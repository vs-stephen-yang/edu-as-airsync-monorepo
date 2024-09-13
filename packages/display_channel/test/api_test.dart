import 'package:display_channel/src/util/api_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'test_util.dart';

void main() {
  final apiOrigin = getApiOriginFromEnv();

  group('Instance Register API', () {
    test(
      'instanceIndex should be greater than 0',
      tags: ['slow'],
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = randomGroupId();

        // Action
        final info = await registerInstance(apiOrigin, instanceId, groupId);

        // Assert
        expect(info.instanceIndex, greaterThan(0));
      },
    );

    test(
      'Responses for requests with the same instanceId and groupId should be identical',
      tags: ['slow'],
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = randomGroupId();

        // Action
        final info1 = await registerInstance(apiOrigin, instanceId, groupId);

        final info2 = await registerInstance(apiOrigin, instanceId, groupId);

        // Assert
        expect(info1.instanceIndex, equals(info2.instanceIndex));
        expect(info1.tunnelApiUrl, equals(info2.tunnelApiUrl));
      },
    );

    test(
      'Instance info should be retrieved successfully after registering with different groupId',
      tags: ['slow'],
      () async {
        // Arrange
        final instanceId = const Uuid().v4();

        final groupId1 = randomGroupId();
        final groupId2 = (groupId1 + 1) % maxInstanceGroupId;

        final info1 = await registerInstance(apiOrigin, instanceId, groupId1);

        // Action
        final info2 = await registerInstance(apiOrigin, instanceId, groupId2);

        // Assert
        expect(info1.instanceIndex, greaterThan(0));
        expect(info2.instanceIndex, greaterThan(0));

        expect(info1.tunnelApiUrl, equals(info2.tunnelApiUrl));
      },
    );
  });

  group('Instance Info API', () {
    test(
      'Instance info should be retrieved successfully after registration',
      tags: ['slow'],
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = randomGroupId();

        final registerInfo =
            await registerInstance(apiOrigin, instanceId, groupId);

        // Action
        final actual = await fetchInstanceInfo(
            apiOrigin, registerInfo.instanceIndex, groupId);

        // Assert
        expect(actual, registerInfo.tunnelApiUrl);
      },
    );

    test(
      'Instance info should remain identical after re-registration',
      tags: ['slow'],
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = randomGroupId();

        final info1 = await registerInstance(apiOrigin, instanceId, groupId);
        final original =
            await fetchInstanceInfo(apiOrigin, info1.instanceIndex, groupId);

        // Action
        final info2 = await registerInstance(apiOrigin, instanceId, groupId);
        final actual =
            await fetchInstanceInfo(apiOrigin, info2.instanceIndex, groupId);

        // Assert
        expect(actual, original);
      },
    );
  });

  group('Race condition', () {
    test(
      'Sequential registrations with the same groupId should return unique instanceIndexes',
      tags: ['slow'],
      () async {
        // Arrange
        final groupId = randomGroupId();
        const uuid = Uuid();

        // Action
        final results = <RegisterInstanceResult>[];

        for (var i = 0; i < 5; ++i) {
          final instanceId = uuid.v4();

          // Sequential API invocations
          results.add(await registerInstance(apiOrigin, instanceId, groupId));
        }

        // Assert
        final instanceIndexes = results
            .map(
              (result) => result.instanceIndex,
            )
            .toList();

        final uniqueInstanceIndexes = instanceIndexes.toSet().toList();

        expect(instanceIndexes, equals(uniqueInstanceIndexes));
      },
    );

    test(
      'Simultaneous registrations with different groupId should complete successfully',
      tags: ['slow'],
      () async {
        // Arrange
        final baseGroupId = randomGroupId();
        const uuid = Uuid();

        // Action
        final futures = <Future<RegisterInstanceResult>>[];

        for (var i = 0; i < 10; ++i) {
          final instanceId = uuid.v4();
          final groupId = (baseGroupId + i) % maxInstanceGroupId;

          // Concurrent API invocations
          futures.add(registerInstance(apiOrigin, instanceId, groupId));
        }
        await Future.wait(futures);

        // Assert
      },
    );

    test(
      'Simultaneous registrations with the same groupId should return unique instanceIndexes',
      tags: ['slow'],
      () async {
        // Arrange
        final groupId = randomGroupId();
        const uuid = Uuid();

        // Action
        final futures = <Future<RegisterInstanceResult>>[];

        for (var i = 0; i < 10; ++i) {
          final instanceId = uuid.v4();
          // Concurrent API invocations
          futures.add(registerInstance(apiOrigin, instanceId, groupId));
        }
        final results = await Future.wait(futures);

        // Assert
        final instanceIndexes = results
            .map(
              (result) => result.instanceIndex,
            )
            .toList();

        final uniqueInstanceIndexes = instanceIndexes.toSet().toList();

        expect(instanceIndexes, equals(uniqueInstanceIndexes));
      },
    );
  });
}

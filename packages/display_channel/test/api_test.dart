import 'dart:math';

import 'package:display_channel/src/util/api_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'test_config.dart';

const maxGroupId = 16777216 - 1;

int _randomGroupId() {
  final seed = DateTime.now().millisecondsSinceEpoch;
  return Random(seed).nextInt(maxGroupId);
}

void main() {
  group('Instance Register API', skip: true, () {
    test(
      'instanceIndex should be greater than 0',
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = _randomGroupId();

        // Action
        final info = await registerInstance(apiOrigin, instanceId, groupId);

        // Assert
        expect(info.instanceIndex, greaterThan(0));
      },
    );

    test(
      'Responses for requests with the same instanceId and groupId should be identical',
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = _randomGroupId();

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
      () async {
        // Arrange
        final instanceId = const Uuid().v4();

        final groupId1 = _randomGroupId();
        final groupId2 = (groupId1 + 1) % maxGroupId;

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

  group('Instance Info API', skip: true, () {
    test(
      'Instance info should be retrieved successfully after registration',
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = _randomGroupId();

        final registerInfo =
            await registerInstance(apiOrigin, instanceId, groupId);

        // Action
        final actual = await fetchInstanceInfo(
            apiOrigin, registerInfo.instanceIndex, groupId);

        // Assert
        expect(registerInfo.tunnelApiUrl, actual);
      },
    );

    test(
      'Instance info should remain identical after re-registration',
      () async {
        // Arrange
        final instanceId = const Uuid().v4();
        final groupId = _randomGroupId();

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

  group('Race condition', skip: true, () {
    test(
      'Sequential registrations with the same groupId should return unique instanceIndexes',
      () async {
        // Arrange
        final groupId = _randomGroupId();
        const uuid = Uuid();

        // Action
        final results = <RegisterInstanceResult>[];

        for (var i = 0; i < 10; ++i) {
          final instanceId = uuid.v4();

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
      'Simultaneous registrations should complete successfully',
      () async {
        // Arrange
        final baseGroupId = _randomGroupId();
        const uuid = Uuid();

        // Action
        final futures = <Future<RegisterInstanceResult>>[];

        for (var i = 0; i < 10; ++i) {
          final instanceId = uuid.v4();
          final groupId = (baseGroupId + i) % maxGroupId;

          // Concurrent API invocations
          futures.add(registerInstance(apiOrigin, instanceId, groupId));
        }
        await Future.wait(futures);

        // Assert
      },
    );

    test(
      'Simultaneous registrations with the same groupId should return unique instanceIndexes',
      () async {
        // Arrange
        final groupId = _randomGroupId();
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

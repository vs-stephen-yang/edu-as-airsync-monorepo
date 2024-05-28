import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

const _updater = 'updater.exe';

// https://www.advancedinstaller.com/user-guide/updater.html#section363
const _updatesFound = 0;
const _noUpdatesAvailable = -536870895;

enum UpdateError {
  updaterNotFound,
  updatesNotAvailable,
  unknownError,
}

class UpdaterErrorException implements Exception {
  int exitCode;

  UpdaterErrorException(this.exitCode);

  @override
  String toString() {
    return 'UpdaterErrorException: $exitCode';
  }
}

class UpdateErrorExecption implements Exception {
  UpdateError error;
  String? details;

  UpdateErrorExecption(this.error, {this.details});

  @override
  String toString() {
    return 'UpdateErrorExecption: $error $details';
  }
}

String _getUpdaterPath() {
  String executableDirectory = path.dirname(Platform.resolvedExecutable);
  return path.join(executableDirectory, _updater);
}

Future<bool> _updaterExists() async {
  return await File(_getUpdaterPath()).exists();
}

// checks if new updates are available
Future<bool> isUpdatesAvailable() async {
  final result = await Process.run(_getUpdaterPath(), ['/justcheck']);

  switch (result.exitCode) {
    case _updatesFound:
      return true;
    case _noUpdatesAvailable:
      return false;
    default:
      throw UpdaterErrorException(result.exitCode);
  }
}

Future<void> installUpdates() async {
  // Does updater executable exist?
  final exists = await _updaterExists();
  if (!exists) {
    throw UpdateErrorExecption(UpdateError.updaterNotFound);
  }

  // Check if new updates are available
  try {
    final hasUpdate = await isUpdatesAvailable();
    if (!hasUpdate) {
      // No updates are available
      throw UpdateErrorExecption(UpdateError.updatesNotAvailable);
    }
  } on UpdaterErrorException catch (e) {
    throw UpdateErrorExecption(
      UpdateError.unknownError,
      details: e.exitCode.toString(),
    );
  } catch (e) {
    throw UpdateErrorExecption(
      UpdateError.unknownError,
      details: e.toString(),
    );
  }

  // Download and install the updates
  // https://www.advancedinstaller.com/user-guide/updater.html#commandline
  final arguments = [
    '/silentall',
    '-nofreqcheck',
    '-reducedgui',
    '-restartapp',
    Platform.resolvedExecutable,
    '-restartappcmd',
    'restart_mode',
  ];

  try {
    await Process.start(_getUpdaterPath(), arguments);
  } catch (e) {
    throw UpdateErrorExecption(
      UpdateError.unknownError,
      details: e.toString(),
    );
  }
}

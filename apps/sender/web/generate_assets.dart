import 'dart:io';
import 'dart:convert';

/// Script to generate service worker with embedded resources list for Flutter web PWA
///
/// Usage: dart generate_service_worker.dart [OPTIONS]
///   --build-dir=PATH     Directory containing the built web app (default: build/web)
///   --template=PATH      Path to service worker template file (default: web/service-worker-template.js)
///   --output=PATH        Path to output service worker file (default: build/web/service-worker.js)
///   --placeholder=TEXT   Placeholder text in template to replace (default: /* ASSETS_PLACEHOLDER */)
///
/// Example: dart generate_service_worker.dart --build-dir=build/web --template=web/service-worker-template.js

void main(List<String> args) async {
  // Default configuration
  String buildDir = 'build/web';
  String templateFile = 'web/service-worker-template.js';
  String outputFile = 'build/web/service-worker.js';
  String placeholder = '/* ASSETS_PLACEHOLDER */';

  // Parse arguments
  for (final arg in args) {
    if (arg.startsWith('--build-dir=')) {
      buildDir = arg.substring('--build-dir='.length);
    } else if (arg.startsWith('--template=')) {
      templateFile = arg.substring('--template='.length);
    } else if (arg.startsWith('--output=')) {
      outputFile = arg.substring('--output='.length);
    } else if (arg.startsWith('--placeholder=')) {
      placeholder = arg.substring('--placeholder='.length);
    }
  }

  // Validate input files
  final buildDirectory = Directory(buildDir);
  if (!await buildDirectory.exists()) {
    stderr.writeln('❌ Error: Build directory $buildDir does not exist.');
    exit(1);
  }

  final template = File(templateFile);
  if (!await template.exists()) {
    stderr.writeln('❌ Error: Template file $templateFile does not exist.');
    exit(1);
  }

  print('🔍 Scanning assets in $buildDir...');

  // Create a list to hold the resources
  final List<String> resources = [];
  final skipFiles = [
    'service-worker.js',
    'flutter_service_worker.js',
    'main.dart.js.map',
  ];

  // Scan the build directory for files
  await for (final entity in buildDirectory.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      // Get the path relative to the build directory
      String relativePath = entity.path.substring(buildDirectory.path.length);

      // Replace backslashes with forward slashes for Windows compatibility
      relativePath = relativePath.replaceAll(r'\', '/');

      // Remove the leading slash if present, except for the root path "/"
      if (relativePath.startsWith('/') && relativePath != '/') {
        relativePath = relativePath.substring(1);
      }

      // Skip files that should be excluded
      bool shouldSkip = false;
      for (final skipFile in skipFiles) {
        if (relativePath == skipFile || relativePath.endsWith('/$skipFile')) {
          shouldSkip = true;
          break;
        }
      }

      if (!shouldSkip) {
        resources.add(relativePath);
      }
    }
  }

  // Add the root path
  resources.add('/');

  // Sort resources for consistency
  resources.sort();

  print('📋 Found ${resources.length} resources to cache');

  // Create the resources array as JavaScript code
  final StringBuffer resourcesArray = StringBuffer();
  resourcesArray.writeln('const RESOURCES = [');

  // Add all resources except the last one with trailing commas
  for (int i = 0; i < resources.length - 1; i++) {
    // JSON encode for proper escaping of special characters, then strip the outer quotes
    // and re-add them to ensure consistent quoting style
    final encoded = jsonEncode(resources[i]);
    final formattedPath = encoded.substring(1, encoded.length - 1);
    resourcesArray.writeln('  "$formattedPath",');
  }

  // Add the last resource without a trailing comma
  if (resources.isNotEmpty) {
    final encoded = jsonEncode(resources.last);
    final formattedPath = encoded.substring(1, encoded.length - 1);
    resourcesArray.writeln('  "$formattedPath"');
  }

  resourcesArray.writeln('];');

  // Read the template file
  print('📝 Reading template from $templateFile');
  final templateContent = await template.readAsString();

  // Check if placeholder exists in template
  if (!templateContent.contains(placeholder)) {
    stderr.writeln('❌ Error: Placeholder text "$placeholder" not found in template file.');
    exit(1);
  }

  // Replace the placeholder with the resources array
  final serviceWorkerContent = templateContent.replaceFirst(
    placeholder,
    resourcesArray.toString(),
  );

  // Write the output file
  print('💾 Writing service worker to $outputFile');
  final outputFileHandle = File(outputFile);
  await outputFileHandle.writeAsString(serviceWorkerContent);

  // Validate the result
  if (await outputFileHandle.exists()) {
    final size = await outputFileHandle.length();
    print('✅ Service worker generated successfully (${(size / 1024).toStringAsFixed(2)} KB)');
    print('🚀 PWA assets are ready for offline use');
  } else {
    stderr.writeln('❌ Error: Failed to write service worker file.');
    exit(1);
  }
}
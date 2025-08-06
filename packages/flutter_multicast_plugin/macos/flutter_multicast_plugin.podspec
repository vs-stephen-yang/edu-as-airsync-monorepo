#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_multicast_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_multicast_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for uvgRTP + GStreamer on macOS'
  s.description      = <<-DESC
                        A Flutter plugin for uvgRTP + GStreamer on macOS
                        DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_multicast_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.static_framework = true
  
  s.source_files = 'Classes/**/*.{h,m,mm}', 'native_src/gstreamer/*.{h,m,mm}'
  s.public_header_files = 'Classes/**/*.h'
  
  s.frameworks = 'Foundation', 'AVFoundation', 'AudioToolbox', 'CoreMedia', 'CoreVideo', 'VideoToolbox'

  # 只連結系統庫
  s.libraries = 'iconv', 'c++', 'z', 'bz2', 'resolv'
  
  # 使用相對路徑的 vendored_libraries
  s.vendored_libraries = [
    'libs/*.a',
    'gstreamer-dylibs/*.dylib'
  ]

  s.resources = ['gstreamer-frameworks']

  log_level = ENV['LOG_LEVEL'] || 'LOG_LEVEL_WARN'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => "$(inherited) $(PODS_TARGET_SRCROOT)/../native_libs/common $(PODS_TARGET_SRCROOT)/../native_libs/uvgrtp/include $(PODS_TARGET_SRCROOT)/gstreamer-headers",
    'OTHER_LDFLAGS' => '$(inherited) -Wl,-rpath,@loader_path/../Resources',
    'OTHER_CFLAGS' => "-DLOG_LEVEL=LOG_LEVEL_WARN",
    'DEFINES_MODULE' => 'YES'
  }
end

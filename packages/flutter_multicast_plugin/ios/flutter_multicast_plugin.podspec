#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_multicast_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_multicast_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for uvgRTP + GStreamer on iOS'
  s.description      = <<-DESC
                        A Flutter plugin for uvgRTP + GStreamer on iOS
                        DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.platform = :ios, '12.0'
  s.static_framework = true

  # 檢查 GStreamer 環境變數
  gstreamer_root = ENV['GSTREAMER_SDK_IOS']
  
  if gstreamer_root.nil? || gstreamer_root.empty?
    puts "❌ Error: GSTREAMER_SDK_IOS environment variable not set!"
    puts "Please run: export GSTREAMER_SDK_IOS=/path/to/GStreamer.framework"
    puts "Example: export GSTREAMER_SDK_IOS=/usr/local/gstreamer-ios/GStreamer.framework"
    raise "GSTREAMER_SDK_IOS environment variable is required"
  end
  
  unless Dir.exist?(gstreamer_root)
    puts "❌ Error: GStreamer directory does not exist: #{gstreamer_root}"
    puts "Please check your GSTREAMER_SDK_IOS path"
    raise "Invalid GSTREAMER_SDK_IOS path: #{gstreamer_root}"
  end

  gstreamer_search_path = File.dirname(gstreamer_root)
  gstreamer_headers = "#{gstreamer_root}/Headers"

  s.source_files = 'Classes/**/*.{h,m,mm}', 'native_src/gstreamer/*.{h,m,mm}'
  s.public_header_files = 'Classes/**/*.h'

  s.vendored_libraries = 'libs/*.a'

  framework_flags = "-F\"#{gstreamer_search_path}\" -framework GStreamer"

  s.dependency 'Flutter'
  s.frameworks = 'Foundation', 'AVFoundation', 'AudioToolbox', 'CoreMedia', 'CoreVideo', 'AssetsLibrary', 'VideoToolbox', 'GStreamer'
  s.libraries = 'iconv', 'c++'

  log_level = ENV['LOG_LEVEL'] || 'LOG_LEVEL_WARN'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => "$(inherited) $(PODS_TARGET_SRCROOT)/../native_libs/common $(PODS_TARGET_SRCROOT)/../native_libs/uvgrtp/include #{gstreamer_headers}",
    'FRAMEWORK_SEARCH_PATHS' => "$(inherited) \"#{gstreamer_search_path}\"",
    'OTHER_LDFLAGS' => '$(inherited) #{framework_flags} -framework VideoToolbox -framework AudioToolbox -framework CoreVideo -framework CoreMedia',
    'OTHER_CFLAGS' => "-DLOG_LEVEL=#{log_level}"
  }

  s.user_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => "$(inherited) \"#{gstreamer_search_path}\"",
    'OTHER_LDFLAGS' => "$(inherited) #{framework_flags}"
  }
end

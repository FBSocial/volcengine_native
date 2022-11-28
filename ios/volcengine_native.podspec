#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint volcengine_native.podspec` to validate before publishing.
#

Pod::Spec.new do |s|
  s.name             = 'volcengine_native'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter volcengine native plugin.'
  s.description      = <<-DESC
A new Flutter volcengine native plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => '星河滚烫@idreamsky.com' }
  s.source           = { :path => '.' , :git => 'https://github.com/volcengine/volcengine-specs.git'}

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  # 火山
  # https://www.volcengine.com/docs/6431/68850#subspecs%E8%AF%B4%E6%98%8E
  s.dependency 'RangersAPM/Crash', '3.0.1'
  s.dependency 'RangersAPM/WatchDog', '3.0.1'
  s.dependency 'RangersAPM/OOM', '3.0.1'
  s.dependency 'RangersAPM/LAG', '3.0.1'
  s.dependency 'RangersAPM/UserException', '3.0.1'
  s.dependency 'RangersAPM/Monitors', '3.0.1'
  s.dependency 'RangersAPM/UITrackers', '3.0.1'
  s.dependency 'RangersAPM/Hybrid', '3.0.1'
  s.dependency 'RangersAPM/MemoryGraph', '3.0.1'
  s.dependency 'RangersAPM/NetworkPro', '3.0.1'
  s.dependency 'RangersAPM/EventMonitor', '3.0.1'
  s.dependency 'RangersAPM/SessionTracker', '3.0.1'
  s.dependency 'RangersAPM/APMLog', '3.0.1'
  s.dependency 'RangersAPM/CrashProtector', '3.0.1'
  s.dependency 'RangersAPM/CPUException', '3.0.1'
  s.dependency 'RangersAPM/MetricKit', '3.0.1'
  s.dependency 'RangersAPM/Disk', '3.0.1'
  s.dependency 'RangersAPM/CN', '3.0.1'

  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end

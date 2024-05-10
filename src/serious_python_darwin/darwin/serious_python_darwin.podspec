#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint serious_python_darwin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'serious_python_darwin'
  s.version          = '0.7.0'
  s.summary          = 'A cross-platform plugin for adding embedded Python runtime to your Flutter apps.'
  s.description      = <<-DESC
  A cross-platform plugin for adding embedded Python runtime to your Flutter apps.
                       DESC
  s.homepage         = 'https://flet.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Appveyor Systems Inc.' => 'hello@flet.dev' }
  s.source           = { :path => '.' }
  #s.static_framework = true
  s.source_files = ['Classes/**/*']
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.15'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'OTHER_LDFLAGS' => '-ObjC -all_load -lc++'
  }
  s.swift_version = '5.0'

  python_version = "3.12.3"
  python_macos_framework = 'dist_macos/Python.xcframework'

  dist_ios = "dist_ios"
  dist_macos = "dist_macos"

  prepare_command = <<-CMD

    rm -rf #{dist_ios}
    mkdir -p #{dist_ios}
    dist_ios=$(realpath #{dist_ios})

    ./prepare_ios.sh #{s.version} #{python_version} $dist_ios

    rm -rf #{dist_macos}
    mkdir -p #{dist_macos}
    dist_macos=$(realpath #{dist_macos})

    ./prepare_macos.sh #{s.version} #{python_version} $dist_macos
    
CMD

puts `#{prepare_command}`

# my_script = <<-SCRIPT_PHASE
#   mkdir -p ${HOME}/123456
#   printenv > ${HOME}/123456/env.txt
#   cp -R $HOME/projects/flet-dev/serious-python/src/serious_python_darwin/darwin/dist/xcframework/yarl.xcframework/ios-arm64/* ${CODESIGNING_FOLDER_PATH}/../
#   ls -alR ${CODESIGNING_FOLDER_PATH}/../ > ${HOME}/123456/ls.txt
# SCRIPT_PHASE

#   s.ios.script_phase = { :name => 'Hello World', :script => my_script, :execution_position => :before_compile }

  # scan all frameworks
  xcframeworks_dir = "#{dist_ios}/xcframeworks"
  ios_frameworks = Dir.glob("#{xcframeworks_dir}/*.xcframework").map do |dir|
    xcframeworks_dir + '/' + Pathname.new(dir).basename.to_s
  end

  s.libraries = 'z', 'bz2', 'c++', 'sqlite3'
  s.ios.vendored_frameworks = ios_frameworks
  s.ios.resource = ["#{dist_ios}/python-stdlib", "#{dist_ios}/site-packages"]

  s.osx.vendored_frameworks = python_macos_framework
  s.osx.resource = ['dist_macos/python-stdlib']
end

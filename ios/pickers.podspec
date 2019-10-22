#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'pickers'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/lisen87/pickers.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '' => '1597828092@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency  'ZLPhotoBrowser'
#  s.resources = ['Classes/PhotoBrowser/resource/ZLPhotoBrowser.bundle','Classes/AKGallery/img']

  s.ios.deployment_target = '8.0'
end


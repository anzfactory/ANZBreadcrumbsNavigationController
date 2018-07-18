#
# Be sure to run `pod lib lint ANZBreadcrumbsNavigationController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ANZBreadcrumbsNavigationController'
  s.version          = '0.3.0'
  s.summary          = 'Breadcrumbs navigation controller.'
  s.description      = <<-DESC
ANZBreadcrumbsNavigationController is breadcrums navigation
                       DESC

  s.homepage         = 'https://github.com/anzfactory/ANZBreadcrumbsNavigationController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anzfactory' => 'anz.factory@gmail.com' }
  s.source           = { :git => 'https://github.com/anzfactory/ANZBreadcrumbsNavigationController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/AnzNetJp'

  s.platform     = :ios, "11.0"
  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }

  s.source_files = 'ANZBreadcrumbsNavigationController/Classes/**/*'
  s.frameworks = 'UIKit'

end

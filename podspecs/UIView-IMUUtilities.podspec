#
# Be sure to run `pod spec lint UIView-IMUtilities.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "UIView-IMUUtilities"
  s.version      = "0.0.1"
  s.summary      = "UIView convenience categories."
  s.homepage     = "https://github.com/imulus/UIView-IMUUtilities"
  s.license      = { :type => 'WTFPL', :file => 'LICENSE' }
  s.author       = { "Bryce Hammond" => "bryce.hammond@imulus.com" }
  s.source       = { :git => "https://github.com/imulus/UIView-IMUUtilities.git", :tag => "0.0.1" }
  s.platform     = :ios, '5.0'

  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.framework  = 'QuartzCore'
  s.requires_arc = true

end

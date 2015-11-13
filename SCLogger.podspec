#
#  Be sure to run `pod spec lint SCLogger.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "SCLogger"
  s.version      = "1.3"
  s.summary      = "SCLogger is a debugging console created by developer for developers, easy integration with your project.
  http://www.lucascorrea.com
  "

  s.description  = <<-DESC
                   SCLogger is a debugging console created by developer for developers, easy integration with your project.
                   http://www.lucascorrea.com
                   For all NSLog used in the project will be recorded in SCLogger also is recorded in a log file
                   DESC

  s.homepage     = "https://github.com/lucascorrea/SCLogger"
  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "Lucas Correa" => "contato@lucascorrea.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "5.0"

  s.source       = { :git => "https://github.com/lucascorrea/SCLogger.git", :tag => "1.3" }


  s.source_files  = "**/SCLogger.{h,m}"

  s.framework  = "MessageUI"
  s.requires_arc = true
end

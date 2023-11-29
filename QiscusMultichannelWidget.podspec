Pod::Spec.new do |s|

s.name         = "QiscusMultichannelWidget"

s.version      = "2.3.2"

s.summary      = "Customer Chat integration."

s.homepage     = "http://qiscus.com"
# s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

s.license      = "MIT"

s.author       = { "arief@qiscus.co" => "arief@qiscus.co" }

s.platform     = :ios, "10.0"
s.swift_version = '4.2'
s.source       = { :git => "https://github.com/qiscus/qiscus-multichannel-widget-ios", :tag => "#{s.version}" }

s.source_files  = "QiscusMultichannelWidget", "Source/QiscusMultichannelWidget/**/*.{h,m,swift,xib}"

s.resources = "Source/QiscusMultichannelWidget/**/*.xcassets"
s.resource_bundles = {
    'QiscusMultichannelWidget' => ['Source/QiscusMultichannelWidget/**/*.{lproj,xib,xcassets,imageset,png}']
}

s.framework		= 'UIKit', 'AVFoundation'
s.requires_arc	= false

s.dependency 'Alamofire'
s.dependency 'AlamofireImage'
s.dependency 'SwiftyJSON'
s.dependency 'QiscusCore', '3.0.0-beta.16'
s.dependency 'SDWebImage'
s.dependency 'SDWebImageWebPCoder'
#s.dependency 'CropViewController'
end

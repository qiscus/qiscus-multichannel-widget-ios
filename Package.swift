// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QiscusMultichannelWidget",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "QiscusMultichannelWidget",
            targets: ["QiscusMultichannelWidget"]),
    ],
	
	dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", .upToNextMajor(from: "4.3.0")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.10.0"),
	.package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.3.0"),
	.package(url: "https://github.com/qiscus/QiscusCore-iOS.git", .branch ("support-carthage-v3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "QiscusMultichannelWidget",
            dependencies: [
                "SwiftyJSON",
                "Alamofire",
                "AlamofireImage",
                "SDWebImage",
		"SDWebImageWebPCoder",
                .product(name: "QiscusCore", package: "QiscusCore-iOS")
            ],
            path: "Source/QiscusMultichannelWidget",
	    resources: [
        	.process("Source/QiscusMultichannelWidget/")
	    ]
        ),
    ]
)

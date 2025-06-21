// swift-tools-version: 5.9
// MorphoPhotoKit - RAW图片和EXIF元数据处理库

import PackageDescription

let package = Package(
    name: "MorphoPhotoKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MorphoPhotoKit",
            targets: ["MorphoPhotoKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MorphoPhotoKit",
            dependencies: [],
            path: "Sources/MorphoPhotoKit"
        ),
        .testTarget(
            name: "MorphoPhotoKitTests",
            dependencies: ["MorphoPhotoKit"],
            path: "Tests/MorphoPhotoKitTests"
        ),
    ]
) 
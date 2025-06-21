import XCTest
@testable import MorphoPhotoKit

final class MorphoPhotoKitTests: XCTestCase {
    
    var morphoKit: MorphoPhotoKit!
    
    override func setUpWithError() throws {
        morphoKit = MorphoPhotoKit()
    }
    
    override func tearDownWithError() throws {
        morphoKit = nil
    }
    
    // MARK: - 基础功能测试
    
    func testMorphoPhotoKitInitialization() throws {
        XCTAssertNotNil(morphoKit)
        XCTAssertNotNil(morphoKit.metadataExtractor)
        XCTAssertNotNil(morphoKit.imageProcessor)
        XCTAssertNotNil(morphoKit.metadataWriter)
    }
    
    func testSupportedFormats() throws {
        let supportedFormats = morphoKit.getSupportedFormats()
        let rawFormats = morphoKit.getSupportedRAWFormats()
        
        XCTAssertTrue(supportedFormats.contains("jpg"))
        XCTAssertTrue(supportedFormats.contains("png"))
        XCTAssertTrue(supportedFormats.contains("arw"))
        XCTAssertTrue(supportedFormats.contains("nef"))
        
        XCTAssertTrue(rawFormats.contains("arw"))
        XCTAssertTrue(rawFormats.contains("nef"))
        XCTAssertTrue(rawFormats.contains("cr2"))
        XCTAssertTrue(rawFormats.contains("dng"))
    }
    
    // MARK: - RAW格式检测测试
    
    func testRAWFormatDetection() throws {
        // 测试RAW格式检测
        let rawURL = URL(fileURLWithPath: "/path/to/image.arw")
        let jpegURL = URL(fileURLWithPath: "/path/to/image.jpg")
        
        XCTAssertTrue(morphoKit.isRAWFormat(rawURL))
        XCTAssertFalse(morphoKit.isRAWFormat(jpegURL))
        XCTAssertTrue(MorphoPhotoKit.isRAWFormat(rawURL))
    }
    
    func testMorphoRAWFormatEnum() throws {
        XCTAssertEqual(MorphoRAWFormat.arw.rawValue, "arw")
        XCTAssertEqual(MorphoRAWFormat.nef.rawValue, "nef")
        XCTAssertEqual(MorphoRAWFormat.cr2.rawValue, "cr2")
        
        let allExtensions = MorphoRAWFormat.allExtensions
        XCTAssertTrue(allExtensions.contains("arw"))
        XCTAssertTrue(allExtensions.contains("nef"))
        XCTAssertTrue(allExtensions.contains("cr2"))
        XCTAssertTrue(allExtensions.contains("cr3"))
        XCTAssertTrue(allExtensions.contains("dng"))
        
        XCTAssertTrue(MorphoRAWFormat.isRAWFormat("arw"))
        XCTAssertTrue(MorphoRAWFormat.isRAWFormat("NEF"))
        XCTAssertFalse(MorphoRAWFormat.isRAWFormat("jpg"))
    }
    
    // MARK: - 元数据结构测试
    
    func testMorphoExifMetadata() throws {
        var exif = MorphoExifMetadata()
        
        XCTAssertFalse(exif.hasBasicInfo)
        
        exif.iso = "800"
        exif.fNumber = "f/2.8"
        exif.exposureTime = "1/60"
        
        XCTAssertTrue(exif.hasBasicInfo)
        XCTAssertEqual(exif.iso, "800")
        XCTAssertEqual(exif.fNumber, "f/2.8")
        XCTAssertEqual(exif.exposureTime, "1/60")
    }
    
    func testMorphoGPSMetadata() throws {
        var gps = MorphoGPSMetadata()
        
        XCTAssertFalse(gps.hasValidCoordinates)
        XCTAssertNil(gps.coordinateString)
        
        gps.latitude = 39.9042
        gps.longitude = 116.4074
        gps.latitudeRef = "N"
        gps.longitudeRef = "E"
        gps.altitude = 100.0
        gps.altitudeRef = 0
        
        XCTAssertTrue(gps.hasValidCoordinates)
        XCTAssertNotNil(gps.coordinateString)
        XCTAssertTrue(gps.coordinateString!.contains("39.904200°N"))
        XCTAssertTrue(gps.coordinateString!.contains("116.407400°E"))
    }
    
    func testMorphoPhotoMetadata() throws {
        var metadata = MorphoPhotoMetadata()
        
        XCTAssertFalse(metadata.hasMetadata)
        
        metadata.exif.iso = "800"
        metadata.exif.fNumber = "f/2.8"
        metadata.exif.exposureTime = "1/60"
        
        XCTAssertTrue(metadata.hasMetadata)
        
        metadata.gps.latitude = 39.9042
        metadata.gps.longitude = 116.4074
        metadata.gps.latitudeRef = "N"
        metadata.gps.longitudeRef = "E"
        
        XCTAssertTrue(metadata.hasMetadata)
        XCTAssertTrue(metadata.exif.hasBasicInfo)
        XCTAssertTrue(metadata.gps.hasValidCoordinates)
    }
    
    // MARK: - 错误处理测试
    
    func testMorphoError() throws {
        let error1 = MorphoError.fileNotFound("/path/to/file")
        XCTAssertEqual(error1.localizedDescription, "文件不存在: /path/to/file")
        
        let error2 = MorphoError.unsupportedFormat("xyz")
        XCTAssertEqual(error2.localizedDescription, "不支持的格式: xyz")
        
        let error3 = MorphoError.invalidImageSource
        XCTAssertEqual(error3.localizedDescription, "无效的图像源")
    }
    
    func testImageInfoResult() throws {
        let url = URL(fileURLWithPath: "/path/to/test.jpg")
        let size = CGSize(width: 1920, height: 1080)
        let fileSize: Int64 = 1024 * 1024 // 1MB
        let metadata = MorphoPhotoMetadata()
        
        let result = MorphoImageInfo(
            fileURL: url,
            imageSize: size,
            fileSize: fileSize,
            isRAWFormat: false,
            metadata: metadata
        )
        
        XCTAssertEqual(result.fileURL, url)
        XCTAssertEqual(result.imageSize, size)
        XCTAssertEqual(result.fileSize, fileSize)
        XCTAssertFalse(result.isRAWFormat)
        
        XCTAssertEqual(result.imageSizeString, "1920 × 1080")
        XCTAssertTrue(result.fileSizeString.contains("MB"))
    }
    
    // MARK: - 组件初始化测试
    
    func testMorphoMetadataExtractor() throws {
        let extractor = MorphoMetadataExtractor()
        XCTAssertNotNil(extractor)
    }
    
    func testMorphoImageProcessor() throws {
        let processor = MorphoImageProcessor()
        XCTAssertNotNil(processor)
        
        let supportedTypes = MorphoImageProcessor.getSupportedImageTypes()
        XCTAssertFalse(supportedTypes.isEmpty)
    }
    
    func testMorphoMetadataWriter() throws {
        let writer = MorphoMetadataWriter()
        XCTAssertNotNil(writer)
    }
    
    // MARK: - 静态方法测试
    
    func testStaticMethods() throws {
        let rawURL = URL(fileURLWithPath: "/path/to/image.arw")
        let jpegURL = URL(fileURLWithPath: "/path/to/image.jpg")
        
        XCTAssertTrue(MorphoPhotoKit.isRAWFormat(rawURL))
        XCTAssertFalse(MorphoPhotoKit.isRAWFormat(jpegURL))
    }
    
    // MARK: - 性能测试
    
    func testPerformanceRAWFormatDetection() throws {
        let urls = (0..<1000).map { URL(fileURLWithPath: "/path/to/image\($0).arw") }
        
        measure {
            for url in urls {
                _ = MorphoPhotoKit.isRAWFormat(url)
            }
        }
    }
    
    func testPerformanceMetadataStructCreation() throws {
        measure {
            for _ in 0..<1000 {
                var metadata = MorphoPhotoMetadata()
                metadata.exif.iso = "800"
                metadata.exif.fNumber = "f/2.8"
                metadata.gps.latitude = 39.9042
                metadata.gps.longitude = 116.4074
                _ = metadata.hasMetadata
            }
        }
    }
    
    // MARK: - 边界条件测试
    
    func testEmptyMetadata() throws {
        let metadata = MorphoPhotoMetadata()
        XCTAssertFalse(metadata.hasMetadata)
        XCTAssertFalse(metadata.exif.hasBasicInfo)
        XCTAssertFalse(metadata.gps.hasValidCoordinates)
        XCTAssertNil(metadata.gps.coordinateString)
    }
    
    func testInvalidGPSCoordinates() throws {
        var gps = MorphoGPSMetadata()
        
        // 只设置纬度，不设置经度
        gps.latitude = 39.9042
        gps.latitudeRef = "N"
        
        XCTAssertFalse(gps.hasValidCoordinates)
        XCTAssertNil(gps.coordinateString)
        
        // 设置经度但不设置参考
        gps.longitude = 116.4074
        gps.longitudeRef = nil
        
        XCTAssertFalse(gps.hasValidCoordinates)
        XCTAssertNil(gps.coordinateString)
    }
    
    func testPartialExifData() throws {
        var exif = MorphoExifMetadata()
        
        // 只设置ISO，不设置其他基本信息
        exif.iso = "800"
        XCTAssertFalse(exif.hasBasicInfo)
        
        // 设置光圈但不设置快门
        exif.fNumber = "f/2.8"
        XCTAssertFalse(exif.hasBasicInfo)
        
        // 设置完整的基本信息
        exif.exposureTime = "1/60"
        XCTAssertTrue(exif.hasBasicInfo)
    }
    
    // MARK: - 文件不存在测试
    
    func testFileNotFoundError() throws {
        let nonExistentURL = URL(fileURLWithPath: "/path/to/nonexistent.jpg")
        
        XCTAssertThrowsError(try morphoKit.imageProcessor.loadImage(from: nonExistentURL)) { error in
            if case MorphoError.fileNotFound(let path) = error {
                XCTAssertEqual(path, "/path/to/nonexistent.jpg")
            } else {
                XCTFail("Expected fileNotFound error")
            }
        }
    }
    
    func testUnsupportedFormatError() throws {
        let unsupportedURL = URL(fileURLWithPath: "/path/to/file.xyz")
        
        XCTAssertThrowsError(try morphoKit.processImage(from: unsupportedURL)) { error in
            if case MorphoError.unsupportedFormat(let format) = error {
                XCTAssertEqual(format, "xyz")
            } else {
                XCTFail("Expected unsupportedFormat error")
            }
        }
    }
} 
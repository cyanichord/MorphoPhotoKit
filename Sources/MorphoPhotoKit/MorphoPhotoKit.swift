import Foundation

#if canImport(AppKit)
import AppKit
public typealias MorphoPlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
public typealias MorphoPlatformImage = UIImage
#endif

// MARK: - MorphoPhotoKit 主API

/// MorphoPhotoKit - RAW图片和EXIF元数据处理库
/// 

public class MorphoPhotoKit {
    
    // MARK: - 初始化
    
    public init() {}
    
    // MARK: - 图片处理 API
    
    /// 处理图片文件 - 使用闭包回调，不保留图片数据
    /// - Parameters:
    ///   - url: 图片文件URL
    ///   - completion: 处理完成回调，包含图片和元数据
    /// - Throws: MorphoError 当处理失败时
    public func processImage(
        from url: URL,
        completion: (MorphoPlatformImage, MorphoPhotoMetadata) throws -> Void
    ) throws {
        // 检查文件是否支持
        guard isSupported(url) else {
            throw MorphoError.unsupportedFormat(url.pathExtension)
        }
        
        // 创建图片源，立即处理，不保留
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw MorphoError.invalidImageSource
        }
        
        // 获取图片
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw MorphoError.imageDecodingFailed
        }
        
        // 获取属性并立即转换为元数据
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            throw MorphoError.metadataExtractionFailed
        }
        
        let metadata = MorphoMetadataExtractor.extractMetadata(from: properties, fileURL: url)
        
        // 标准化图片
        let standardizedImage = MorphoImageProcessor.standardizeImageForGPU(cgImage)
        
        #if canImport(AppKit)
        let platformImage = NSImage(cgImage: standardizedImage, size: .zero)
        #else
        let platformImage = UIImage(cgImage: standardizedImage)
        #endif
        
        // 通过闭包返回结果，函数结束后不保留任何数据
        try completion(platformImage, metadata)
    }
    
    /// 获取图片信息 - 使用闭包回调，不保留图片数据
    /// - Parameters:
    ///   - url: 图片文件URL
    ///   - completion: 完成回调，包含图片信息
    /// - Throws: MorphoError 当获取失败时
    public func getImageInfo(
        from url: URL,
        completion: (MorphoImageInfo) throws -> Void
    ) throws {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw MorphoError.invalidImageSource
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            throw MorphoError.metadataExtractionFailed
        }
        
        // 获取基本信息
        var size = CGSize.zero
        var fileSize: Int64 = 0
        
        if let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
           let height = properties[kCGImagePropertyPixelHeight] as? NSNumber {
            size = CGSize(width: width.doubleValue, height: height.doubleValue)
        }
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSizeNumber = fileAttributes[.size] as? NSNumber {
                fileSize = fileSizeNumber.int64Value
            }
        } catch {
            throw MorphoError.fileAccessFailed(error.localizedDescription)
        }
        
        // 提取元数据
        let metadata = MorphoMetadataExtractor.extractMetadata(from: properties, fileURL: url)
        let isRAW = Self.isRAWFormat(url)
        
        let imageInfo = MorphoImageInfo(
            fileURL: url,
            imageSize: size,
            fileSize: fileSize,
            isRAWFormat: isRAW,
            metadata: metadata
        )
        
        // 通过闭包返回结果
        try completion(imageInfo)
    }
    
    /// 批量处理图片 - 使用闭包逐个处理，不保留批量数据
    /// - Parameters:
    ///   - urls: 图片文件URL数组
    ///   - itemProcessor: 单个项目处理回调
    ///   - completion: 完成回调
    public func processImages(
        from urls: [URL],
        itemProcessor: (URL, Result<(MorphoPlatformImage, MorphoPhotoMetadata), MorphoError>) -> Void,
        completion: () -> Void
    ) {
        for url in urls {
            do {
                try processImage(from: url) { image, metadata in
                    itemProcessor(url, .success((image, metadata)))
                }
            } catch let error as MorphoError {
                itemProcessor(url, .failure(error))
            } catch {
                itemProcessor(url, .failure(.fileAccessFailed(error.localizedDescription)))
            }
        }
        completion()
    }
    
    // MARK: - 元数据修改 API
    
    /// 更新GPS信息并通过闭包返回原始元数据用于备份
    /// - Parameters:
    ///   - url: 图片文件URL
    ///   - latitude: 纬度
    ///   - longitude: 经度
    ///   - altitude: 海拔（可选）
    ///   - backupHandler: 备份处理回调，接收原始元数据
    /// - Throws: MorphoError 当更新失败时
    public func updateGPSInfo(
        at url: URL,
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil,
        backupHandler: (MorphoPhotoMetadata) -> Void
    ) throws {
        
        // 读取原始图片数据
        let imageData: Data
        do {
            imageData = try Data(contentsOf: url)
        } catch {
            throw MorphoError.fileAccessFailed(error.localizedDescription)
        }
        
        // 创建图片源并立即处理
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw MorphoError.invalidImageSource
        }
        
        guard let originalProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            throw MorphoError.metadataExtractionFailed
        }
        
        // 立即提取原始元数据并通过闭包返回
        let originalMetadata = MorphoMetadataExtractor.extractMetadata(from: originalProperties, fileURL: url)
        backupHandler(originalMetadata)
        
        // 创建新的GPS元数据
        var gpsMetadata = MorphoGPSMetadata()
        gpsMetadata.latitude = latitude
        gpsMetadata.longitude = longitude
        gpsMetadata.latitudeRef = latitude >= 0 ? "N" : "S"
        gpsMetadata.longitudeRef = longitude >= 0 ? "E" : "W"
        
        if let altitude = altitude {
            gpsMetadata.altitude = altitude
            gpsMetadata.altitudeRef = altitude >= 0 ? 0 : 1
        }
        
        gpsMetadata.timestamp = Date()
        
        // 更新属性
        var updatedProperties = originalProperties
        updatedProperties[kCGImagePropertyGPSDictionary] = MorphoMetadataWriter.createGPSProperties(from: gpsMetadata)
        
        // 立即保存，不保留数据
        try MorphoMetadataWriter.saveImageWithProperties(imageData: imageData, to: url, properties: updatedProperties)
    }
    
    /// 更新EXIF信息并通过闭包返回原始元数据用于备份
    /// - Parameters:
    ///   - url: 图片文件URL
    ///   - exifMetadata: EXIF元数据
    ///   - backupHandler: 备份处理回调，接收原始元数据
    /// - Throws: MorphoError 当更新失败时
    public func updateExifInfo(
        at url: URL,
        with exifMetadata: MorphoExifMetadata,
        backupHandler: (MorphoPhotoMetadata) -> Void
    ) throws {
        
        // 读取原始图片数据
        let imageData: Data
        do {
            imageData = try Data(contentsOf: url)
        } catch {
            throw MorphoError.fileAccessFailed(error.localizedDescription)
        }
        
        // 创建图片源并立即处理
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw MorphoError.invalidImageSource
        }
        
        guard let originalProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            throw MorphoError.metadataExtractionFailed
        }
        
        // 立即提取原始元数据并通过闭包返回
        let originalMetadata = MorphoMetadataExtractor.extractMetadata(from: originalProperties, fileURL: url)
        backupHandler(originalMetadata)
        
        // 更新EXIF属性
        var updatedProperties = originalProperties
        var exifDict = originalProperties[kCGImagePropertyExifDictionary] as? [CFString: Any] ?? [:]
        exifDict = MorphoMetadataWriter.mergeExifData(exifDict, with: exifMetadata)
        updatedProperties[kCGImagePropertyExifDictionary] = exifDict
        
        // 立即保存，不保留数据
        try MorphoMetadataWriter.saveImageWithProperties(imageData: imageData, to: url, properties: updatedProperties)
    }
    
    /// 恢复原始元数据
    /// - Parameters:
    ///   - url: 图片文件URL
    ///   - originalMetadata: 要恢复的原始元数据
    /// - Throws: MorphoError 当恢复失败时
    public func restoreOriginalMetadata(
        at url: URL,
        with originalMetadata: MorphoPhotoMetadata
    ) throws {
        
        // 读取当前图片数据
        let imageData: Data
        do {
            imageData = try Data(contentsOf: url)
        } catch {
            throw MorphoError.fileAccessFailed(error.localizedDescription)
        }
        
        // 创建原始属性字典
        let originalProperties = MorphoMetadataWriter.createPropertiesFromMetadata(originalMetadata)
        
        // 立即保存恢复后的图片
        try MorphoMetadataWriter.saveImageWithProperties(imageData: imageData, to: url, properties: originalProperties)
    }
    
    // MARK: - 图片保存 API
    
    /// 保存处理后的图片并保留元数据 - 通过闭包获取原始元数据
    /// - Parameters:
    ///   - imageData: 处理后的图片数据
    ///   - outputURL: 输出文件URL
    ///   - originalURL: 原始文件URL
    ///   - metadataProvider: 元数据提供回调
    /// - Throws: MorphoError 当保存失败时
    public func saveProcessedImage(
        imageData: Data,
        to outputURL: URL,
        originalURL: URL,
        metadataProvider: (MorphoPhotoMetadata) throws -> Void
    ) throws {
        
        // 从原始文件获取元数据
        guard let imageSource = CGImageSourceCreateWithURL(originalURL as CFURL, nil) else {
            throw MorphoError.invalidImageSource
        }
        
        guard let originalProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            // 如果无法获取元数据，直接保存图片
            try imageData.write(to: outputURL)
            return
        }
        
        // 通过闭包提供元数据
        let metadata = MorphoMetadataExtractor.extractMetadata(from: originalProperties, fileURL: originalURL)
        try metadataProvider(metadata)
        
        // 保存带元数据的图片
        try MorphoMetadataWriter.saveImageWithProperties(imageData: imageData, to: outputURL, properties: originalProperties)
    }
    
    // MARK: - 格式检查 API (静态方法，不涉及数据保留)
    
    /// 检查文件是否为RAW格式
    /// - Parameter url: 文件URL
    /// - Returns: 是否为RAW格式
    public static func isRAWFormat(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return MorphoRAWFormat.isRAWFormat(fileExtension)
    }
    
    /// 检查文件是否支持处理
    /// - Parameter url: 文件URL
    /// - Returns: 是否支持
    public func isSupported(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        let standardFormats = ["jpg", "jpeg", "png", "tiff", "tif", "heic", "heif", "bmp", "gif"]
        return standardFormats.contains(fileExtension) || MorphoRAWFormat.allExtensions.contains(fileExtension)
    }
    
    /// 获取支持的文件格式列表
    /// - Returns: 支持的格式扩展名数组
    public static func getSupportedFormats() -> [String] {
        let standardFormats = ["jpg", "jpeg", "png", "tiff", "tif", "heic", "heif", "bmp", "gif"]
        return standardFormats + MorphoRAWFormat.allExtensions
    }
    
    /// 获取支持的RAW格式列表
    /// - Returns: RAW格式扩展名数组
    public static func getSupportedRAWFormats() -> [String] {
        return MorphoRAWFormat.allExtensions
    }
} 
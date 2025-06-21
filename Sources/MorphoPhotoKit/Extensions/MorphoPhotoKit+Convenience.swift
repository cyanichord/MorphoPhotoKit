import Foundation
import CoreGraphics
import ImageIO

// MARK: - MorphoPhotoKit 便利方法扩展

public extension MorphoPhotoKit {
    
    // MARK: - 快速静态方法
    
    /// 快速提取图片元数据（静态方法）
    /// - Parameter url: 图片文件URL
    /// - Returns: 元数据
    /// - Throws: MorphoError 当提取失败时
    static func quickExtractMetadata(from url: URL) throws -> MorphoPhotoMetadata {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw MorphoError.invalidImageSource
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            throw MorphoError.metadataExtractionFailed
        }
        
        return MorphoMetadataExtractor.extractMetadata(from: properties, fileURL: url)
    }
    
    /// 快速检查文件格式支持（静态方法）
    /// - Parameter url: 文件URL
    /// - Returns: 格式支持信息
    static func checkFormatSupport(for url: URL) -> (isSupported: Bool, isRAW: Bool, brand: String?) {
        let fileExtension = url.pathExtension.lowercased()
        let standardFormats = ["jpg", "jpeg", "png", "tiff", "tif", "heic", "heif", "bmp", "gif"]
        
        let isSupported = standardFormats.contains(fileExtension) || MorphoRAWFormat.allExtensions.contains(fileExtension)
        let isRAW = MorphoRAWFormat.isRAWFormat(fileExtension)
        let brand = MorphoRAWFormat.getCameraBrand(from: fileExtension)
        
        return (isSupported, isRAW, brand)
    }
    
    // MARK: - 批量操作便利方法
    
    /// 批量检查文件格式
    /// - Parameter urls: 文件URL数组
    /// - Returns: 格式检查结果数组
    static func batchCheckFormats(for urls: [URL]) -> [(url: URL, isSupported: Bool, isRAW: Bool)] {
        return urls.map { url in
            let support = checkFormatSupport(for: url)
            return (url: url, isSupported: support.isSupported, isRAW: support.isRAW)
        }
    }
    
    /// 过滤支持的文件
    /// - Parameter urls: 文件URL数组
    /// - Returns: 支持的文件URL数组
    static func filterSupportedFiles(from urls: [URL]) -> [URL] {
        return urls.filter { url in
            let support = checkFormatSupport(for: url)
            return support.isSupported
        }
    }
    
    /// 过滤RAW文件
    /// - Parameter urls: 文件URL数组
    /// - Returns: RAW文件URL数组
    static func filterRAWFiles(from urls: [URL]) -> [URL] {
        return urls.filter { url in
            let support = checkFormatSupport(for: url)
            return support.isRAW
        }
    }
    
    // MARK: - 异步处理便利方法
    
    /// 异步处理图片
    /// - Parameter url: 图片文件URL
    /// - Returns: 处理结果
    func processImageAsync(from url: URL) async throws -> (MorphoPlatformImage, MorphoPhotoMetadata) {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try processImage(from: url) { image, metadata in
                    continuation.resume(returning: (image, metadata))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// 异步获取图片信息
    /// - Parameter url: 图片文件URL
    /// - Returns: 图片信息
    func getImageInfoAsync(from url: URL) async throws -> MorphoImageInfo {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try getImageInfo(from: url) { imageInfo in
                    continuation.resume(returning: imageInfo)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// 异步更新GPS信息
    /// - Parameters:
    ///   - url: 图片文件URL
    ///   - latitude: 纬度
    ///   - longitude: 经度
    ///   - altitude: 海拔（可选）
    /// - Returns: 原始元数据
    func updateGPSInfoAsync(
        at url: URL,
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil
    ) async throws -> MorphoPhotoMetadata {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try updateGPSInfo(at: url, latitude: latitude, longitude: longitude, altitude: altitude) { originalMetadata in
                    continuation.resume(returning: originalMetadata)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
} 
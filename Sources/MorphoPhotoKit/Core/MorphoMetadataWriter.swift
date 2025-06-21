import Foundation
import CoreGraphics
import ImageIO

// MARK: - Morpho 元数据写入器

/// Morpho 照片元数据写入器 - 负责保存图片时保留或更新EXIF和GPS信息
/// 使用静态方法确保不保留任何数据
public struct MorphoMetadataWriter {
    
    // MARK: - GPS属性创建
    
    /// 创建GPS属性字典
    /// - Parameter gpsMetadata: GPS元数据
    /// - Returns: GPS属性字典
    public static func createGPSProperties(from gpsMetadata: MorphoGPSMetadata) -> [CFString: Any] {
        var gpsDict: [CFString: Any] = [:]
        
        if let latitude = gpsMetadata.latitude, let latitudeRef = gpsMetadata.latitudeRef {
            gpsDict[kCGImagePropertyGPSLatitude] = NSNumber(value: abs(latitude))
            gpsDict[kCGImagePropertyGPSLatitudeRef] = latitudeRef
        }
        
        if let longitude = gpsMetadata.longitude, let longitudeRef = gpsMetadata.longitudeRef {
            gpsDict[kCGImagePropertyGPSLongitude] = NSNumber(value: abs(longitude))
            gpsDict[kCGImagePropertyGPSLongitudeRef] = longitudeRef
        }
        
        if let altitude = gpsMetadata.altitude, let altitudeRef = gpsMetadata.altitudeRef {
            gpsDict[kCGImagePropertyGPSAltitude] = NSNumber(value: abs(altitude))
            gpsDict[kCGImagePropertyGPSAltitudeRef] = NSNumber(value: altitudeRef)
        }
        
        if let timestamp = gpsMetadata.timestamp {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            formatter.dateFormat = "yyyy:MM:dd"
            gpsDict[kCGImagePropertyGPSDateStamp] = formatter.string(from: timestamp)
            
            formatter.dateFormat = "HH:mm:ss"
            gpsDict[kCGImagePropertyGPSTimeStamp] = formatter.string(from: timestamp)
        }
        
        return gpsDict
    }
    
    // MARK: - EXIF属性创建和合并
    
    /// 创建EXIF属性字典
    /// - Parameter exifMetadata: EXIF元数据
    /// - Returns: EXIF属性字典
    public static func createExifProperties(from exifMetadata: MorphoExifMetadata) -> [CFString: Any] {
        var exifDict: [CFString: Any] = [:]
        
        if !exifMetadata.iso.isEmpty {
            exifDict[kCGImagePropertyExifISOSpeedRatings] = [NSNumber(value: Int(exifMetadata.iso) ?? 0)]
        }
        
        if !exifMetadata.fNumber.isEmpty {
            let fNumber = exifMetadata.fNumber.replacingOccurrences(of: "f/", with: "")
            if let value = Float(fNumber) {
                exifDict[kCGImagePropertyExifFNumber] = NSNumber(value: value)
            }
        }
        
        if !exifMetadata.exposureTime.isEmpty {
            if let exposureValue = parseExposureTime(exifMetadata.exposureTime) {
                exifDict[kCGImagePropertyExifExposureTime] = NSNumber(value: exposureValue)
            }
        }
        
        if !exifMetadata.focalLength.isEmpty {
            let focalLength = exifMetadata.focalLength.replacingOccurrences(of: "mm", with: "")
            if let value = Float(focalLength) {
                exifDict[kCGImagePropertyExifFocalLength] = NSNumber(value: value)
            }
        }
        
        if let dateTime = exifMetadata.dateTimeOriginal {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            exifDict[kCGImagePropertyExifDateTimeOriginal] = formatter.string(from: dateTime)
        }
        
        return exifDict
    }
    
    /// 合并EXIF数据
    /// - Parameters:
    ///   - originalExif: 原始EXIF字典
    ///   - exifMetadata: 新的EXIF元数据
    /// - Returns: 合并后的EXIF字典
    public static func mergeExifData(
        _ originalExif: [CFString: Any],
        with exifMetadata: MorphoExifMetadata
    ) -> [CFString: Any] {
        
        var mergedExif = originalExif
        
        if !exifMetadata.iso.isEmpty {
            mergedExif[kCGImagePropertyExifISOSpeedRatings] = [NSNumber(value: Int(exifMetadata.iso) ?? 0)]
        }
        
        if !exifMetadata.fNumber.isEmpty {
            let fNumber = exifMetadata.fNumber.replacingOccurrences(of: "f/", with: "")
            if let value = Float(fNumber) {
                mergedExif[kCGImagePropertyExifFNumber] = NSNumber(value: value)
            }
        }
        
        if !exifMetadata.exposureTime.isEmpty {
            if let exposureValue = parseExposureTime(exifMetadata.exposureTime) {
                mergedExif[kCGImagePropertyExifExposureTime] = NSNumber(value: exposureValue)
            }
        }
        
        if let dateTime = exifMetadata.dateTimeOriginal {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            mergedExif[kCGImagePropertyExifDateTimeOriginal] = formatter.string(from: dateTime)
        }
        
        return mergedExif
    }
    
    // MARK: - 属性字典创建
    
    /// 从元数据创建完整的属性字典
    /// - Parameter metadata: 元数据
    /// - Returns: 属性字典
    public static func createPropertiesFromMetadata(_ metadata: MorphoPhotoMetadata) -> [CFString: Any] {
        var properties: [CFString: Any] = [:]
        
        // 添加基本图片信息
        if metadata.imageSize != .zero {
            properties[kCGImagePropertyPixelWidth] = NSNumber(value: Int(metadata.imageSize.width))
            properties[kCGImagePropertyPixelHeight] = NSNumber(value: Int(metadata.imageSize.height))
        }
        
        if metadata.orientation != 1 {
            properties[kCGImagePropertyOrientation] = NSNumber(value: metadata.orientation)
        }
        
        // 添加EXIF信息
        if metadata.exif.hasBasicInfo {
            properties[kCGImagePropertyExifDictionary] = createExifProperties(from: metadata.exif)
        }
        
        // 添加GPS信息
        if metadata.gps.hasValidCoordinates {
            properties[kCGImagePropertyGPSDictionary] = createGPSProperties(from: metadata.gps)
        }
        
        return properties
    }
    
    // MARK: - 图片保存
    
    /// 保存带属性的图片
    /// - Parameters:
    ///   - imageData: 图片数据
    ///   - url: 保存URL
    ///   - properties: 图片属性
    /// - Throws: MorphoError 当保存失败时
    public static func saveImageWithProperties(
        imageData: Data,
        to url: URL,
        properties: [CFString: Any]
    ) throws {
        
        // 创建图片源
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw MorphoError.invalidImageData
        }
        
        // 确定输出格式
        let outputFormat = determineOutputFormat(from: url)
        
        // 创建图片目标
        guard let imageDestination = CGImageDestinationCreateWithURL(
            url as CFURL,
            outputFormat.identifier as CFString,
            1,
            nil
        ) else {
            throw MorphoError.imageSaveFailed("无法创建图片目标")
        }
        
        // 添加图片和属性
        CGImageDestinationAddImage(imageDestination, cgImage, properties as CFDictionary)
        
        // 完成保存
        guard CGImageDestinationFinalize(imageDestination) else {
            throw MorphoError.imageSaveFailed("图片保存失败")
        }
    }
    
    // MARK: - 辅助方法
    
    /// 解析快门速度字符串
    /// - Parameter exposureTime: 快门速度字符串
    /// - Returns: 快门速度数值
    private static func parseExposureTime(_ exposureTime: String) -> Double? {
        if exposureTime.contains("/") {
            let components = exposureTime.components(separatedBy: "/")
            if components.count == 2,
               let numerator = Double(components[0]),
               let denominator = Double(components[1]) {
                return numerator / denominator
            }
        } else if exposureTime.hasSuffix("s") {
            let timeString = String(exposureTime.dropLast())
            return Double(timeString)
        }
        return Double(exposureTime)
    }
    
    /// 确定输出格式
    /// - Parameter url: 文件URL
    /// - Returns: 输出格式
    private static func determineOutputFormat(from url: URL) -> OutputFormat {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "jpg", "jpeg":
            return OutputFormat(identifier: "public.jpeg")
        case "png":
            return OutputFormat(identifier: "public.png")
        case "tiff", "tif":
            return OutputFormat(identifier: "public.tiff")
        case "heic":
            return OutputFormat(identifier: "public.heic")
        case "heif":
            return OutputFormat(identifier: "public.heif")
        default:
            return OutputFormat(identifier: "public.jpeg") // 默认为JPEG
        }
    }
} 
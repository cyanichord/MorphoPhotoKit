import Foundation
import CoreGraphics
import ImageIO

// MARK: - Morpho 元数据提取器

/// Morpho 照片元数据提取器 - 负责从图片属性中提取EXIF和GPS信息

public struct MorphoMetadataExtractor {
    
    // MARK: - 主要提取方法
    
    /// 从属性字典中提取元数据 - 静态方法，立即转换
    /// - Parameters:
    ///   - properties: 图片属性字典
    ///   - fileURL: 文件URL（可选）
    /// - Returns: 提取的元数据
    public static func extractMetadata(from properties: [CFString: Any], fileURL: URL?) -> MorphoPhotoMetadata {
        var metadata = MorphoPhotoMetadata()
        
        // 提取基本图片信息
        extractBasicImageInfo(from: properties, into: &metadata)
        
        // 提取EXIF信息
        if let exifDict = properties[kCGImagePropertyExifDictionary] as? [CFString: Any] {
            metadata.exif = extractExifFromProperties(exifDict)
        }
        
        // 提取GPS信息
        if let gpsDict = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] {
            metadata.gps = extractGPSFromProperties(gpsDict)
        }
        
        // 设置文件信息
        if let url = fileURL {
            setFileInfo(from: url, into: &metadata)
        }
        
        return metadata
    }
    
    // MARK: - 基本信息提取
    
    /// 提取基本图片信息
    /// - Parameters:
    ///   - properties: 图片属性字典
    ///   - metadata: 元数据对象（引用传递）
    private static func extractBasicImageInfo(from properties: [CFString: Any], into metadata: inout MorphoPhotoMetadata) {
        // 图片尺寸
        if let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
           let height = properties[kCGImagePropertyPixelHeight] as? NSNumber {
            metadata.imageSize = CGSize(width: width.doubleValue, height: height.doubleValue)
        }
        
        // 图片方向
        if let orientation = properties[kCGImagePropertyOrientation] as? NSNumber {
            metadata.orientation = orientation.intValue
        }
        
        // 色彩空间
        if let colorModel = properties[kCGImagePropertyColorModel] as? String {
            metadata.colorSpace = colorModel
        }
    }
    
    /// 设置文件信息
    /// - Parameters:
    ///   - url: 文件URL
    ///   - metadata: 元数据对象（引用传递）
    private static func setFileInfo(from url: URL, into metadata: inout MorphoPhotoMetadata) {
        metadata.fileFormat = url.pathExtension.uppercased()
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSizeNumber = fileAttributes[.size] as? NSNumber {
                metadata.fileSize = fileSizeNumber.int64Value
            }
        } catch {
            // 忽略文件大小获取错误
        }
    }
    
    // MARK: - EXIF信息提取
    
    /// 从EXIF属性字典中提取EXIF元数据
    /// - Parameter exifDict: EXIF属性字典
    /// - Returns: EXIF元数据
    public static func extractExifFromProperties(_ exifDict: [CFString: Any]) -> MorphoExifMetadata {
        var exif = MorphoExifMetadata()
        
        // ISO感光度
        if let isoArray = exifDict[kCGImagePropertyExifISOSpeedRatings] as? [NSNumber],
           let iso = isoArray.first {
            exif.iso = String(iso.intValue)
        }
        
        // 光圈值
        if let fNumber = exifDict[kCGImagePropertyExifFNumber] as? NSNumber {
            exif.fNumber = String(format: "%.1f", fNumber.floatValue)
        }
        
        // 快门速度
        if let exposureTime = exifDict[kCGImagePropertyExifExposureTime] as? NSNumber {
            let exposure = exposureTime.doubleValue
            if exposure >= 1 {
                exif.exposureTime = String(format: "%.1fs", exposure)
            } else {
                exif.exposureTime = String(format: "1/%.0fs", 1.0 / exposure)
            }
        }
        
        // 焦距
        if let focalLength = exifDict[kCGImagePropertyExifFocalLength] as? NSNumber {
            exif.focalLength = String(format: "%.1f", focalLength.floatValue)
        }
        
        // 拍摄时间
        if let dateTimeString = exifDict[kCGImagePropertyExifDateTimeOriginal] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            exif.dateTimeOriginal = formatter.date(from: dateTimeString)
        }
        
        // 相机制造商
        if let cameraMake = exifDict[kCGImagePropertyExifMakerNote] as? String {
            exif.cameraMake = cameraMake
        }
        
        // 相机型号
        if let cameraModel = exifDict[kCGImagePropertyExifCameraOwnerName] as? String {
            exif.cameraModel = cameraModel
        }
        
        // 镜头型号
        if let lensModel = exifDict[kCGImagePropertyExifLensModel] as? String {
            exif.lensModel = lensModel
        }
        
        return exif
    }
    
    // MARK: - GPS信息提取
    
    /// 从GPS属性字典中提取GPS元数据
    /// - Parameter gpsDict: GPS属性字典
    /// - Returns: GPS元数据
    public static func extractGPSFromProperties(_ gpsDict: [CFString: Any]) -> MorphoGPSMetadata {
        var gps = MorphoGPSMetadata()
        
        // 纬度
        if let latitude = gpsDict[kCGImagePropertyGPSLatitude] as? NSNumber,
           let latitudeRef = gpsDict[kCGImagePropertyGPSLatitudeRef] as? String {
            let lat = latitude.doubleValue
            gps.latitude = latitudeRef == "N" ? lat : -lat
            gps.latitudeRef = latitudeRef
        }
        
        // 经度
        if let longitude = gpsDict[kCGImagePropertyGPSLongitude] as? NSNumber,
           let longitudeRef = gpsDict[kCGImagePropertyGPSLongitudeRef] as? String {
            let lon = longitude.doubleValue
            gps.longitude = longitudeRef == "E" ? lon : -lon
            gps.longitudeRef = longitudeRef
        }
        
        // 海拔
        if let altitude = gpsDict[kCGImagePropertyGPSAltitude] as? NSNumber,
           let altitudeRef = gpsDict[kCGImagePropertyGPSAltitudeRef] as? NSNumber {
            let alt = altitude.doubleValue
            gps.altitude = altitudeRef.intValue == 0 ? alt : -alt
            gps.altitudeRef = altitudeRef.intValue
        }
        
        // GPS时间戳
        if let dateStamp = gpsDict[kCGImagePropertyGPSDateStamp] as? String,
           let timeStamp = gpsDict[kCGImagePropertyGPSTimeStamp] as? String {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            let dateTimeString = "\(dateStamp) \(timeStamp)"
            gps.timestamp = formatter.date(from: dateTimeString)
        }
        
        // GPS处理方法
        if gpsDict[kCGImagePropertyGPSProcessingMethod] != nil {
            // 处理GPS处理方法信息（如果需要的话）
        }
        
        return gps
    }
} 
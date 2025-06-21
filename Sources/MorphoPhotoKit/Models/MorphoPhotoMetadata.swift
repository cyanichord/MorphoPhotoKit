import Foundation

// MARK: - 照片元数据模型

/// Morpho EXIF元数据信息
public struct MorphoExifMetadata: Codable, Equatable {
    /// ISO感光度
    public var iso: String = ""
    /// 光圈值 (f/2.8)
    public var fNumber: String = ""
    /// 快门速度 (1/60s)
    public var exposureTime: String = ""
    /// 相机制造商
    public var cameraMake: String = ""
    /// 相机型号
    public var cameraModel: String = ""
    /// 镜头型号
    public var lensModel: String = ""
    /// 焦距
    public var focalLength: String = ""
    /// 拍摄日期
    public var dateTimeOriginal: Date?
    
    public init() {}
    
    /// 检查是否包含基本EXIF信息
    public var hasBasicInfo: Bool {
        return !iso.isEmpty && !fNumber.isEmpty && !exposureTime.isEmpty
    }
}

/// Morpho GPS地理信息
public struct MorphoGPSMetadata: Codable, Equatable {
    /// 纬度
    public var latitude: Double?
    /// 纬度参考 (N/S)
    public var latitudeRef: String?
    /// 经度
    public var longitude: Double?
    /// 经度参考 (E/W)
    public var longitudeRef: String?
    /// 海拔高度
    public var altitude: Double?
    /// 海拔参考 (0=海平面以上, 1=海平面以下)
    public var altitudeRef: Int?
    /// GPS时间戳
    public var timestamp: Date?
    
    public init() {}
    
    /// 检查是否包含有效的GPS坐标
    public var hasValidCoordinates: Bool {
        return latitude != nil && longitude != nil && 
               latitudeRef != nil && longitudeRef != nil
    }
    
    /// 获取格式化的坐标字符串
    public var coordinateString: String? {
        guard hasValidCoordinates,
              let lat = latitude, let latRef = latitudeRef,
              let lon = longitude, let lonRef = longitudeRef else {
            return nil
        }
        
        return String(format: "%.6f°%@, %.6f°%@", abs(lat), latRef, abs(lon), lonRef)
    }
}

/// Morpho 完整的照片元数据
public struct MorphoPhotoMetadata: Codable, Equatable {
    /// EXIF信息
    public var exif: MorphoExifMetadata = MorphoExifMetadata()
    /// GPS信息
    public var gps: MorphoGPSMetadata = MorphoGPSMetadata()
    /// 图片尺寸
    public var imageSize: CGSize = .zero
    /// 文件大小 (字节)
    public var fileSize: Int64 = 0
    /// 文件格式
    public var fileFormat: String = ""
    /// 色彩空间
    public var colorSpace: String = ""
    /// 图片方向
    public var orientation: Int = 1
    
    public init() {}
    
    /// 检查是否包含任何有效元数据
    public var hasMetadata: Bool {
        return exif.hasBasicInfo || gps.hasValidCoordinates
    }
}

 
import Foundation

// MARK: - 错误类型

/// MorphoPhotoKit 错误类型
public enum MorphoError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidImageSource
    case invalidImageData
    case imageDecodingFailed
    case metadataExtractionFailed
    case fileAccessFailed(String)
    case unsupportedFormat(String)
    case imageSaveFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "文件不存在: \(path)"
        case .invalidImageSource:
            return "无效的图像源"
        case .invalidImageData:
            return "无效的图像数据"
        case .imageDecodingFailed:
            return "图像解码失败"
        case .metadataExtractionFailed:
            return "元数据提取失败"
        case .fileAccessFailed(let message):
            return "文件访问失败: \(message)"
        case .unsupportedFormat(let format):
            return "不支持的格式: \(format)"
        case .imageSaveFailed(let message):
            return "图像保存失败: \(message)"
        }
    }
}

// MARK: - 数据结构

/// Morpho 图片信息
public struct MorphoImageInfo {
    /// 文件URL
    public let fileURL: URL
    /// 图片尺寸
    public let imageSize: CGSize
    /// 文件大小
    public let fileSize: Int64
    /// 是否为RAW格式
    public let isRAWFormat: Bool
    /// 元数据
    public let metadata: MorphoPhotoMetadata
    
    public init(fileURL: URL, imageSize: CGSize, fileSize: Int64, isRAWFormat: Bool, metadata: MorphoPhotoMetadata) {
        self.fileURL = fileURL
        self.imageSize = imageSize
        self.fileSize = fileSize
        self.isRAWFormat = isRAWFormat
        self.metadata = metadata
    }
    
    /// 格式化的文件大小字符串
    public var fileSizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

/// 输出格式
public struct OutputFormat {
    public let identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
    }
} 
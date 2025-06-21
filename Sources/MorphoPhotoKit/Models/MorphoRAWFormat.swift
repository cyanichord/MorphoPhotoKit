import Foundation

// MARK: - RAW格式支持

/// MorphoPhotoKit 支持的RAW格式定义
public struct MorphoRAWFormat {
    
    // MARK: - 支持的RAW格式扩展名
    
    /// 所有支持的RAW格式扩展名
    public static let allExtensions: [String] = [
        // Canon
        "cr2", "cr3", "crw",
        
        // Nikon
        "nef", "nrw",
        
        // Sony
        "arw", "srf", "sr2",
        
        // Fujifilm
        "raf",
        
        // Olympus
        "orf",
        
        // Panasonic
        "rw2", "raw",
        
        // Leica
        "dng", "rwl",
        
        // Pentax
        "pef", "ptx",
        
        // Samsung
        "srw",
        
        // Kodak
        "dcr", "kdc",
        
        // Minolta
        "mrw",
        
        // Sigma
        "x3f",
        
        // Hasselblad
        "3fr",
        
        // Mamiya
        "mef",
        
        // Phase One
        "iiq",
        
        // Red
        "r3d",
        
        // Adobe DNG
        "dng"
    ]
    
    // MARK: - 按品牌分类的格式
    
    /// Canon RAW格式
    public static let canonFormats = ["cr2", "cr3", "crw"]
    
    /// Nikon RAW格式
    public static let nikonFormats = ["nef", "nrw"]
    
    /// Sony RAW格式
    public static let sonyFormats = ["arw", "srf", "sr2"]
    
    /// Fujifilm RAW格式
    public static let fujiFormats = ["raf"]
    
    /// Olympus RAW格式
    public static let olympusFormats = ["orf"]
    
    /// Panasonic RAW格式
    public static let panasonicFormats = ["rw2", "raw"]
    
    /// Leica RAW格式
    public static let leicaFormats = ["dng", "rwl"]
    
    /// Pentax RAW格式
    public static let pentaxFormats = ["pef", "ptx"]
    
    /// Samsung RAW格式
    public static let samsungFormats = ["srw"]
    
    /// 其他专业格式
    public static let professionalFormats = ["3fr", "mef", "iiq", "r3d", "x3f", "dcr", "kdc", "mrw"]
    
    // MARK: - 格式检查方法
    
    /// 检查文件扩展名是否为RAW格式
    /// - Parameter extension: 文件扩展名
    /// - Returns: 是否为RAW格式
    public static func isRAWFormat(_ extension: String) -> Bool {
        let lowercased = `extension`.lowercased()
        return allExtensions.contains(lowercased)
    }
    
    /// 根据扩展名获取相机品牌
    /// - Parameter extension: 文件扩展名
    /// - Returns: 相机品牌名称（如果识别的话）
    public static func getCameraBrand(from extension: String) -> String? {
        let lowercased = `extension`.lowercased()
        
        if canonFormats.contains(lowercased) {
            return "Canon"
        } else if nikonFormats.contains(lowercased) {
            return "Nikon"
        } else if sonyFormats.contains(lowercased) {
            return "Sony"
        } else if fujiFormats.contains(lowercased) {
            return "Fujifilm"
        } else if olympusFormats.contains(lowercased) {
            return "Olympus"
        } else if panasonicFormats.contains(lowercased) {
            return "Panasonic"
        } else if leicaFormats.contains(lowercased) {
            return "Leica"
        } else if pentaxFormats.contains(lowercased) {
            return "Pentax"
        } else if samsungFormats.contains(lowercased) {
            return "Samsung"
        } else if professionalFormats.contains(lowercased) {
            return "Professional"
        }
        
        return nil
    }
    
    /// 检查是否为通用DNG格式
    /// - Parameter extension: 文件扩展名
    /// - Returns: 是否为DNG格式
    public static func isDNGFormat(_ extension: String) -> Bool {
        return `extension`.lowercased() == "dng"
    }
    
    /// 获取格式描述
    /// - Parameter extension: 文件扩展名
    /// - Returns: 格式描述
    public static func getFormatDescription(_ extension: String) -> String {
        let lowercased = `extension`.lowercased()
        
        switch lowercased {
        case "cr2":
            return "Canon Raw Version 2"
        case "cr3":
            return "Canon Raw Version 3"
        case "crw":
            return "Canon Raw"
        case "nef":
            return "Nikon Electronic Format"
        case "nrw":
            return "Nikon Raw"
        case "arw":
            return "Sony Alpha Raw"
        case "srf", "sr2":
            return "Sony Raw Format"
        case "raf":
            return "Fuji Raw Format"
        case "orf":
            return "Olympus Raw Format"
        case "rw2":
            return "Panasonic Raw"
        case "raw":
            return "Generic Raw"
        case "dng":
            return "Adobe Digital Negative"
        case "pef":
            return "Pentax Electronic Format"
        case "ptx":
            return "Pentax Raw"
        case "srw":
            return "Samsung Raw"
        case "3fr":
            return "Hasselblad 3F Raw"
        case "mef":
            return "Mamiya Electronic Format"
        case "iiq":
            return "Phase One Intelligent Image Quality"
        case "r3d":
            return "Red Raw"
        case "x3f":
            return "Sigma X3F Raw"
        case "dcr", "kdc":
            return "Kodak Raw"
        case "mrw":
            return "Minolta Raw"
        default:
            return "Raw Format"
        }
    }
} 
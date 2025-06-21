import Foundation
import CoreGraphics

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// MARK: - Morpho 图片处理器

/// Morpho 图片处理器 - 负责图片格式标准化和GPU兼容性处理
public struct MorphoImageProcessor {
    
    // MARK: - 图片标准化
    
    /// 标准化图像格式以确保GPU兼容性
    /// - Parameters:
    ///   - cgImage: 原始CGImage
    ///   - targetColorSpace: 目标色彩空间（可选，默认保持原有色彩空间）
    /// - Returns: 标准化后的CGImage
    public static func standardizeImageForGPU(
        _ cgImage: CGImage,
        targetColorSpace: CGColorSpace? = nil
    ) -> CGImage {
        let width = cgImage.width
        let height = cgImage.height
        
        // 确定使用的色彩空间
        let colorSpace: CGColorSpace
        if let targetColorSpace = targetColorSpace {
            colorSpace = targetColorSpace
        } else if let originalColorSpace = cgImage.colorSpace {
            colorSpace = originalColorSpace
        } else {
            // 如果原图没有色彩空间信息，使用sRGB作为默认值
            guard let sRGBColorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                return cgImage
            }
            colorSpace = sRGBColorSpace
        }
        
        // 创建位图上下文
        let bitsPerComponent = 8
        let bytesPerRow = width * 4 // RGBA
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return cgImage
        }
        
        // 配置上下文
        context.interpolationQuality = .high
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        // 绘制图像
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 从上下文创建新的CGImage
        guard let standardizedImage = context.makeImage() else {
            return cgImage
        }
        
        return standardizedImage
    }
    
    // MARK: - 色彩空间便利方法
    
    /// 获取常用色彩空间
    public enum ColorSpaceType {
        case sRGB
        case adobeRGB
        case displayP3
        case rec2020
        case genericRGB
        
        /// 获取对应的CGColorSpace
        public var cgColorSpace: CGColorSpace? {
            switch self {
            case .sRGB:
                return CGColorSpace(name: CGColorSpace.sRGB)
            case .adobeRGB:
                return CGColorSpace(name: CGColorSpace.adobeRGB1998)
            case .displayP3:
                return CGColorSpace(name: CGColorSpace.displayP3)
            case .rec2020:
                return CGColorSpace(name: CGColorSpace.itur_2020)
            case .genericRGB:
                return CGColorSpace(name: CGColorSpace.genericRGBLinear)
            }
        }
    }
    
    /// 使用预定义色彩空间标准化图像
    /// - Parameters:
    ///   - cgImage: 原始CGImage
    ///   - colorSpaceType: 目标色彩空间类型
    /// - Returns: 标准化后的CGImage
    public static func standardizeImageForGPU(
        _ cgImage: CGImage,
        colorSpaceType: ColorSpaceType
    ) -> CGImage {
        guard let targetColorSpace = colorSpaceType.cgColorSpace else {
            return cgImage
        }
        return standardizeImageForGPU(cgImage, targetColorSpace: targetColorSpace)
    }
} 
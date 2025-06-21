# MorphoPhotoKit API 使用文档

## 初始化方法

### 创建MorphoPhotoKit实例
```swift
let morphoKit = MorphoPhotoKit()
```

## 图片处理功能

### 1. 处理图片文件
```swift
func processImage(from url: URL, completion: (MorphoPlatformImage, MorphoPhotoMetadata) throws -> Void) throws
```
- 参数：
  - url: 图片文件URL
  - completion: 处理完成回调，包含图片和元数据
- 返回值：通过闭包返回处理后的图片和元数据
- 抛出异常：MorphoError

### 2. 获取图片信息
```swift
func getImageInfo(from url: URL, completion: (MorphoImageInfo) throws -> Void) throws
```
- 参数：
  - url: 图片文件URL
  - completion: 完成回调，包含图片信息
- 返回值：通过闭包返回图片信息
- 抛出异常：MorphoError

### 3. 批量处理图片
```swift
func processImages(from urls: [URL], itemProcessor: (URL, Result<(MorphoPlatformImage, MorphoPhotoMetadata), MorphoError>) -> Void, completion: () -> Void)
```
- 参数：
  - urls: 图片文件URL数组
  - itemProcessor: 单个项目处理回调
  - completion: 完成回调
- 返回值：通过闭包逐个返回处理结果

## 元数据操作功能

### 1. 更新GPS信息
```swift
func updateGPSInfo(at url: URL, latitude: Double, longitude: Double, altitude: Double? = nil, backupHandler: (MorphoPhotoMetadata) -> Void) throws
```
- 参数：
  - url: 图片文件URL
  - latitude: 纬度
  - longitude: 经度
  - altitude: 海拔（可选）
  - backupHandler: 备份处理回调，接收原始元数据
- 返回值：通过闭包返回原始元数据用于备份
- 抛出异常：MorphoError

### 2. 更新EXIF信息
```swift
func updateExifInfo(at url: URL, with exifMetadata: MorphoExifMetadata, backupHandler: (MorphoPhotoMetadata) -> Void) throws
```
- 参数：
  - url: 图片文件URL
  - exifMetadata: EXIF元数据
  - backupHandler: 备份处理回调，接收原始元数据
- 返回值：通过闭包返回原始元数据用于备份
- 抛出异常：MorphoError

### 3. 恢复原始元数据
```swift
func restoreOriginalMetadata(at url: URL, with originalMetadata: MorphoPhotoMetadata) throws
```
- 参数：
  - url: 图片文件URL
  - originalMetadata: 要恢复的原始元数据
- 返回值：无
- 抛出异常：MorphoError

## 图片保存功能

### 保存处理后的图片并保留元数据
```swift
func saveProcessedImage(imageData: Data, to outputURL: URL, originalURL: URL, metadataProvider: (MorphoPhotoMetadata) throws -> Void) throws
```
- 参数：
  - imageData: 处理后的图片数据
  - outputURL: 输出文件URL
  - originalURL: 原始文件URL
  - metadataProvider: 元数据提供回调
- 返回值：通过闭包提供元数据
- 抛出异常：MorphoError

## 格式检查功能（静态方法）

### 1. 检查文件是否为RAW格式
```swift
static func isRAWFormat(_ url: URL) -> Bool
```
- 参数：url: 文件URL
- 返回值：Bool - 是否为RAW格式

### 2. 检查文件是否支持处理
```swift
func isSupported(_ url: URL) -> Bool
```
- 参数：url: 文件URL
- 返回值：Bool - 是否支持

### 3. 获取支持的文件格式列表
```swift
static func getSupportedFormats() -> [String]
```
- 参数：无
- 返回值：[String] - 支持的格式扩展名数组

### 4. 获取支持的RAW格式列表
```swift
static func getSupportedRAWFormats() -> [String]
```
- 参数：无
- 返回值：[String] - RAW格式扩展名数组

## 便利方法（扩展）

### 1. 快速提取图片元数据
```swift
static func quickExtractMetadata(from url: URL) throws -> MorphoPhotoMetadata
```
- 参数：url: 图片文件URL
- 返回值：MorphoPhotoMetadata - 元数据
- 抛出异常：MorphoError

### 2. 快速检查文件格式支持
```swift
static func checkFormatSupport(for url: URL) -> (isSupported: Bool, isRAW: Bool, brand: String?)
```
- 参数：url: 文件URL
- 返回值：元组 - (是否支持, 是否RAW, 相机品牌)

### 3. 批量检查文件格式
```swift
static func batchCheckFormats(for urls: [URL]) -> [(url: URL, isSupported: Bool, isRAW: Bool)]
```
- 参数：urls: 文件URL数组
- 返回值：格式检查结果数组

### 4. 过滤支持的文件
```swift
static func filterSupportedFiles(from urls: [URL]) -> [URL]
```
- 参数：urls: 文件URL数组
- 返回值：[URL] - 支持的文件URL数组

### 5. 过滤RAW文件
```swift
static func filterRAWFiles(from urls: [URL]) -> [URL]
```
- 参数：urls: 文件URL数组
- 返回值：[URL] - RAW文件URL数组

## 异步方法

### 1. 异步处理图片
```swift
func processImageAsync(from url: URL) async throws -> (MorphoPlatformImage, MorphoPhotoMetadata)
```
- 参数：url: 图片文件URL
- 返回值：元组 - (图片, 元数据)
- 抛出异常：MorphoError

### 2. 异步获取图片信息
```swift
func getImageInfoAsync(from url: URL) async throws -> MorphoImageInfo
```
- 参数：url: 图片文件URL
- 返回值：MorphoImageInfo - 图片信息
- 抛出异常：MorphoError

### 3. 异步更新GPS信息
```swift
func updateGPSInfoAsync(at url: URL, latitude: Double, longitude: Double, altitude: Double? = nil) async throws -> MorphoPhotoMetadata
```
- 参数：
  - url: 图片文件URL
  - latitude: 纬度
  - longitude: 经度
  - altitude: 海拔（可选）
- 返回值：MorphoPhotoMetadata - 原始元数据
- 抛出异常：MorphoError

## 图像处理工具（静态方法）

### 标准化图像格式以确保GPU兼容性
```swift
static func standardizeImageForGPU(_ cgImage: CGImage, targetColorSpace: CGColorSpace? = nil) -> CGImage
```
- 参数：
  - cgImage: 原始CGImage
  - targetColorSpace: 目标色彩空间（可选）
- 返回值：CGImage - 标准化后的CGImage

### 使用预定义色彩空间标准化图像
```swift
static func standardizeImageForGPU(_ cgImage: CGImage, colorSpaceType: ColorSpaceType) -> CGImage
```
- 参数：
  - cgImage: 原始CGImage
  - colorSpaceType: 目标色彩空间类型
- 返回值：CGImage - 标准化后的CGImage

## 数据模型

### MorphoPhotoMetadata
包含完整的照片元数据：
- exif: MorphoExifMetadata - EXIF信息
- gps: MorphoGPSMetadata - GPS信息
- imageSize: CGSize - 图片尺寸
- fileSize: Int64 - 文件大小
- fileFormat: String - 文件格式
- colorSpace: String - 色彩空间
- orientation: Int - 图片方向

### MorphoExifMetadata
包含EXIF元数据：
- iso: String - ISO感光度
- fNumber: String - 光圈值
- exposureTime: String - 快门速度
- cameraMake: String - 相机制造商
- cameraModel: String - 相机型号
- lensModel: String - 镜头型号
- focalLength: String - 焦距
- dateTimeOriginal: Date? - 拍摄日期

### MorphoGPSMetadata
包含GPS地理信息：
- latitude: Double? - 纬度
- latitudeRef: String? - 纬度参考
- longitude: Double? - 经度
- longitudeRef: String? - 经度参考
- altitude: Double? - 海拔高度
- altitudeRef: Int? - 海拔参考
- timestamp: Date? - GPS时间戳

### MorphoImageInfo
包含图片信息：
- fileURL: URL - 文件URL
- imageSize: CGSize - 图片尺寸
- fileSize: Int64 - 文件大小
- isRAWFormat: Bool - 是否为RAW格式
- metadata: MorphoPhotoMetadata - 元数据

## 错误类型

### MorphoError
- fileNotFound(String) - 文件不存在
- invalidImageSource - 无效的图像源
- invalidImageData - 无效的图像数据
- imageDecodingFailed - 图像解码失败
- metadataExtractionFailed - 元数据提取失败
- fileAccessFailed(String) - 文件访问失败
- unsupportedFormat(String) - 不支持的格式
- imageSaveFailed(String) - 图像保存失败

## 支持的文件格式

### 标准格式
jpg, jpeg, png, tiff, tif, heic, heif, bmp, gif

### RAW格式
Canon: cr2, cr3, crw
Nikon: nef, nrw
Sony: arw, srf, sr2
Fujifilm: raf
Olympus: orf
Panasonic: rw2, raw
Leica: dng, rwl
Pentax: pef, ptx
Samsung: srw
其他专业格式: 3fr, mef, iiq, r3d, x3f, dcr, kdc, mrw 
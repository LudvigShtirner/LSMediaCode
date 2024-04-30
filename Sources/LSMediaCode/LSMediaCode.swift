public struct LSMediaCode {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public static var assetImageExtractor: AssetImageExtractor {
        AssetImageExtractorBase(thumbnailExtractor: thumbnailExtractor)
    }
    
    public static var thumbnailExtractor: ThumbnailExtractor {
        ThumbnailExtractorBase(imageManager: .default())
    }
    
    public static var videoCreator: VideoCreator {
        VideoCreatorBase(fileManager: .default)
    }
    
    public static var assetExtractor: AssetExtractor {
        AssetExtractorBase(imageManager: .default())
    }
    
    public static var assetExporter: AssetExporter {
        AssetExporterBase()
    }
}

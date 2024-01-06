public struct LSMediaCode {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public static func buildAssetImageExtractor() -> AssetImageExtractor {
        return AssetImageExtractorBase()
    }
}

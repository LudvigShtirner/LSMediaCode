//
//  AssetImageExtractOperation.swift
//
//
//  Created by Алексей Филиппов on 16.12.2023.
//

// SPM
import SupportCode
// Apple
import Photos
import class UIKit.UIImage

/// Операция по извлечению изображения из ассета галереи
final class AssetImageExtractOperation: AsyncOperation {
    // MARK: - Data
    private let thumbnailExtractor: ThumbnailExtractor
    private let localIdentifier: String
    private let requestedSize: CGSize
    private let finishBlock: OptImageBlock
    
    private var identifier: PHImageRequestID?
    
    // MARK: - Life cycle
    init(thumbnailExtractor: ThumbnailExtractor,
         localIdentifier: String,
         requestedSize: CGSize,
         finishBlock: @escaping OptImageBlock) {
        self.thumbnailExtractor = thumbnailExtractor
        self.localIdentifier = localIdentifier
        self.requestedSize = requestedSize
        self.finishBlock = finishBlock
    }
    
    // MARK: - Override
    override func main() {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier],
                                              options: nil)
        if fetchResult.countOfAssets(with: .image) == 0 {
            finishBlock(nil)
            completeOperation()
            return
        }
        let phAsset = fetchResult[0]
        
        identifier = thumbnailExtractor.extractThumbnail(forAsset: phAsset,
                                                         thumbnailSize: requestedSize,
                                                         contentMode: .aspectFit,
                                                         completionBlock: { [weak self] result in
            guard let self else { return }
            if self.isCancelled {
                self.completeOperation()
                return
            }
            if self.isFinished {
                return
            }
            guard let isDegraded = result?.isDegraded else {
                return
            }
            if !isDegraded {
                self.finishBlock(result?.image)
                self.completeOperation()
            }
        })
    }
    
    override func cancel() {
        guard let identifier else { return }
        thumbnailExtractor.cancelThumbnailExtraction(imageRequestID: identifier)
    }
}

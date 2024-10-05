//
//  ThumbnailExtractorBase.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import UIKit
import Photos

final class ThumbnailExtractorBase: ThumbnailExtractor {
    // MARK: - Dependencies
    private let imageManager: PHImageManager
    
    // MARK: - Inits
    init(imageManager: PHImageManager) {
        self.imageManager = imageManager
    }
    
    // MARK: - ThumbnailExtractor
    func extractThumbnail(forAsset asset: PHAsset,
                          thumbnailSize: CGSize,
                          contentMode: PHImageContentMode,
                          deliveryMode: PHImageRequestOptionsDeliveryMode,
                          completionBlock: @escaping (ThumbnailExtractResult?) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = deliveryMode
        
        return imageManager.requestImage(for: asset,
                                         targetSize: thumbnailSize,
                                         contentMode: contentMode,
                                         options: options) { image, info in
            guard let info, let image else {
                completionBlock(nil)
                return
            }
            if let isCancelled = info[PHImageCancelledKey] as? NSNumber, isCancelled.boolValue {
                completionBlock(nil)
                return
            }
            if let isDegraded = info[PHImageResultIsDegradedKey] as? NSNumber, isDegraded.boolValue {
                completionBlock((image, true))
                return
            }
            completionBlock((image, false))
        }
    }
    
    func cancelThumbnailExtraction(imageRequestID: PHImageRequestID) {
        imageManager.cancelImageRequest(imageRequestID)
    }
}


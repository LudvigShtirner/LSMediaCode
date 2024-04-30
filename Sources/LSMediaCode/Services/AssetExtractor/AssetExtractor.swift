//
//  AssetExtractor.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import Photos

public protocol AssetExtractor {
    func extractMedia(fromAsset asset: PHAsset,
                      assetRequestOptions: PHVideoRequestOptions,
                      completion: @escaping (AVURLAsset?) -> Void) -> PHImageRequestID
    func cancelExtraction(requestId: PHImageRequestID)
}

final class AssetExtractorBase: AssetExtractor {
    // MARK: - Dependencies
    private let imageManager: PHImageManager
    
    // MARK: - Inits
    init(imageManager: PHImageManager) {
        self.imageManager = imageManager
    }
    
    // MARK: - AssetExtractor
    func extractMedia(fromAsset asset: PHAsset,
                      assetRequestOptions: PHVideoRequestOptions,
                      completion: @escaping (AVURLAsset?) -> Void) -> PHImageRequestID {
        let imageRequestId = imageManager.requestAVAsset(forVideo: asset,
                                                         options: assetRequestOptions) { (avAsset, _, _) in
            completion(avAsset as? AVURLAsset)
        }
        return imageRequestId
    }
    
    func cancelExtraction(requestId: PHImageRequestID) {
        imageManager.cancelImageRequest(requestId)
    }
}

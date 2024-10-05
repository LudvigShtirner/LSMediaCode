//
//  ThumbnailExtractor.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import UIKit
import Photos

public typealias ThumbnailExtractResult = (image: UIImage, isDegraded: Bool)

public protocol ThumbnailExtractor {
    func extractThumbnail(forAsset asset: PHAsset,
                          thumbnailSize: CGSize,
                          contentMode: PHImageContentMode,
                          deliveryMode: PHImageRequestOptionsDeliveryMode,
                          completionBlock: @escaping (ThumbnailExtractResult?) -> Void) -> PHImageRequestID
    func cancelThumbnailExtraction(imageRequestID: PHImageRequestID)
}

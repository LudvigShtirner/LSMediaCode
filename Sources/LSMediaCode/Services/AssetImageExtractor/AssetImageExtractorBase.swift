//
//  AssetImageExtractorBase.swift
//
//
//  Created by Алексей Филиппов on 16.12.2023.
//

// SPM
import SupportCode
// Apple
import Foundation
import class Photos.PHAsset
import class Photos.PHImageManager
import CoreGraphics

/// Реализация извлекателя изображения из ассета
final class AssetImageExtractorBase: AssetImageExtractor {
    // MARK: - Dependencies
    private let thumbnailExtractor: ThumbnailExtractor
    
    // MARK: - Lfie cycle
    init(thumbnailExtractor: ThumbnailExtractor) {
        self.thumbnailExtractor = thumbnailExtractor
    }
    
    // MARK: - Info
    private let operationQueue: OperationQueue = {
        let opQueue = OperationQueue()
        opQueue.qualityOfService = .userInitiated
        return opQueue
    }()
    
    // MARK: - AssetImageExtracting
    func extractImage(forAsset asset: PHAsset,
                      requestedSize: CGSize,
                      completionBlock: @escaping OptImageBlock) {
        let operation = AssetImageExtractOperation(thumbnailExtractor: thumbnailExtractor,
                                                   localIdentifier: asset.localIdentifier,
                                                   requestedSize: requestedSize,
                                                   finishBlock: completionBlock)
        operationQueue.addOperation(operation)
    }
}


//
//  AssetImageExtractor.swift
//
//
//  Created by Алексей Филиппов on 16.12.2023.
//

// SPM
import SupportCode
// Apple
import class Photos.PHAsset
import CoreGraphics

/// Протокол извлекателя изображения из ассета
public protocol AssetImageExtractor: AnyObject {
    /// Извлечь изображение из ассета
    ///
    /// - Parameters:
    ///   - asset: ассет изображения
    ///   - requestedSize: необходимый размер
    ///   - completionBlock: блок операций после извлечения изображения
    func extractImage(forAsset asset: PHAsset,
                      requestedSize: CGSize,
                      completionBlock: @escaping OptImageBlock)
}


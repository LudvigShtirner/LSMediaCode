//
//  ImageExtractorProtocol.swift
//  
//
//  Created by Алексей Филиппов on 02.04.2023.
//

// SPM
import SupportCode
// Apple
import UIKit
import AVFoundation

public protocol ImageExtractorProtocol {
    func extractCGImage(fromAsset asset: AVAsset,
                        atTime time: CMTime) -> CGImage?
    @available(iOS 16.0, *)
    func extractCGImage(fromAsset asset: AVAsset,
                        atTime time: CMTime) async -> CGImage?
    func extractCGImage(fromAsset asset: AVAsset,
                        maximumSize: CGSize,
                        atTime time: CMTime,
                        completion: @escaping ResultBlock<CGImage>)
}

public extension ImageExtractorProtocol {
    func extractCGImage(fromAsset asset: AVAsset,
                        atTime time: CMTime) -> CGImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        return try? generator.copyCGImage(at: time, actualTime: nil)
    }
    
    @available(iOS 16.0, *)
    func extractCGImage(fromAsset asset: AVAsset,
                        atTime time: CMTime) async -> CGImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        return try? await generator.image(at: time).image
    }
    
    func extractCGImage(fromAsset asset: AVAsset,
                        maximumSize: CGSize,
                        atTime time: CMTime,
                        completion: @escaping ResultBlock<CGImage>) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = maximumSize
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { t1, image, t2, result, error in
            guard let image else {
                completion(.failure(error ?? NSError()))
                return
            }
            completion(.success(image))
        }
    }
}

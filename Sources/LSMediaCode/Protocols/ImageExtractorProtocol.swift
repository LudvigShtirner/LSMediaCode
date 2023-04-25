//
//  ImageExtractorProtocol.swift
//  
//
//  Created by Алексей Филиппов on 02.04.2023.
//

// Apple
import AVFoundation

public protocol ImageExtractorProtocol {
    func extractCGImage(fromAsset asset: AVAsset,
                        atTime time: CMTime) -> CGImage?
}

public extension ImageExtractorProtocol {
    func extractCGImage(fromAsset asset: AVAsset,
                        atTime time: CMTime) -> CGImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        return try? generator.copyCGImage(at: time, actualTime: nil)
    }
}

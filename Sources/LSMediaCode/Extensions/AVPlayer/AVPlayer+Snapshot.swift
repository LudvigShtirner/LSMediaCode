//
//  AVPlayer+Snapshot.swift
//  
//
//  Created by Алексей Филиппов on 02.04.2023.
//

// Apple
import AVKit

public extension AVPlayer {
    /// Creates image from current playable asset extracted by time
    ///
    /// - Important: If player doesn't stopped, it would be for capturing snapshot
    func takeSnapshot() -> CGImage? {
        if rate != 0 {
            pause()
        }
        guard let asset = currentItem?.asset,
              let time = currentItem?.currentTime() else {
            return nil
        }
        return extractCGImage(fromAsset: asset, atTime: time)
    }
}

extension AVPlayer: ImageExtractorProtocol {
    
}

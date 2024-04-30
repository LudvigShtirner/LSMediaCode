//
//  VideoCreateOptions.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import Foundation
import CoreGraphics

public struct VideoCreateOptions {
    let outputSize: CGSize
    let fps: Int32
    let duration: TimeInterval
    let outputURL: URL
    
    public init(outputSize: CGSize, 
                fps: Int32,
                duration: TimeInterval,
                outputURL: URL) {
        self.outputSize = outputSize
        self.fps = fps
        self.duration = duration
        self.outputURL = outputURL
    }
}

//
//  VideoCreator.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import UIKit
import AVFoundation

public protocol VideoCreator: AnyObject {
    func createVideo(from photo: UIImage,
                     options: VideoCreateOptions,
                     progress: ((Double) -> Void)?,
                     completion: @escaping (Result<AVURLAsset, VideoCreatorError>) -> Void)
}

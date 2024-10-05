//
//  VideoCreatorBase.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// SPM
import SupportCode
// Apple
import UIKit
import AVFoundation

final class VideoCreatorBase: VideoCreator {
    // MARK: - Dependencies
    private let fileManager: FileManager
    
    // MARK: - Data
    private var assetWriter: AVAssetWriter?
    private let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
        return operationQueue
    }()
    
    // MARK: - Life cycle
    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    // MARK: - VideoCreator
    func createVideo(from photo: UIImage,
                     options: VideoCreateOptions,
                     progress: DoubleBlock?,
                     completion: @escaping (Result<AVURLAsset, VideoCreatorError>) -> Void) {
        var assetWriter: AVAssetWriter
        do {
            assetWriter = try AVAssetWriter(outputURL: options.outputURL,
                                            fileType: .mov)
        } catch let writerError as NSError {
            completion(.failure(.canNotCreateWriter(writerError)))
            return
        }
        let operation = VideoCreateTask(fileManager: fileManager,
                                        assetWriter: assetWriter,
                                        photo: photo,
                                        options: options,
                                        progress: progress,
                                        completion: completion)
        operationQueue.addOperation(operation)
    }
    
    func cancelCreatingVideos() {
        operationQueue.cancelAllOperations()
    }
}

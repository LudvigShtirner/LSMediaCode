//
//  VideoCreatorBase.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import UIKit
import AVFoundation

final class VideoCreatorBase: VideoCreator {
    // MARK: - Dependencies
    private let fileManager: FileManager
    
    // MARK: - Data
    private var assetWriter: AVAssetWriter?
    private let mediaQueue = DispatchQueue(label: "\(#file).queue")
    
    // MARK: - Life cycle
    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    // MARK: - VideoCreator
    func createVideo(from photo: UIImage,
                     options: VideoCreateOptions,
                     progress: ((Double) -> Void)?,
                     completion: @escaping (Result<URL, VideoCreatorError>) -> Void) {
        do {
            try removeFileIfNeeded(at: options.outputURL)
        } catch let error as NSError {
            completion(.failure(.outputPathNotEmpty(error)))
            return
        }
        var assetWriter: AVAssetWriter
        do {
            try assetWriter = AVAssetWriter(outputURL: options.outputURL, fileType: .mov)
        } catch let writerError as NSError {
            completion(.failure(.canNotCreateWriter(writerError)))
            return
        }
        self.assetWriter = assetWriter
        
        let videoSettings: [String : AnyObject] = [
            AVVideoCodecKey  : AVVideoCodecType.hevc as AnyObject,
            AVVideoWidthKey  : options.outputSize.width as AnyObject,
            AVVideoHeightKey : options.outputSize.height as AnyObject,
        ]
        let assetWriterInput = AVAssetWriterInput(mediaType: .video,
                                                  outputSettings: videoSettings)
        
        #warning("Проверить Scaled size, возможно в 2-3 раза меньше пикселей используется")
        let sourceBufferAttributes = [
            (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
            (kCVPixelBufferWidthKey as String): Float(photo.size.width),
            (kCVPixelBufferHeightKey as String): Float(photo.size.height)] as [String : Any]
        
        guard assetWriter.canAdd(assetWriterInput) else {
            completion(.failure(VideoCreatorError.canNotAddInput))
            return
        }
        assetWriter.add(assetWriterInput)
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput,
                                                                      sourcePixelBufferAttributes: sourceBufferAttributes)
        guard assetWriter.startWriting() else {
            completion(.failure(VideoCreatorError.canNotStartWriting))
            return
        }
        assetWriter.startSession(atSourceTime: .zero)
        
        guard pixelBufferAdaptor.pixelBufferPool != nil else {
            completion(.failure(VideoCreatorError.pixelBufferPoolNotCreated))
            return
        }
        
        var error: VideoCreatorError?
        assetWriterInput.requestMediaDataWhenReady(on: mediaQueue) {
            let fps = options.fps
            let frameDuration = CMTimeMake(value: 1, timescale: fps)
            var frameCount: Int64 = 0
            let totalFrames = Double(fps) * options.duration
            while true {
                if assetWriterInput.isReadyForMoreMediaData == false {
                    continue
                }
                if Double(frameCount) >= totalFrames {
                    break
                }
                let lastFrameTime = CMTimeMake(value: frameCount, timescale: fps)
                let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                let success = self.appendPixelBufferForImage(photo,
                                                             pixelBufferAdaptor: pixelBufferAdaptor,
                                                             presentationTime: presentationTime)
                if !success {
                    error = VideoCreatorError.bufferNotAppended
                    break
                }
                frameCount += 1
                progress?(Double(frameCount) / totalFrames)
            }
            assetWriterInput.markAsFinished()
            assetWriter.finishWriting { [weak self] in
                self?.assetWriter = nil
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(options.outputURL))
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func removeFileIfNeeded(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        try fileManager.removeItem(at: url)
    }
    
    private func appendPixelBufferForImage(_ image: UIImage,
                                           pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
                                           presentationTime: CMTime) -> Bool {
        var appendSucceeded = false
        
        autoreleasepool {
            guard let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool else {
                return
            }
            let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
            let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault,
                                                                      pixelBufferPool,
                                                                      pixelBufferPointer)
            
            if let pixelBuffer = pixelBufferPointer.pointee, status == 0 {
                fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
                appendSucceeded = pixelBufferAdaptor.append(pixelBuffer,
                                                            withPresentationTime: presentationTime)
                pixelBufferPointer.deinitialize(count: 1)
            }
            pixelBufferPointer.deallocate()
        }
        return appendSucceeded
    }
    
    private func fillPixelBufferFromImage(_ image: UIImage, pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                width: Int(image.size.width),
                                height: Int(image.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let rect = CGRect(origin: .zero, size: image.size)
        context?.draw(image.cgImage!, in: rect)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
}

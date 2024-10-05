//
//  VideoCreateTask.swift
//
//
//  Created by Алексей Филиппов on 06.05.2024.
//

// SPM
import SupportCode
// Apple
import UIKit
import AVFoundation

final class VideoCreateTask: AsyncOperation {
    // MARK: - Dependencies
    private let fileManager: FileManager
    private let assetWriter: AVAssetWriter
    
    // MARK: - Data
    private let photo: UIImage
    private let options: VideoCreateOptions
    private let progress: DoubleBlock?
    private let completion: (Result<AVURLAsset, VideoCreatorError>) -> Void
    private let mediaQueue: DispatchQueue
    
    // MARK: - Life cycle
    init(fileManager: FileManager,
         assetWriter: AVAssetWriter,
         photo: UIImage,
         options: VideoCreateOptions,
         progress: DoubleBlock?,
         completion: @escaping (Result<AVURLAsset, VideoCreatorError>) -> Void) {
        self.fileManager = fileManager
        self.assetWriter = assetWriter
        self.photo = photo
        self.options = options
        self.progress = progress
        self.completion = completion
        self.mediaQueue = DispatchQueue(label: "\(#file)\(options.outputURL.lastPathComponent).queue")
        super.init()
    }
    
    // MARK: - Overrides
    override func main() {
        do {
            try removeFileIfNeeded(at: options.outputURL)
        } catch let error as NSError {
            finishOperation(result: .failure(.outputPathNotEmpty(error)))
            return
        }
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
            (kCVPixelBufferHeightKey as String): Float(photo.size.height)
        ] as [String : Any]
        
        guard assetWriter.canAdd(assetWriterInput) else {
            finishOperation(result: .failure(VideoCreatorError.canNotAddInput))
            return
        }
        assetWriter.add(assetWriterInput)
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput,
                                                                      sourcePixelBufferAttributes: sourceBufferAttributes)
        
        guard assetWriter.startWriting() else {
            let error = assetWriter.error
            finishOperation(result: .failure(VideoCreatorError.canNotStartWriting(error)))
            return
        }
        assetWriter.startSession(atSourceTime: .zero)
        
        guard pixelBufferAdaptor.pixelBufferPool != nil else {
            finishOperation(result: .failure(VideoCreatorError.pixelBufferPoolNotCreated))
            return
        }
        
        var error: VideoCreatorError?
        assetWriterInput.requestMediaDataWhenReady(on: mediaQueue) { [weak self] in
            guard let self else { return }
            let fps = self.options.fps
            let frameDuration = CMTimeMake(value: 1, timescale: fps)
            var frameCount: Int64 = 0
            let totalFrames = Double(fps) * self.options.duration
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
            self.assetWriter.finishWriting { [weak self] in
                guard let self else { return }
                if let error {
                    self.finishOperation(result: .failure(error))
                } else {
                    let asset = AVURLAsset(url: self.options.outputURL)
                    self.finishOperation(result: .success(asset))
                }
            }
        }
    }
    
    override func cancel() {
        finishOperation(result: .failure(.cancelled))
    }
}

private extension VideoCreateTask {
    func finishOperation(result: Result<AVURLAsset, VideoCreatorError>) {
        completion(result)
        completeOperation()
    }
    
    func removeFileIfNeeded(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        try fileManager.removeItem(at: url)
    }
    
    func appendPixelBufferForImage(_ image: UIImage,
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
    
    func fillPixelBufferFromImage(_ image: UIImage,
                                  pixelBuffer: CVPixelBuffer) {
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

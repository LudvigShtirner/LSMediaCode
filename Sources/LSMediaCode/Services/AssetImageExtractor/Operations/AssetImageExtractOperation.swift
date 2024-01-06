//
//  AssetImageExtractOperation.swift
//
//
//  Created by Алексей Филиппов on 16.12.2023.
//

// SPM
import SupportCode
// Apple
import Photos
import class UIKit.UIImage

/// Операция по извлечению изображения из ассета галереи
final class AssetImageExtractOperation: AsyncOperation {
    // MARK: - Info
    private let imageManager: PHImageManager
    private let localIdentifier: String
    private let requestedSize: CGSize
    private let finishBlock: OptImageBlock
    
    // MARK: - Inits
    init(imageManager: PHImageManager,
         localIdentifier: String,
         requestedSize: CGSize,
         finishBlock: @escaping OptImageBlock) {
        self.imageManager = imageManager
        self.localIdentifier = localIdentifier
        self.requestedSize = requestedSize
        self.finishBlock = finishBlock
    }
    
    // MARK: - Override
    override func main() {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier],
                                              options: nil)
        if fetchResult.countOfAssets(with: .image) == 0 {
            finishBlock(nil)
            completeOperation()
            return
        }
        let phAsset = fetchResult[0]
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: phAsset,
                                  targetSize: requestedSize,
                                  contentMode: .aspectFit,
                                  options: options) { [weak self] (result, info) in
                                    guard let self = self else {
                                        return
                                    }
                                    if self.isCancelled {
                                        self.completeOperation()
                                        return
                                    }
                                    if self.isFinished {
                                        return
                                    }
                                    // imageManager в асинхронном режиме и opportunistic delivery mode
                                    // может 2 раза дернуть resultHandler с картинками разного качества
                                    // если операцию успели отменить или она считается завершенной
                                    // перестаем отправлять результаты во внешний мир
                                    // завершаем операцию в случае если мы получили картинку максимально качества
                                    guard let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool else {
                                        return
                                    }
                                    if !isDegraded {
                                        self.finishBlock(result)
                                        self.completeOperation()
                                    }
        }
    }
}

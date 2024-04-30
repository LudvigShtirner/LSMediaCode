//
//  AssetExporter.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// SPM
import SupportCode
// Apple
import Foundation
import AVFoundation

public protocol AssetExporter {
    typealias ProgressTuple = (timerUpdate: TimeInterval, progressBlock: DoubleBlock)
    
    var isExporting: Bool { get }
    
    func export(asset: AVAsset,
                preset: PresetType,
                outputFileURL: URL,
                progressTuple: ProgressTuple?,
                completion: @escaping (URL?) -> Void)
    func cancelExporting()
}

final class AssetExporterBase: AssetExporter {
    // MARK: - Dependencies
    private var exporter: AVAssetExportSession?
    
    // MARK: - Data
    private var progressTimer: Timer?
    private var shouldKeepRunning = false
    private let queue = DispatchQueue(label: "\(#file).Timer",
                                      qos: .background,
                                      autoreleaseFrequency: .workItem)
    
    // MARK: - Life cycle
    init() { }
    
    deinit {
        cancelExporting()
    }
    
    // MARK: - AssetExporter
    var isExporting: Bool {
        exporter?.status == .exporting
    }
    
    func export(asset: AVAsset,
                preset: PresetType,
                outputFileURL: URL,
                progressTuple: ProgressTuple?,
                completion: @escaping (URL?) -> Void) {
        guard let exporter = AVAssetExportSession(asset: asset,
                                                  presetName: preset.exportPreset) else {
            return
        }
        exporter.outputURL = outputFileURL
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously { [weak self] in
            guard let exporter = self?.exporter else { return }
            self?.invalidateTimer()
            switch exporter.status {
            case .completed:
                completion(outputFileURL)
            default:
                completion(nil)
            }
        }
        
        guard let (timerInterval, progressBlock) = progressTuple else {
            return
        }
        queue.async { [weak self] in
            guard let self = self else { return }
            let timer = Timer.scheduledTimer(withTimeInterval: timerInterval,
                                             repeats: true,
                                             block: { [weak self] _ in
                guard self?.exporter?.status == .exporting,
                      let progress = self?.exporter?.progress else {
                    return
                }
                progressBlock(Double(progress))
            })
            self.progressTimer = timer
            let runLoop = RunLoop.current
            runLoop.add(timer, forMode: .common)
            self.shouldKeepRunning = true
            while self.shouldKeepRunning {
                runLoop.run(until: Date().advanced(by: timerInterval * 2))
            }
        }
        self.exporter = exporter
    }
    
    func cancelExporting() {
        exporter?.cancelExport()
    }
    
    // MARK: - Private methods
    private func invalidateTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        shouldKeepRunning = false
    }
}

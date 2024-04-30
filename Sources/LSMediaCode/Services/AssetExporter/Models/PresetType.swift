//
//  PresetType.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import AVFoundation

public enum PresetType {
    case ultraHD(Bool)
    case fullHD(Bool)
    case hd
    
    public var exportPreset: String {
        switch self {
        case .ultraHD(let isHEVC): return isHEVC ? AVAssetExportPresetHEVC3840x2160 : AVAssetExportPreset3840x2160
        case .fullHD(let isHEVC): return isHEVC ? AVAssetExportPresetHEVC1920x1080 : AVAssetExportPreset1920x1080
        case .hd: return AVAssetExportPreset1280x720
        }
    }
    
    public var size: CGSize {
        switch self {
        case .ultraHD(_): return CGSize(width: 3840, height: 2160)
        case .fullHD(_): return CGSize(width: 1920, height: 1080)
        case .hd: return CGSize(width: 1280, height: 720)
        }
    }
}


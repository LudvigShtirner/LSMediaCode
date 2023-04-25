//
//  PHFetchResult+Utils.swift
//  
//
//  Created by Алексей Филиппов on 02.04.2023.
//

// Apple
import Photos

public extension PHFetchResult where ObjectType == PHAsset {
    /// Extracted assets from fetch result. Calculated property O(N)
    var assets: [PHAsset] {
        var assets: [PHAsset] = []
        self.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
}

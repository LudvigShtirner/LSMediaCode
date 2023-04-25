//
//  CMTime+Utils.swift
//  
//
//  Created by Алексей Филиппов on 02.04.2023.
//

// Apple
import CoreMedia

public extension CMTime {
    var half: CMTime {
        CMTimeMultiplyByRatio(self, multiplier: 1, divisor: 2)
    }
    
    func multiply(on value: Double) -> CMTime {
        CMTime(seconds: seconds * value,
               preferredTimescale: timescale)
    }
}


//
//  VideoCreatorError.swift
//
//
//  Created by Алексей Филиппов on 31.03.2024.
//

// Apple
import Foundation

public enum VideoCreatorError: Error {
    case outputPathNotEmpty(Error)
    case canNotCreateWriter(Error)
    case canNotAddInput
    case canNotStartWriting(Error?)
    case pixelBufferPoolNotCreated
    case bufferNotAppended
    case cancelled
}

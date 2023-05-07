//
//  NSFWJSWrapperError.swift
//  NSFWJSWrapper
//
//  Created by nice2meet on 2023/5/7.
//

import Foundation

enum NSFWJSWrapperError {
    case emptyInput
    case busy
    case notReady
    
    private static let domain = "NSFWJSWrapperError"
    var error: NSError {
        switch self{
        case .emptyInput:
            return NSError.init(domain: Self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey : "emptyInput"])
        case .busy:
            return NSError.init(domain: Self.domain, code: -2, userInfo: [NSLocalizedDescriptionKey : "busy"])
        case .notReady:
            return NSError.init(domain: Self.domain, code: -2, userInfo: [NSLocalizedDescriptionKey : "notReady"])
        }
    }
}

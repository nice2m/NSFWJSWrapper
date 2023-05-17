//
//  NSFWJSWrapperWebView.swift
//  NSFWJSWrapper
//
//  Created by nice2meet on 2023/5/7.
//

import Foundation
import WebKit

class NSFWJSWrapperWebView: WKWebView { }

enum NSFWJSWrapperMessageHandler: String, CaseIterable {
    case nativeOnCall
    
    enum Name: String {
        case updateJSFilesLoadSucceed
        case updateSingleClassifyComplete
        case updateWramUpLoadComplete
    }
}

enum NSFWJSWrapperJSFunction {
    
    case classifyImage(uuid: String, imageDataBase64: String)
    case jsOnCallUpdateHost(hostName: String)
    
    func build(extraParam: [String: String]? = nil) -> String {
        switch self {
        case .classifyImage(let uuid, let imageDataBase64):
            let imageData = String(format: "data:image/png;base64,%@", imageDataBase64)
            return "classifyImage('\(uuid)','\(imageData)');"
        case .jsOnCallUpdateHost(let hostName):
             return "jsOnCallUpdateHost('\(hostName)');"
        }
    }
}

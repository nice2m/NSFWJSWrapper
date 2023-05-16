//
//  NSFWJSWrapperWebView.swift
//  NSFWJSWrapper
//
//  Created by nice2meet on 2023/5/7.
//

import Foundation
import WebKit

class NSFWJSWrapperWebView: WKWebView { }

enum NSFWJSWrapperMessageName: String, CaseIterable {
    case nativeOnCall
}

enum NSFWJSWrapperJSFunction {
    
    case classifyImage(uuid: String, imageDataBase64: String)
    
    case jsOnCallUpdateTFModelUrl(TFModelUrl: String)
    
    case jsOnCallLoadJSes(loadings: [String])
    
    func build(extraParam: [String: String]? = nil) -> String {
        switch self {
        case .classifyImage(let uuid, let imageDataBase64):
            let imageData = String(format: "data:image/png;base64,%@", imageDataBase64)
            return "classifyImage('\(uuid)','\(imageData)');"
        case .jsOnCallUpdateTFModelUrl(let TFModelUrl):
            return "jsOnCallUpdateTFModelUrl('\(TFModelUrl)');"
        case .jsOnCallLoadJSes(let loadings):
            let tmpjsArr = loadings.map{ "'\($0)'" }.joined(separator: ",")
            return "jsOnCallLoadJSes([\(tmpjsArr)]);"
        }
    }
}

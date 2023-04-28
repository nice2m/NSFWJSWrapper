//
//  NSFWJSWrapper.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/4/27.
//

import UIKit
import WebKit

class NSFWJSWebContainer: WKWebView {
    
}

enum NSFWJSWrapperMessageName: String, CaseIterable {
    case onNativeCall
}

enum NSFWJSWrapperJSFunction {
    
    case classifyImage(uuid: String, imageDataBase64: String)
    
    func buildFunction(extraParam: [String: String]? = nil) -> String {
        switch self {
        case .classifyImage(let uuid, let imageDataBase64):
            var paramOrigin = [
                "uuid" : uuid,
                "imageData" : String(format: "data:image/png;base64,%@", imageDataBase64),
            ]
            
            if let extraParam = extraParam {
                let _ = extraParam.keys.map { key in
                    paramOrigin[key] = extraParam[key]
                }
            }
            
            if let json = try? paramOrigin.toJsonString() {
                return "classifyImage(\(json))"
            }
            return ""
        }
    }
}


class NSFWJSResultModel: Codable {
    let className: String
    let possibility: String
}

class NSFWJSTask: NSObject {
    let uuid: String
    let image: UIImage
    
    init(uuid: String, image: UIImage) {
        self.uuid = uuid
        self.image = image
    }
    
    static func task(image: UIImage) -> NSFWJSTask {
        let uuid = UUID()
        return NSFWJSTask(uuid: uuid.uuidString, image: image)
    }
}

typealias NSFWJSCompletion = ([NSFWJSResultModel]) -> Void

class NSFWJSWrapper: NSObject {
    
    static let shared = NSFWJSWrapper()
    
    private var taskQueues = [String: NSFWJSTask]()
    
    private var webContainer: NSFWJSWebContainer?
    
    private var isLoaded: Bool = false {
        didSet{
            if isLoaded {
                
            }
        }
    }
    
    override init() {
        super.init()
        
        config()
    }
    
    func classify(image: UIImage, uuid: String) {
        // data:image/png;base64
        guard let data = image.jpegData(compressionQuality: 0.618) else {
            return
        }
        let function = NSFWJSWrapperJSFunction.classifyImage(uuid: uuid, imageDataBase64: data.base64EncodedString()).buildFunction()
        webContainer?.evaluateJavaScript(function, completionHandler: { result, error in
            print("result:\(String(describing: result))")
            print("error:\(error)")
        });
    }
}

extension NSFWJSWrapper {
    private func config() {
        
        let configuration = WKWebViewConfiguration.init()
        let contentVC = WKUserContentController.init()
        
        let _ = NSFWJSWrapperMessageName.allCases.map { name in
            contentVC.add(self, name: name.rawValue)
        }
        webContainer = NSFWJSWebContainer(frame: .zero, configuration: configuration)
        
        if let fileURL = Bundle.main.url(forResource: "NSFWJSMessager.html", withExtension: nil) {
            let request = URLRequest(url: fileURL)
            webContainer?.load(request)
        }
    }
    
}

extension NSFWJSWrapper: WKScriptMessageHandler, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
        print(navigation)
        isLoaded = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
        print(navigation)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation")
        print(navigation)
        print("\(error)")
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        switch message.name {
        case NSFWJSWrapperMessageName.onNativeCall.rawValue:
            ()
        default:
            print(message)
        }
    }
    
}

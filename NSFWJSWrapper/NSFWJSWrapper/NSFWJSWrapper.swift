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
            let imageData = String(format: "data:image/png;base64,%@", imageDataBase64)
            return "classifyImage(\(uuid),\(imageData)"
        }
    }
}


class NSFWJSResultModel: Codable {
    let className: String
    let probability: String
}

class NSFWJSTask: NSObject {
    let uuid: String
    let image: UIImage
    
    let completion: NSFWJSCompletion?
    
    init(uuid: String, image: UIImage,completion: NSFWJSCompletion? = nil) {
        self.uuid = uuid
        self.image = image
        self.completion = completion
    }
}

typealias NSFWJSCompletion = ([NSFWJSResultModel]?) -> Void

class NSFWJSWrapper: NSObject {
    
    static let `default` = NSFWJSWrapper()
    
    private var taskQueue = [String: NSFWJSTask]()
    
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
    
    @discardableResult
    static func task(image: UIImage, completion: NSFWJSCompletion?) -> NSFWJSTask {
        let uuid = UUID().uuidString
        let task = NSFWJSTask(uuid: uuid, image: image, completion: completion)
        NSFWJSWrapper.default.taskQueue[uuid] = task
        NSFWJSWrapper.default.classify(image: image, uuid: uuid)
        return task
    }
    
    private func classify(image: UIImage, uuid: String) {
        // data:image/png;base64
        guard let data = image.jpegData(compressionQuality: 0.618) else {
            return
        }
        let function = NSFWJSWrapperJSFunction.classifyImage(uuid: uuid, imageDataBase64: data.base64EncodedString()).buildFunction()
        webContainer?.evaluateJavaScript(function, completionHandler: { result, error in
            print("result:\(String(describing: result))")
            print("error:\(String(describing: error))")
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
        guard let body = message.body as? [String: Any],
              let uuid = body["uuid"] as? String,
              let bodyJSON = try? JSONSerialization.data(withJSONObject: body, options: .sortedKeys) else {
            return
        }
        switch message.name {
        case NSFWJSWrapperMessageName.onNativeCall.rawValue:
            guard let task =  taskQueue[uuid] else {
                return
            }
            let decoder = JSONDecoder()
            let modelList = try? decoder.decode([NSFWJSResultModel].self, from: bodyJSON)
            task.completion?(modelList)
        default:
            print(message)
        }
    }
    
}

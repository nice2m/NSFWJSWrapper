//
//  NSFWJSWrapper.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/4/27.
//

import UIKit
import WebKit

class NSFWJSWrapperSingleTask {
    let uuid: String
    let image: UIImage
    let completion: NSFWJSWrapperCompletion?
    
    init(uuid: String = UUID().uuidString, image: UIImage, completion: NSFWJSWrapperCompletion? = nil) {
        self.uuid = uuid
        self.image = image
        self.completion = completion
    }
    
    init(image: UIImage) {
        self.image = image
        self.uuid = UUID().uuidString
        self.completion = nil
    }
}

typealias NSFWJSWrapperCompletion = ([NSFWJSWrapperResultModel]?, _ error: NSFWJSWrapperError?) -> Void

class NSFWJSWrapper: NSObject {
    enum Status {
        case notInitialized
        case ready
        case busy
    }
    
    static let `default` = NSFWJSWrapper()
    
    private static var isLoaded: Bool = false
    
    var status: Status {
        if !Self.isLoaded {
            return .notInitialized
        }
        
        if readyToResume() {
            return .ready
        }
        
        return .busy
    }
    
    private var currentResults = NSFWJSWrapperResultGroupModel()
    
    private var webContainer: NSFWJSWrapperWebView?
    
    private  var executionGroup: DispatchGroup?
    
    override init() {
        super.init()
        config()
    }
    
    static func initService() {
        let _ = Self.default
    }
    
    func resume(task list: [NSFWJSWrapperSingleTask], completion: NSFWJSWrapperCompletion?) {
        guard status == .ready else {
            completion?(nil, NSFWJSWrapperError.notReady)
            return
        }
        guard !list.isEmpty else {
            completion?(nil, NSFWJSWrapperError.emptyInput)
            return
        }
        
        guard readyToResume() else {
            completion?(nil, NSFWJSWrapperError.busy)
            return
        }
        
        let groupUUID = list[0].uuid
        currentResults = .init()
        currentResults.groupUUID = groupUUID
        currentResults.completion = completion
        let group = DispatchGroup()
        executionGroup = group
        
        _ = list.map{ task in
            let singleResult = NSFWJSWrapperResultModel()
            singleResult.uuid = task.uuid
            singleResult.completion = task.completion
            currentResults.list.append(singleResult)
            
            executionGroup?.enter()
            classify(image: task.image, uuid: task.uuid)
        }
        executionGroup?.notify(queue: .main) {[weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.currentResults.completion?(weakSelf.currentResults.list, nil)
        }
    }
}

extension NSFWJSWrapper {
    
    private func readyToResume() -> Bool {
        return currentResults.isCompleted
    }
    
    private func classify(image: UIImage, uuid: String) {
        let quality: CGFloat = 0.99
        guard let data = image.jpegData(compressionQuality: quality) else {
            return
        }
        let function = NSFWJSWrapperJSFunction.classifyImage(uuid: uuid, imageDataBase64: data.base64EncodedString()).build()
        webContainer?.evaluateJavaScript(function)
    }
    
    private func config() {
        
        let configuration = WKWebViewConfiguration.init()
        let userContentController = WKUserContentController.init()
        
        let _ = NSFWJSWrapperMessageName.allCases.map { name in
            userContentController.add(self, name: name.rawValue)
        }
        configuration.userContentController = userContentController
        webContainer = NSFWJSWrapperWebView(frame: .zero, configuration: configuration)
        webContainer?.navigationDelegate = self
        webContainer?.uiDelegate = self
        
        if let fileURL = Bundle.main.url(forResource: "NSFWJSMessager.html", withExtension: nil) {
            let request = URLRequest(url: fileURL,cachePolicy: .returnCacheDataElseLoad,timeoutInterval: 60)
            webContainer?.load(request)
        }
    }
    
}

extension NSFWJSWrapper: WKUIDelegate { }
extension NSFWJSWrapper: WKScriptMessageHandler, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Self.isLoaded = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case NSFWJSWrapperMessageName.nativeOnCall.rawValue:
            updateSingleResult(message: message)
            executionGroup?.leave()
        default:
            // print(message)
            break;
        }
    }
    
    func updateSingleResult(message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let uuid = body["uuid"] as? String,
              let result = body["result"] as? [Any],
              let resultJSON = try? JSONSerialization.data(withJSONObject: result, options: .sortedKeys) else {
            return
        }
        
        let decoder = JSONDecoder()
        guard let singleResult = currentResults.list.first(where: { $0.uuid == uuid }),
              let classes = try? decoder.decode([NSFWJSWrapperResultClassModel].self, from: resultJSON) else {
            return
        }
        singleResult.classes = classes
        singleResult.completion?([singleResult], nil)
        singleResult.state = .finished
    }
    
}

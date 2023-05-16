//
//  NSFWJSWrapper.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/4/27.
//

import UIKit
import WebKit

typealias NSFWJSWrapperCompletion = ([NSFWJSWrapperResultModel]?, _ error: NSFWJSWrapperError?) -> Void

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

typealias NSFWJSWrapperWKWebViewDidFinish = (_ webView: WKWebView, _ navigation: WKNavigation) -> Void

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
        
        if lastComplete() {
            return .ready
        }
        
        return .busy
    }
    
    var wkwebviewDidFinish: NSFWJSWrapperWKWebViewDidFinish? = nil
    
    private var currentResults = NSFWJSWrapperResultGroupModel()
    
    private(set) var webContainer: NSFWJSWrapperWebView?
    
    private  var executionGroup: DispatchGroup?
    
    private var webURL: String = ""
    
    private override init() {
        super.init()
        config()
    }
    
    static func initService(url: String) {
        let wrapper = Self.default
        wrapper.configURL(webURLString: url)
    }
    
    private var startDate: Date = .init()
    
    func configURL(webURLString: String) {
        webURL = webURLString
        reloadWebView()
    }
    
    func resume(task list: [NSFWJSWrapperSingleTask], completion: NSFWJSWrapperCompletion?) {
        switch status {
        case .notInitialized:
            completion?(nil, .notReady)
            return
        case .busy:
            completion?(nil, .busy)
            return
        default:
            break
        }
        
        guard !list.isEmpty else {
            completion?(nil, NSFWJSWrapperError.emptyInput)
            return
        }
        
        guard lastComplete() else {
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
    
    private func lastComplete() -> Bool {
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
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true
        webContainer = NSFWJSWrapperWebView(frame: .zero, configuration: configuration)
        webContainer?.navigationDelegate = self
        webContainer?.uiDelegate = self
    }
    
    func reloadWebView() {
        if let URL = URL.init(string: self.webURL) {
            let request = URLRequest(url: URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            webContainer?.load(request)
            startDate = .init()
        }
    }
    
    private func callJSUpdate(hostName: String) {
        let function2 = NSFWJSWrapperJSFunction.jsOnCallUpdateHost(hostName: hostName).build()
        webContainer?.evaluateJavaScript(function2, completionHandler: { ret, error in
            print(error)
            print(ret)
        })
    }
}

extension NSFWJSWrapper: WKUIDelegate { }
extension NSFWJSWrapper: WKScriptMessageHandler, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Self.isLoaded = true
        print("didFinish load: \(Date().timeIntervalSince(startDate)) seconds")
        let hostName = NSFWJSWrapperManager.default.hostName
        callJSUpdate(hostName: hostName)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
        print(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { }
    
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
        singleResult.state = .finished

        singleResult.completion?([singleResult], nil)
    }
    
}

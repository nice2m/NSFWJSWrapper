//
//  NSFWJSWrapperManager.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/5/16.
//

import Foundation

class NSFWJSWrapperManager {
    
    private var jsesList: [NSFWJSWrapperFileServiceInfo] = [
        .init(fileNameInBundle: "nsfwjs@2.4.2.js", pathInService: "/nsfw.js", mimeType: "text/javascript"),
        .init(fileNameInBundle: "tensorflow@2.6.0.js", pathInService: "/tensorflow.js", mimeType: "text/javascript"),
    ]
    private var serviceList: [NSFWJSWrapperFileServiceInfo] = [
        .init(fileNameInBundle: "tf.min.js.map.json", pathInService: "/tf.min.js.map", mimeType: "text/json"),
        .init(fileNameInBundle: "model.json", pathInService: "/model.json", mimeType: "text/json"),
        .init(fileNameInBundle: "group1-shard1of1", pathInService: "/group1-shard1of1",mimeType: "application/octet-stream")
    ]
    
    static let `default`: NSFWJSWrapperManager = .init()
    
    private let webServer: GCDWebServer = .init()
    
    private init() {
        configServer()
    }
}


extension NSFWJSWrapperManager {
    func configServer() {
        // add server handlers
        let _ = (jsesList + serviceList).map { info in
            webServer.addHandler(forMethod: "GET", path: info.pathInService, request: GCDWebServerRequest.self) { request in
                guard let path = Bundle.main.url(forResource: info.fileNameInBundle, withExtension: nil),
                      let data = try? Data(contentsOf: path) else {
                    return GCDWebServerDataResponse(statusCode: 501)
                }
                return GCDWebServerDataResponse(data: data, contentType: info.mimeType)
            }
        }
        webServer.start()
        
        // call js
        let host = String((webServer.serverURL?.absoluteString ?? "").dropLast(1))
        
        let jsLoadings = jsesList.map{ host + $0.pathInService }
        let function = NSFWJSWrapperJSFunction.jsOnCallLoadJSes(loadings: jsLoadings).build()
        NSFWJSWrapper.default.webContainer?.evaluateJavaScript(function, completionHandler: { result, error in
            print(result)
            print(error)
        })
        
        let function2 = NSFWJSWrapperJSFunction.jsOnCallUpdateTFModelUrl(TFModelUrl: host + "/").build()
        NSFWJSWrapper.default.webContainer?.evaluateJavaScript(function2, completionHandler: { result, error in
            print(result)
            print(error)
        })
    }
}

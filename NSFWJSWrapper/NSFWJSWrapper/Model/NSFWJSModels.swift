//
//  NSFWJSModels.swift
//  NSFWJSWrapper
//
//  Created by nice2meet on 2023/5/7.
//

import Foundation

class NSFWJSWrapperResultGroupModel {
    var groupUUID: String = ""
    var list: [NSFWJSWrapperResultModel] = []
    var completion: NSFWJSWrapperCompletion?
    
    var isCompleted: Bool {
        list.reduce(true) { partialResult, model in
            return partialResult && model.state != .initialized
        }
    }
}

class NSFWJSWrapperResultModel {
    enum State: Equatable {
        case initialized
        case finished
        case error(erro: NSFWJSWrapperError)
    }
    var uuid: String = ""
    var classes: [NSFWJSWrapperResultClassModel] = []
    var state: State = .initialized
    var completion: NSFWJSWrapperCompletion?
}

struct NSFWJSWrapperResultClassModel: Codable {
    let className: String
    let probability: Double
}


//
//  NSFWJSUtil.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/4/27.
//

import UIKit

extension Encodable {
    
    public func toJson(using encoder: JSONEncoder = JSONEncoder(), options: JSONSerialization.ReadingOptions = []) throws -> Any {

        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: options)
    }

    public func toJsonString(using encoder: JSONEncoder = JSONEncoder(), encoding: String.Encoding = .utf8) throws -> String? {

        let data = try encoder.encode(self)
        return String(data: data, encoding: encoding)
    }
}



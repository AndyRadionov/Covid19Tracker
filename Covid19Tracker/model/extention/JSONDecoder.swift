//
//  JSONDecoder.swift
//  Covid19Tracker
//
//  Created by Andy on 22.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import Foundation

extension JSONDecoder.KeyDecodingStrategy {
    struct AnyCodingKey : CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init(_ base: CodingKey) {
            self.stringValue = base.stringValue
            self.intValue = base.intValue
        }
        
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    static var convertFromUpperCamelCase: JSONDecoder.KeyDecodingStrategy {
        return .custom { codingKeys in
            var key = AnyCodingKey(codingKeys.last!)
            if let firstChar = key.stringValue.first {
                let i = key.stringValue.startIndex
                
                key.stringValue.replaceSubrange(
                    i ... i, with: String(firstChar).lowercased()
                )
            }
            return key
        }
    }
}

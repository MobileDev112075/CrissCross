//
//  FilterModel.swift
//  crisscross2.0
//
//  Created by tycoon on 11/19/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import Argo
import Curry
import ReactiveCocoa
import Result


struct FilterModel {
    static private let typeKey  = "type"
    static private let callKey  = "call"
    static private let defOnKey = "defOn"
    static private let innerSKey = "innerS"
    static private let typeIDKey = "typeID"
    
    let type: String
    let call: String?
    var defOn:Bool? = false
    var innerSort:Bool? = false
    let typeID: String?
}

extension FilterModel: Decodable {
    static func decode(json: JSON) -> Decoded<FilterModel> {
        return curry(FilterModel.init)
            <^> json <| typeKey
            <*> json <|? callKey
            <*> json <|? defOnKey
            <*> json <|? innerSKey
            <*> json <|? typeIDKey
        
    }
}




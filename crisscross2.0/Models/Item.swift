//
//  Item.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 2/9/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import Argo
import Curry

struct Item{
    
    static private let idKey            = "id"
    let tid: String
    
}



extension Item: Decodable {
    static func decode(json: JSON) -> Decoded<Item> {
        return curry(Item.init)
            <^> json <| idKey
    }
}


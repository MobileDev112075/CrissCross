//
//  NearMe.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/25/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import Argo
import Curry


struct NearMe {
    static private let titleKey = "title"
    static private let lidKey = "id"

    let lid: String
    let title: String
}

// MARK: Decodable

extension NearMe: Decodable {
    static func decode(json: JSON) -> Decoded<NearMe> {
        return curry(NearMe.init)
            <^> json <| lidKey
            <*> json <| titleKey
    }
}

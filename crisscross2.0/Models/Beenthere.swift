//
//  Beenthere.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/24/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import Curry


struct Beenthere {
    static private let titleKey = "title"
    static private let imgKey = "img"
    static private let locations_idKey = "locations_id"
    static private let commentKey = "comment"
    static private let ratingKey = "rating"
    static private let item_titleKey = "item_title"
    static private let createdKey = "created"
    static private let category_idKey = "category_id"
    static private let custom_imgKey = "custom_img"
    static private let lidKey = "lid"
    static private let sort_keyKey = "sort_key"
    static private let pKey = "p"
    static private let childrenKey = "children"
    
    let lid: String
    let title: String?
    let img: String?
    let locations_id: String?
    let comment: String?
    let rating: Int?
    let item_title: String?
    let created: String?
    let category_id: String?
    let custom_img: String?
    let sort_key: String?
    let p: String?
    let children: [Children]?
}

// MARK: Decodable

extension Beenthere: Decodable {
    static func decode(json: JSON) -> Decoded<Beenthere> {
        return curry(Beenthere.init)
            <^> json <| lidKey
            <*> json <|? titleKey
            <*> json <|? imgKey
            <*> json <|? locations_idKey
            <*> json <|? commentKey
            <*> json <|? ratingKey
            <*> json <|? item_titleKey
            <*> json <|? createdKey
            <*> json <|? category_idKey
            <*> json <|? custom_imgKey
            <*> json <|? sort_keyKey
            <*> json <|? pKey
            <*> json <||? childrenKey
    }
}



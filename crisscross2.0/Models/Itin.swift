//
//  itinModel.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/14/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import Argo
import Curry

struct Itin{
    static private let bylineKey    = "byline"
    static private let catKey       = "category_id"
    static private let idsKey       = "ids"
    static private let imgKey       = "img_url"
    static private let titleKey     = "title"
    
    let byline: String
    let category_id: String?
    let ids:[String]?
    let img_url: String?
    let title: String?
    
    var imageURL: NSURL {
        return NSURL(string: self.img_url ?? "")!
    }
    
}



extension Itin: Decodable {
    static func decode(json: JSON) -> Decoded<Itin> {
        return curry(Itin.init)
            <^> json <| bylineKey
            <*> json <|? catKey
            <*> json <||? idsKey
            <*> json <|? imgKey
            <*> json <|? titleKey
    }
}

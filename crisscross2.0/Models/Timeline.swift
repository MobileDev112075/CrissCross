//
//  Timeline.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/24/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Foundation

import Argo
import Curry


struct Timeline {
    
    static private let time_sectionKey = "section"
    static private let time_typeKey = "type"
    static private let time_users_idKey = "users_id"
    static private let time_createdKey = "created"
    
    static private let time_l1Key = "l1"
    static private let time_l2Key = "l2"
    static private let time_l3Key = "l3"
    
    static private let time_imgKey = "img"
    static private let time_start_dateKey = "start_date"
    static private let time_end_dateKey = "end_date"
    static private let btKey = "bt"
    
    let time_section: String
    let time_type: String
    let time_users_id: String?
    let time_created: String?
    
    let time_l1: String?
    let time_l2: String?
    let time_l3: String?
    
    let time_img: String?
    let time_start_date: String?
    let time_end_date: String?
    let bt: Children?
    
    var imageURL: NSURL {
        return NSURL(string: self.time_img ?? "")!
    }
    
    
//    var avatarURL: NSURL {
//        return NSURL(string: self.users_image ?? "")!
//    }
    
}


// MARK: Decodable

extension Timeline: Decodable {
    static func decode(json: JSON) -> Decoded<Timeline> {
        return curry(Timeline.init)
            <^> json <| time_sectionKey
            <*> json <| time_typeKey
            <*> json <|? time_users_idKey
            <*> json <|? time_createdKey
        
            <*> json <|? time_l1Key
            <*> json <|? time_l2Key
            <*> json <|? time_l3Key
            
            <*> json <|? time_imgKey
            <*> json <|? time_start_dateKey
            <*> json <|? time_end_dateKey
            <*> json <|? btKey
    }
}

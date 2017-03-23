//
//  Friend.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/24/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//


import Argo
import Curry


struct Friend {
    
    static private let friendIdKey      = "id"
    static private let nameKey          = "name"
    static private let firstnameKey     = "firstname"
    static private let lastnameKey      = "lastname"
    static private let image_urlKey     = "image_url"
    static private let privateKey       = "private"
    static private let stoneKey         = "stone"
    static private let seenKey          = "seen_activity"
    static private let showKey          = "show_city"
    static private let homeKey          = "home_town"


    let friendId:       String
    let name:           String
    let firstname:      String?
    let lastname:       String?
    let image_url:      String?
    let privateFriend:  String?
    let stone:          String?
    let seen_activity:  Int?
    let show_city:      String?
    let home_town:      String?
}

// MARK: Decodable

extension Friend: Decodable {
    static func decode(json: JSON) -> Decoded<Friend> {
        return curry(Friend.init)
            <^> json <| friendIdKey
            <*> json <| nameKey
            <*> json <|? firstnameKey
            <*> json <|? lastnameKey
            <*> json <|? image_urlKey
            <*> json <|? privateKey
            <*> json <|? stoneKey
            <*> json <|? seenKey
            <*> json <|? showKey
            <*> json <|? homeKey
    }
}

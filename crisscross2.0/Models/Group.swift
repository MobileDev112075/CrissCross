//
//  Group.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/24/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//



import Argo
import Curry


struct Group {
    
    static private let groupIdKey   = "id"
    static private let titleKey     = "title"
    static private let usersIdsKey  = "ids"
    
    let groupId: String
    let title: String
    let usersIds: [String]

}

// MARK: Decodable

extension Group: Decodable {
    static func decode(json: JSON) -> Decoded<Group> {
        return curry(Group.init)
            <^> json <| groupIdKey
            <*> json <| titleKey
            <*> json <|| usersIdsKey
    }
}

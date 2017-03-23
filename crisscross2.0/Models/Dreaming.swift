//
//  Dreaming.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/23/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import Argo
import Curry
import ReactiveCocoa
import Result


struct Dreaming
{
    static private let db_id_Key        = "db_id"
    static private let id_Key           = "id"
    static private let title_Key        = "title"
    static private let reference_Key    = "reference"
    
    let db_id:      String
    let id_id:      String
    let title:      String
    let reference:  String
    
    
    static func contentMatches(lhs: Dreaming, _ rhs: Dreaming) -> Bool {
        return lhs.db_id == rhs.db_id
            && lhs.id_id == rhs.id_id
            && lhs.title == rhs.title
    }
}

extension Dreaming: Decodable
{
    static func decode(json: JSON) -> Decoded<Dreaming>
    {
        return curry(Dreaming.init)
            <^> json <| db_id_Key
            <*> json <| id_Key
            <*> json <| title_Key
            <*> json <| reference_Key
    }
}

// MARK: Equatable

extension Dreaming: Equatable {}

func ==(lhs: Dreaming, rhs: Dreaming) -> Bool {
    return lhs.db_id == rhs.db_id
}



// MARK: Encodable

extension Dreaming: Encodable {
    func encode() -> [String: AnyObject] {
        return [
            Dreaming.db_id_Key : db_id,
            Dreaming.id_Key : id_id,
            Dreaming.title_Key : title,
            Dreaming.reference_Key : reference
        ]
    }
}



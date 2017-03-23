//
//  Feedback.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/29/17.
//  Copyright © 2017 tycoon. All rights reserved.
//


import Argo
import Curry


struct Feedback {
    
    static private let createdKey = "created"
    static private let titleKey = "title"
    static private let imgKey = "img"
    static private let cidKey = "id"
    static private let locations_idKey = "locations_id"
    static private let commentKey = "comment"
    static private let ratingKey = "rating"
    static private let item_titleKey = "item_title"
    static private let category_idKey = "category_id"
    static private let users_idKey = "users_id"
    static private let users_imageKey = "users_image_url"
    static private let users_nameKey = "users_name"
    static private let custom_imgKey = "custom_img"

    let created: String
    let title: String
    let img: String
    let cid: String
    let locations_id: String
    let comment: String
    let rating: String
    let item_title: String
    let category_id: String
    let userId:String
    let users_image:String
    let users_name:String
    let custom_img:String?
    
    static func contentMatches (lhs: Feedback, _ rhs: Feedback) -> Bool {
        return lhs.created == rhs.created
            && lhs.title == rhs.title
            && lhs.img == rhs.img
            && lhs.cid == rhs.cid
            && lhs.locations_id == rhs.locations_id
            && lhs.comment == rhs.comment
            && lhs.rating == rhs.rating
            && lhs.item_title == rhs.item_title
            && lhs.category_id == rhs.category_id
    }
    
    static func contentMatches(lhs: [Feedback], _ rhs: [Feedback]) -> Bool {
        if lhs.count != rhs.count { return false }
        
        for (index, children) in lhs.enumerate() {
            if !contentMatches(rhs[index], children) {
                return false
            }
        }
        return true
    }
    
    var avatarURL: NSURL {
        let url =  NSURL(string: self.users_image)
        return url ?? NSURL()
    }
    
    var categoryFilter:String{
        switch Int(category_id)! {
        case 1: return "Eat"
        case 2: return "Breakfast"
        case 3: return "Brunch"
        case 4: return "Lunch"
        case 5: return "Dinner"
        case 6: return "Bites"
        case 7: return "Drink"
        case 8: return "Coffee"
        case 9: return "Beer"
        case 10: return "Wine"
        case 11: return "Cocktails"
        case 15: return "See"
        case 19: return "Sights"
        case 20: return "Secrets"
        case 21: return "Shops"
        case 22: return "Art"
        case 12: return "Sleep"
        case 13: return "Hotels"
        case 14: return "Hostels"
        default: return "See"
        }
    }
}

// MARK: Equatable

extension Feedback: Equatable {}

func ==(lhs: Feedback, rhs: Feedback) -> Bool {
    return lhs.created == rhs.created
}

// MARK: Decodable

extension Feedback: Decodable {
    static func decode(json: JSON) -> Decoded<Feedback> {
        return curry(Feedback.init)
            <^> json <| createdKey
            <*> json <| titleKey
            <*> json <| imgKey
            <*> json <| cidKey
            <*> json <| locations_idKey
            <*> json <| commentKey
            <*> json <| ratingKey
            <*> json <| item_titleKey
            <*> json <| category_idKey
            <*> json <| users_idKey
            <*> json <| users_imageKey
            <*> json <| users_nameKey
            <*> json <|? custom_imgKey
    }
}
// MARK: Encodable

extension Feedback: Encodable {
    func encode() -> [String: AnyObject] {
        return [
            Feedback.createdKey : created,
            Feedback.titleKey : title,
            Feedback.imgKey : img,
            Feedback.cidKey : cid,
            Feedback.locations_idKey : locations_id,
            Feedback.commentKey : comment,
            Feedback.ratingKey : rating,
            Feedback.item_titleKey : item_title,
            Feedback.category_idKey : category_id,
            Feedback.custom_imgKey : custom_img ?? ""
        ]
    }
}



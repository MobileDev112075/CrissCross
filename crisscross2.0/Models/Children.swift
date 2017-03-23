//
//  Bt.swift
//  RacCriss
//
//  Created by Daniel Karsh on 11/1/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import Curry

enum CategoryType:Int {
    case Eat = 1
    case Breakfast = 2
    case Brunch = 3
    case Lunch = 4
    case Dinner = 5
    case Bites = 6
    case Drink = 7
    case Coffee = 8
    case Beer = 9
    case Wine = 10
    case Cocktails = 11
    case See = 15
    case Sights = 19
    case Secrets = 20
    case Shops = 21
    case Art = 22
    case Sleep = 12
    case Hotels = 13
    case Hostels = 14
}

struct Children {
    
    static private let createdKey = "created"
    static private let titleKey = "title"
    static private let imgKey = "img"
    static private let cidKey = "id"
    static private let lidKey = "lid"
    static private let locations_idKey = "locations_id"
    static private let commentKey = "comment"
    static private let ratingKey = "rating"
    static private let item_titleKey = "item_title"
    static private let category_idKey = "category_id"
    static private let allIdsKey = "all_ids"
    static private let users_idKey = "users_id"
    static private let users_imageKey = "users_image_url"
    static private let users_nameKey = "users_name"

    let created: String
    let title: String
    let img: String
    let cid: String
    let lid: String?
    let locations_id: String
    let comment: String
    let rating: String
    let item_title: String
    let category_id: String
    var allIds:[String]?
    let userId:String?
    let users_image:String?
    let users_name:String?
    
    var imageURL: NSURL {
        return NSURL(string: self.img ?? "")!
    }
    
    
    var avatarURL: NSURL {
        return NSURL(string: self.users_image ?? "")!
    }
    
    var categoryString:CategoryType {
        return CategoryType(rawValue: Int(self.category_id)!)!
    }
    
    var categoryImage:UIImage{
        switch Int(category_id)! {
        case 1...6:
            return UIImage(named: "eat")!
        case 7...11:
            return UIImage(named: "drink")!
        case 12...14:
            return UIImage(named: "sleep")!
        case 15...22:
            return UIImage(named: "see")!
        default:
            return UIImage(named: "see")!
        }
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
    
    var masterFilter:String{
        switch Int(category_id)! {
        case 1...6:
            return "Eat"
        case 7...11:
            return "Drink"
        case 12...14:
            return "Sleep"
        case 15...22:
            return "See"
        default:
            return "See"
        }
    }


    static func contentMatches (lhs: Children, _ rhs: Children) -> Bool {
        return lhs.created == rhs.created
            && lhs.title == rhs.title
            && lhs.img == rhs.img
            && lhs.cid == rhs.cid
            && lhs.lid ?? "" == rhs.lid ?? ""
            && lhs.locations_id == rhs.locations_id
            && lhs.comment == rhs.comment
            && lhs.rating == rhs.rating
            && lhs.item_title == rhs.item_title
            && lhs.category_id == rhs.category_id
            && lhs.allIds ?? [] == rhs.allIds ?? []
    }
    
    static func contentMatches(lhs: [Children], _ rhs: [Children]) -> Bool {
        if lhs.count != rhs.count { return false }
        
        for (index, children) in lhs.enumerate() {
            if !contentMatches(rhs[index], children) {
                return false
            }
        }
        return true
    }
}

// MARK: Equatable

extension Children: Equatable {}

func ==(lhs: Children, rhs: Children) -> Bool {
    return lhs.created == rhs.created
}

// MARK: Decodable

extension Children: Decodable {
    static func decode(json: JSON) -> Decoded<Children> {
        return curry(Children.init)
            <^> json <| createdKey
            <*> json <| titleKey
            <*> json <| imgKey
            <*> json <| cidKey
            <*> json <|? lidKey
            <*> json <| locations_idKey
            <*> json <| commentKey
            <*> json <| ratingKey
            <*> json <| item_titleKey
            <*> json <| category_idKey
            <*> json <||? allIdsKey
            <*> json <|? users_idKey
            <*> json <|? users_imageKey
            <*> json <|? users_nameKey
    }
}
// MARK: Encodable

extension Children: Encodable {
    func encode() -> [String: AnyObject] {
        return [
            Children.createdKey : created,
            Children.titleKey : title,
            Children.imgKey : img,
            Children.cidKey : cid,
            Children.lidKey : lid ?? "",
            Children.locations_idKey : locations_id,
            Children.commentKey : comment,
            Children.ratingKey : rating,
            Children.item_titleKey : item_title,
            Children.category_idKey : category_id,
            Children.allIdsKey : allIds ?? []
        ]
    }
}



//
//  User.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/18/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import Curry

struct User {
    
    static private let identifierKey = "id"
    static private let emailKey = "email"
    static private let nameKey = "name"
    static private let usernameKey = "username"
    static private let firstnameKey = "firstname"
    static private let lastnameKey = "lastname"
    static private let tokenKey = "token"
    static private let show_cityKey = "show_city"
    static private let show_city_idKey = " show_city_id"
    static private let phoneKey = "phone"
    static private let current_cityKey = "current_city"
    static private let home_townKey = "home_town"
    static private let degreesKey = "degrees"
    static private let has_activityKey = "has_activity"
    static private let seen_activityKey = "seen_activity"
    static private let image_urlKey = "image_url"
    static private let dprivateKey = "private"
    static private let notificationsKey = "notifications"
    static private let friendsKey = "friends"
    static private let timelineKey = "timeline"
    static private let beenthereKey = "beenthere"

    let identifier: String
    let email: String?
    let name: String?
    let username: String?
    let firstname: String?
    let lastname: String?
    let token: String?
    let phone: String?
    let current_city: String?
    let home_town: String?
    let degrees: String?
    let has_activity: String?
    let seen_activity: String?
    let image_url: String?
    let dprivate: String?
    let notifications: String?
    let friends: [Friend]?
    let timelines: [Timeline]?
    let beenTheres:[Beenthere]?
//    let show_city: String?
//    let show_city_id: String?
}

// MARK: Decodable

extension User: Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return curry(User.init)
            <^> json <| identifierKey
            <*> json <|? emailKey
            <*> json <|? nameKey
            <*> json <|? usernameKey
            <*> json <|? firstnameKey
            <*> json <|? lastnameKey
            <*> json <|? tokenKey
            <*> json <|? phoneKey
            <*> json <|? current_cityKey
            <*> json <|? home_townKey
            <*> json <|? degreesKey
            <*> json <|? has_activityKey
            <*> json <|? seen_activityKey
            <*> json <|? image_urlKey
            <*> json <|? dprivateKey
            <*> json <|? notificationsKey
            <*> json <||? friendsKey
            <*> json <||? timelineKey
            <*> json <||? beenthereKey
//            <*> json <|? show_cityKey
//            <*> json <|? show_city_idKey
    }
}

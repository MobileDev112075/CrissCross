//
//  Login.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/20/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Foundation

import Argo
import Curry

struct Login {
    let plans: [AnyObject]
    let user: AnyObject
    
    static private let plansKey = "plans"
    static private let userKey = "user"
    
    init(user: AnyObject,plans:[AnyObject]) {
        self.plans = plans
        self.user = user
    }
}


// MARK: Decodable

//extension Login: Decodable {
//    static func decode(json: JSON) -> Decoded<Login> {
//        return curry(Login.init)
//            <^> json <| userKey
//            <*> json <|| plansKey
//}

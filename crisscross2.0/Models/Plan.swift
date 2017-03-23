//
//  Plan.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/24/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import Curry

enum AppPlanType:Int{
   case AppPlanTypeSure = 0
   case AppPlanTypeIf = 1
   case AppPlanTypeUpdate = 2
}



struct Plan {
    let planId: String
    let userId: String
    let planType: String
    let startDateInterval: String
    let endDateInterval: String
    let created: String
    let locationsId: String
    let how_id: String
    let kindOfPlanId: String
    let isViewableByAll: String
    let locations_title: String
    let photos: String
    let sharedWithGroupsIds: [String]
    let sharedWithUsersIds: [String]
    let title: String
    
    static private let planIdKey = "id"
    static private let userIdKey = "users_id"
    static private let planTypeKey = "plans_type_id"
    static private let start_dateKey = "start_date"
    static private let end_dateKey = "end_date"
    static private let createdKey = "created"
    static private let locationsIdKey = "locations_id"
    static private let how_idKey = "how_id"
    static private let kindOfPlanIdKey = "kind_of_types_id"
    static private let isViewableByAllKey = "viewable_by_all"
    static private let locations_titleKey = "locations_title"
    static private let photoKey = "photo"
    static private let photosKey = "photos"
    static private let sharedWithGroupsIdsKey = "shared_groups_id"
    static private let sharedWithUsersIdsKey = "shared_users_id"
    static private let titleKey = "title"
    
    // TODO: Decide if content matching should include identifier or not
    static func contentPlans(lhs: Plan, _ rhs: Plan) -> Bool {
        return lhs.planId == rhs.planId
            && lhs.userId == rhs.userId
            && lhs.planType == rhs.planType
            && lhs.startDateInterval == rhs.startDateInterval
            && lhs.endDateInterval == rhs.endDateInterval
            && lhs.created == rhs.created
            && lhs.locationsId == rhs.locationsId
            && lhs.how_id == rhs.how_id
            && lhs.kindOfPlanId == rhs.kindOfPlanId
            && lhs.isViewableByAll == rhs.isViewableByAll
            && lhs.locations_title == rhs.locations_title
            && lhs.photos == rhs.photos
            && lhs.sharedWithGroupsIds == rhs.sharedWithGroupsIds
            && lhs.sharedWithUsersIds == rhs.sharedWithUsersIds
           && lhs.title == rhs.title
    }
}

// MARK: Equatable

extension Plan: Equatable {}

func ==(lhs: Plan, rhs: Plan) -> Bool {
    return lhs.planId == rhs.planId
}

// MARK: Decodable

extension Plan: Decodable {
    static func decode(json: JSON) -> Decoded<Plan> {
        return curry(Plan.init)
            <^> json <| planIdKey
            <*> json <| userIdKey
            <*> json <| planTypeKey
            <*> json <| start_dateKey
            <*> json <| end_dateKey
            <*> json <| createdKey
            <*> json <| locationsIdKey
            <*> json <| how_idKey
            <*> json <| kindOfPlanIdKey
            <*> json <| isViewableByAllKey
            <*> json <| locations_titleKey
            <*> json <| photosKey
            <*> json <|| sharedWithGroupsIdsKey
            <*> json <|| sharedWithUsersIdsKey
            <*> json <| titleKey
    }
}

// MARK: Encodable

extension Plan: Encodable {
    func encode() -> [String: AnyObject] {
        return [
            Plan.planIdKey : planId,
            Plan.userIdKey : userId,
            Plan.planTypeKey : planType,
            Plan.start_dateKey : startDateInterval,
            Plan.end_dateKey : endDateInterval,
            Plan.createdKey : created,
            Plan.locationsIdKey : locationsId,
            Plan.how_idKey : how_id,
            Plan.kindOfPlanIdKey : kindOfPlanId,
            Plan.isViewableByAllKey : isViewableByAll,
            Plan.locations_titleKey : locations_title,
            Plan.photosKey : photos,
            Plan.sharedWithGroupsIdsKey :sharedWithGroupsIds,
            Plan.sharedWithUsersIdsKey : sharedWithUsersIds,
            Plan.titleKey : title
        ]
    }
}





//
//  SuggCellViewModel.swift
//  RacCriss
//
//  Created by tycoon on 11/16/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import Result
import Alamofire
import AlamofireImage
import ReactiveCocoa

class FeedbackCellModel {
    
    var feedback: Feedback
    let imageCache = Shared.MyInfo.imageCache
    
    init(feedback:Feedback) {
        self.feedback = feedback
    }
    
    var comment: String {
        return feedback.comment
    }
    
    var types:String {
        return feedback.categoryFilter
    }
    
    var name: String {
        return feedback.users_name
    }
    
    var avatar: SignalProducer<(UIImage,String), NSError> {
        let avIds = (feedback.userId,feedback.avatarURL,feedback.users_name)
        let av = AvatarCall(userIDs: avIds)
        return av.fetchCircleAvatarSignal()
    }

    func goProfile() {
        let friend = Friend(friendId: feedback.userId, name: feedback.users_name, firstname: "", lastname: "", image_url: feedback.users_image, privateFriend: "", stone: "", seen_activity: 0, show_city: "", home_town: "")
            Shared.MyInfo.showFriendsTree.value.append(friend)
    }
    
    func writeSugg() {
        
    }
}

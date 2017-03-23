//
//  ProfileViewModel.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import ReactiveCocoa
import Result
import Alamofire

class ProfileViewModel:DKViewModel  {
    
    private var uid: String = Shared.MyInfo.myIdentifier
    // Inputs
    
    // Outputs
   
    var profileName:        String = ""
    var profileLocation:    String = ""
    var profileAvatar:      UIImage? = nil
    
    let profileUser =       MutableProperty<User?>(nil)
    let friendsIsValid =    MutableProperty(false)
    let dreqamIsValid =     MutableProperty(false)
    let plansIsValid =      MutableProperty(false)
    let timeIsValid =       MutableProperty(false)
    let suggIsValid =       MutableProperty(false)
    
    override init(store: StoreType) {
        
        super.init(store: store)
        
        self.title  = "My Profile"
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)


        Shared.MyInfo.showFriendsTree.producer
            .filter({ (friends) -> Bool in
                friends.count>0
            })
            .map({ (friends) -> Friend in
                friends.last!
            })
            .startWithNext { (friend) in
                
                self.profileAvatar = Shared.MyInfo.imageCache.imageWithIdentifier("\(friend.friendId)")
                self.uid = friend.friendId
                self.profileName = friend.name
                self.profileLocation = friend.home_town ?? ""
                self.refreshObserver.sendNext()
                
                Shared.MyInfo.localStore
                    .fetchUser(friend.friendId)
                    .on{ user in
                        if let user = user {
                            self.profileUser.swap(user)
                        }else{
                            self.myStore.fetchUser(friend.friendId)
                                .on{ user in
                                    if let user = user {
                                        Shared.MyInfo.localStore.saveUser(user)
                                        self.profileUser.swap(user)
                                    }
                                }.start()
                        }
                    }.start()
                
        }
        
        Shared.MyInfo.showFriendsTree.producer
            .filter({ (friends) -> Bool in
                friends.count==0
            })
            .startWithNext { _ in
                self.profileUser.swap(Shared.MyInfo.myLoginUser.value!)
        }
        
        self.profileUser.producer
            .ignoreNil()
            .startWithNext { (user) in
                
                self.profileLocation    = user.home_town ?? ""
                self.profileName        = user.name ?? ""
                self.uid                = user.identifier
                
                if let friends = user.friends {
                    self.friendsIsValid.swap(friends.count > 0)
                    Shared.MyInfo.showUserFriends.swap(friends)
                }
                
                if let times = user.timelines {
                    self.friendsIsValid.swap(times.count > 0)
                }
                
                let imageRequest = Alamofire.request(.GET, user.image_url ?? "")
                imageRequest.responseImage { response in
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        let circleImage = image
                        Shared.MyInfo.imageCache.addImage(circleImage, withIdentifier:"\(user.identifier)")
                        self.profileAvatar = circleImage
                        self.refreshObserver.sendNext()
                    }
                }
                
        }
    }
    
    func dismiss(){
        var friendsTree =  Shared.MyInfo.showFriendsTree.value
        if friendsTree.count > 0 {
            friendsTree.removeLast()
            Shared.MyInfo.showFriendsTree.swap(friendsTree)
        }
        else{
            Shared.MyInfo.showUserFriends.swap(Shared.MyInfo.myClose)
        }
    }
}

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

class FriendCellViewModel {
    
    var friend: Friend
    let imageCache = Shared.MyInfo.imageCache
    
    init(friend:Friend) {
        self.friend = friend
    }
    
    var first: String {
        return friend.firstname ?? ""
    }
    
    var last: String {
        return friend.lastname ?? ""
    }
    

    func fetchImageSignal() -> SignalProducer<UIImage, NSError> {
        return SignalProducer { observer, disposable in
            let imageCache = Shared.MyInfo.imageCache
            let cachedBackground = imageCache.imageWithIdentifier(self.friend.friendId)
            if let cachedBackground = cachedBackground {
                observer.sendNext(cachedBackground)
                observer.sendCompleted()
            }else{
                let imageRequest = Alamofire.request(.GET, self.friend.image_url ?? "")
                imageRequest.responseImage { response in
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        let circleImage = image.af_imageAspectScaledToFillSize(CGSizeMake(40,40)).af_imageRoundedIntoCircle()
                        imageCache.addImage(circleImage, withIdentifier:self.friend.friendId)
                        observer.sendNext(circleImage)
                        observer.sendCompleted()
                    } else {
                        observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None))
                    }
                }
            }
        }
    }
}

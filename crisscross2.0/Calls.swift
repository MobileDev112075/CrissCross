//
//  Avatar.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/31/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import Argo
import Result
import Alamofire
import AlamofireImage
import ReactiveCocoa

class AvatarCall {
    
    let userID:String
    let avatarURL:NSURL
    let userName:String
    
    init(userIDs:(String,NSURL,String)) {
        userID = userIDs.0
        avatarURL = userIDs.1
        userName = userIDs.2
    }
    
    func fetchCircleAvatarSignal() -> SignalProducer<(UIImage,String), NSError> {
        return SignalProducer { observer, disposable in
            let imageCache = Shared.MyInfo.imageCache
            if let cachedAvatar = imageCache.imageWithIdentifier(self.userID){
                let aspectScaledToFitImage = cachedAvatar.af_imageAspectScaledToFillSize(CGSizeMake(40,40)).af_imageRoundedIntoCircle()
                observer.sendNext(aspectScaledToFitImage, self.userName)
                observer.sendCompleted()
            }else{
                Alamofire.request(.GET, self.avatarURL)
                    .responseImage { response in
                        if let error = response.result.error {
                            observer.sendFailed(error)
                        }
                        else if let image = response.result.value {
                            print("image downloaded: \(image)")
                            imageCache.addImage(image, withIdentifier: self.userID)
                            
                            let aspectScaledToFitImage = image.af_imageAspectScaledToFillSize(CGSizeMake(40,40)).af_imageRoundedIntoCircle()
                            observer.sendNext(aspectScaledToFitImage, self.userName)
                            observer.sendCompleted()
                        }
                }
            }
        }
    }
    
    func fetchFullAvatarSignal() -> SignalProducer<(UIImage,String), NSError> {
        return SignalProducer { observer, disposable in
            let imageCache = Shared.MyInfo.imageCache
            if let cachedAvatar = imageCache.imageWithIdentifier(self.userID){
                observer.sendNext(cachedAvatar, self.userName)
                observer.sendCompleted()
            }else{
                Alamofire.request(.GET, self.avatarURL)
                    .responseImage { response in
                        if let error = response.result.error {
                            observer.sendFailed(error)
                        }
                        else if let image = response.result.value {
                            print("image downloaded: \(image)")
                            imageCache.addImage(image, withIdentifier: self.userID)
                            observer.sendNext(image, self.userName)
                            observer.sendCompleted()
                        }
                }
            }
        }
    }
    
}

class BackgroundImage {
    
    let child:Children
    init(child:Children) {
        self.child = child
    }
    
    func fetchImageSignal() -> SignalProducer<UIImage, NSError> {
        return SignalProducer { observer, disposable in
            let imageCache = Shared.MyInfo.imageCache
            let cachedBackground = imageCache.imageWithIdentifier(self.child.cid)
            if let cachedBackground = cachedBackground {
                observer.sendNext(cachedBackground)
                observer.sendCompleted()
            }else{
                let imageRequest = Alamofire.request(.GET, self.child.imageURL)
                imageRequest.responseImage { response in
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        imageCache.addImage(image, withIdentifier:self.child.cid)
                        observer.sendNext(image)
                        observer.sendCompleted()
                    } else {
                        observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None))
                    }
                }
            }
        }
    }
    
}

class BackgroundItinImage {
    
    let itin:Itin
    init(itin:Itin) {
        self.itin = itin
    }
    
    func fetchInitImageSignal() -> SignalProducer<UIImage, NSError> {
        return SignalProducer { observer, disposable in
            let imageCache = Shared.MyInfo.imageCache
            if let img_url = self.itin.img_url {
                let cachedBackground = imageCache.imageWithIdentifier(img_url)
                if let cachedBackground = cachedBackground {
                    observer.sendNext(cachedBackground)
                    observer.sendCompleted()
                }else{
                    let imageRequest = Alamofire.request(.GET, self.itin.imageURL)
                    imageRequest.responseImage { response in
                        if let image = response.result.value {
                            print("image downloaded: \(image)")
                            imageCache.addImage(image, withIdentifier:self.itin.img_url!)
                            observer.sendNext(image)
                            observer.sendCompleted()
                        } else {
                            observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None))
                        }
                    }
                }
            }else{
                observer.sendCompleted()
            }
        }
    }
}

class FeedbackCall {
    
    let child:Children
    init(child:Children) {
        self.child = child
    }
    
    func fetchFeedbackSignal() -> SignalProducer<[Feedback], NoError> {
        return SignalProducer { observer, disposable in
            let contain = Shared.MyInfo.feedbackCache.contains{$0.0 == self.child.cid}
            if contain , let oldfeed = Shared.MyInfo.feedbackCache[self.child.cid]
            {
                observer.sendNext(oldfeed)
            }else {
                Shared.MyInfo.store.fetchFeedback(self.child)
                    .startWithResult({ (result) in
                        switch result {
                        case let .Success(feeds):
                            if let feed = feeds.first
                            {
                                Shared.MyInfo.feedbackCache[feed.cid]=feeds
                            }
                            observer.sendNext(feeds)
                            observer.sendCompleted()
                        case .Failure:
                            observer.sendCompleted()
                        }
                    })
            }
        }
    }
}

class AvatarFromChildren {
    
    let child:Children
    init(child:Children) {
        self.child = child
    }
    
    func fetchCircleAvatarSignal() -> SignalProducer<(UIImage,String), NSError> {
        return FeedbackCall(child: self.child).fetchFeedbackSignal()
            .flatMap(.Latest, transform: { (feeds) -> SignalProducer<(UIImage,String), NSError> in
                if let feedback = feeds.first {
                    let avIds = (feedback.userId,feedback.avatarURL,feedback.users_name)
                    let av = AvatarCall(userIDs: avIds)
                    return av.fetchCircleAvatarSignal()
                }else{
                    return SignalProducer.empty
                }
            })
    }
}


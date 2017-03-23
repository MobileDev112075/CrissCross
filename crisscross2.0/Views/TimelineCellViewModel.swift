//
//  TimeCellViewModel
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

class TimelineCellViewModel {
    
    var timeline: Timeline
    let imageCache = Shared.MyInfo.imageCache
    
    init(timeline:Timeline) {
        self.timeline = timeline
    }
    
    var title: String {
        return timeline.time_l1 ?? ""
    }
    
    var item_title: String {
        return timeline.time_l2 ?? ""
    }
    
    var timeC: String {
        return timeline.time_l3 ?? ""
    }
    
    var imageURL:NSURL {
        return timeline.imageURL
    }
    

    
//    private func fetchFeedbackSignal() -> SignalProducer<Children, NoError> {
//        return SignalProducer {[weak self] observer, disposable in
//           let contain = Shared.MyInfo.feedChildrens.contains{$0.0 == self?.child.cid}
//            if contain , let oldfeed = Shared.MyInfo.feedChildrens[(self?.child.cid)!]
//            {
//                observer.sendNext(oldfeed)
//            }else if let fid = self?.child.allIds?.first {
//                Shared.MyInfo.store.fetchFeedback(fid)
//                    .startWithResult({ (result) in
//                        switch result {
//                        case let .Success(feeds):
//                            if let feed = feeds.first,
//                                let _ = feed.users_image
//                            {
//                                Shared.MyInfo.feedChildrens[feed.cid]=feed
//                                observer.sendNext(feed)
//                                observer.sendCompleted()
//                            }
//                        case .Failure:
//                            observer.sendCompleted()
//                        }
//                    })
//            }
//        }
//    }
//    
    
    func fetchImageSignal() -> SignalProducer<UIImage, NSError> {
        return SignalProducer { observer, disposable in
            let imageCache = Shared.MyInfo.imageCache
            let imageRequest = Alamofire.request(.GET, self.timeline.imageURL)
            let cachedBackground = imageCache.imageWithIdentifier(self.timeline.time_img!)
            if let cachedBackground = cachedBackground {
                observer.sendNext(cachedBackground)
                observer.sendCompleted()
            }else{
                imageRequest.responseImage { response in
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        imageCache.addImage(image, withIdentifier:self.timeline.time_img!)
                        observer.sendNext(image)
                        observer.sendCompleted()
                    } else {
                        observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None))
                    }
                }
            }
        }
    }
    
//    func fetchAvatarSignal() -> SignalProducer<(UIImage,String), NSError> {
//        return SignalProducer { observer, disposable in
//            self.fetchFeedbackSignal().startWithNext { (feed) in
//                let imageCache = Shared.MyInfo.imageCache
//                let cachedAvatar = imageCache.imageWithIdentifier(feed.users_name!)
//                if let cachedAvatar = cachedAvatar {
//                    observer.sendNext(cachedAvatar, feed.users_name!)
//                    observer.sendCompleted()
//                }else{
//                    Alamofire.request(.GET, feed.avatarURL)
//                        .responseImage { response in
//                            if let image = response.result.value {
//                                print("image downloaded: \(image)")
//                                let aspectScaledToFitImage = image.af_imageAspectScaledToFillSize(CGSizeMake(40,40)).af_imageRoundedIntoCircle()
//                                imageCache.addImage(aspectScaledToFitImage, withIdentifier: feed.userId!)
//                                observer.sendNext(aspectScaledToFitImage, feed.users_name!)
//                                observer.sendCompleted()
//                            } else {
//                                observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None))
//                            }
//                    }
//                }
//            }
//        }
//    }
}

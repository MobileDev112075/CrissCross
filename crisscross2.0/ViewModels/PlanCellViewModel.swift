//
//  PlanCellViewModel.swift
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

class PlanCellViewModel {
    
    let plan: Plan
    let image: UIImage?
    
    init(plan:Plan, image:UIImage?) {
        self.plan = plan
        self.image = image
    }

    var title: String {
        return plan.title
    }
    
    var item_title: String {
        return plan.locations_title
    }
    

    var timeC: String {
        return plan.created
    }
    
//    private func fetchFeedbackSignal() -> SignalProducer<Children, NoError> {
//        return SignalProducer {[weak self] observer, disposable in
//            if let fid = self?.child.allIds?.first
//            {
//                Shared.MyInfo.store.fetchFeedback(fid)
//                    .startWithResult({ (result) in
//                        switch result {
//                        case let .Success(feeds):
//                            if let feed = feeds.first,
//                                let _ = feed.users_image
//                            {
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
    
    
    
//    func fetchImageSignal() -> SignalProducer<UIImage, NSError> {
//        return SignalProducer { observer, disposable in
//            Alamofire.request(.GET, self.plan.imageURL)
//                .responseImage { response in
//                    if let image = response.result.value {
//                        print("image downloaded: \(image)")
//                        observer.sendNext(image) //send the fetched image on the signal
//                        observer.sendCompleted()
//                    } else {
//                        observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None)) //send your error
//                    }
//            }
//        }
//    }
    
//    func fetchAvatarSignal() -> SignalProducer<(UIImage,String), NSError> {
//        return SignalProducer { observer, disposable in
//            self.fetchFeedbackSignal().startWithNext { (feed) in
//                Alamofire.request(.GET, feed.avatarURL)
//                    .responseImage { response in
//                        if let image = response.result.value {
//                            print("image downloaded: \(image)")
//                            observer.sendNext((image, feed.users_name!))//send the fetched image on the signal
//                            observer.sendCompleted()
//                        } else {
//                            observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None)) //send your error
//                        }
//                }
//            }
//        }
//    }
}

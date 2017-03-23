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

class LocationCellViewModel {
    
    let location: Location
    let city: Bool
    
    init(location:Location, city:Bool) {
        self.location = location
        self.city = city
    }
    
    var title: String {
        if city {
            return location.city()
        }
        return location.country()
    }
    
    func fetchImageSignal() -> SignalProducer<UIImage, NSError> {
        return SignalProducer { observer, disposable in
            Alamofire.request(.GET, self.location.beenthere.children![0].imageURL)
                .responseImage { response in
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        observer.sendNext(image) //send the fetched image on the signal
                        observer.sendCompleted()
                    } else {
                        observer.sendFailed( NSError(domain: "", code: 0, userInfo: .None)) //send your error
                    }
            }
        }
    }
}

    

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

class WelcomeSuggModel {
    
    var itin: Itin
    let imageCache = Shared.MyInfo.imageCache
    
    init(itin:Itin) {
        self.itin = itin
    }
    
    var title: String {
        return itin.byline ?? ""
    }
    
    var action: String {
        return itin.title ?? ""
    }

    var imageURL:NSURL {
        return itin.imageURL
    }
    
    var backImage: SignalProducer<(UIImage), NSError> {
        return BackgroundItinImage(itin:itin).fetchInitImageSignal()
    }
}

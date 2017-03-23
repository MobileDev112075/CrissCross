//
//  SuggCellViewModel.swift
//  RacCriss
//
//  Created by tycoon on 11/16/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.

import Argo
import Result
import Alamofire
import AlamofireImage
import ReactiveCocoa

class  SuggCellViewModel {
    
    var child: Children
    
    let imageCache = Shared.MyInfo.imageCache
    
    init(child:Children) {
        self.child = child
    }
    
    var title: String {
        return child.title
    }
    
    var item_title: String {
        return child.item_title
    }
    
    var timeC: String {
        return child.created
    }
    
    var imageURL:NSURL {
        return child.imageURL
    }
    
    var categoryType:String {
        return "\(child.categoryString)"
    }
    
    var categoryImage:UIImage{
        return child.categoryImage
    }
    
    var avatar: SignalProducer<(UIImage,String), NSError> {
        return AvatarFromChildren(child: child).fetchCircleAvatarSignal()
    }
    
    var backImage: SignalProducer<(UIImage), NSError> {
        return BackgroundImage(child: child).fetchImageSignal()
    }
    
}


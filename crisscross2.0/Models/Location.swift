//
//  Location.swift
//  crisscross2.0
//
//  Created by tycoon on 11/22/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import GooglePlaces
import CoreLocation
import UIKit

struct Location {
    
    let beenthere:Beenthere
    let place:GMSPlace
    
    func distanceFromMyLocation() -> CLLocationDistance {
        let clocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        if let loca = Shared.MyInfo.myLocation.value {
            return clocation.distanceFromLocation(loca)
        }
        return clocation.distanceFromLocation(CLLocation(latitude: 40.7164069, longitude: -74.0152577))
    }
    
    func city() -> String {
        if let ad = place.addressComponents
        {
            let city =
            ad.filter({ (addressComponent) -> Bool in
               return addressComponent.type == "locality"
            }).map({ (addressComponent) -> String in
               return addressComponent.name
            })
            if let city = city.first {
                return city
            }
        }
        return place.name
    }
    
    func country() -> String {
        if let ad = place.addressComponents
        {
            let city =
                ad.filter({ (addressComponent) -> Bool in
                    return addressComponent.type == "country"
                }).map({ (addressComponent) -> String in
                    return addressComponent.name
                })
            if let city = city.first {
                return city
            }
        }
        return place.name
    }
}

class LocationChild{
    var child:Children
    let place:GMSPlace?
    
    init(child:Children) {
        self.child = child
        self.place = nil
    }
    
    init(child:Children, place:GMSPlace) {
        self.child = child
        self.place = place
    }
}

struct LocationImage {
    let plan:Plan
    var image:UIImage?
    let photoMetadata:GMSPlacePhotoMetadataList
    
    mutating func setImage(limage:UIImage) {
        self.image = limage
    }
}


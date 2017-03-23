//
//  LocationManager.swift
//  crisscross2.0
//
//  Created by tycoon on 11/22/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import Argo
import ReactiveCocoa
import CoreLocation
import Result
import GooglePlaces
import GoogleMaps


import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
static let sharedInstance = LocationManager()
    
    var clManager: CLLocationManager?
    var currentLocation: CLLocation?
    var currentCity = ""
    var countryCode = ""
    var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        
        GMSServices.provideAPIKey("AIzaSyD2IwAA827Ag0bObCeFUOuAA816X41rjRU")
        GMSPlacesClient.provideAPIKey("AIzaSyD2IwAA827Ag0bObCeFUOuAA816X41rjRU")
        
        self.clManager = CLLocationManager()
        guard let locationManager = self.clManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            // you have 2 choice
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 200 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.clManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.clManager?.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last(current) location
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (places , error ) in
            if let placemark = places?[0]
            {
                self.currentCity = placemark.locality ?? ""
                self.countryCode = placemark.ISOcountryCode ?? ""
                Shared.MyInfo.myLocation.swap(location)
            }
        }
        self.currentLocation = location
       
        // use for real time update location
        updateLocation(location)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        // do on error
        updateLocationDidFailWithError(error)
    }
    
    // Private function
    private func updateLocation(currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error)
    }
}



//class LocationManager: NSObject {
//    
//    
//    
//    
//    func myLocation()// ->  Signal<CLLocation, NoError> {
//    {
//
//        Shared.MyInfo.myLocation.value = CLLocation(latitude: 40.7164069, longitude: -74.0152577)
////        CLGeocoder().reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error:NSError?) in
////            if let placemark = placemarks?[0]{
////                let locality = placemark.locality
////                let countryCode = placemark
////            }
////        }
//        
//        let placeID = "ChIJn8o2UZ4HbUcRRluiUYrlwv0"
//        let placesClient = GMSPlacesClient.sharedClient()
//        placesClient.lookUpPlaceID(placeID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
//            if let error = error {
//                print("lookup place id query error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let place = place {
//                print("Place name \(place.name)")
//                print("Place address \(place.formattedAddress)")
//                print("Place placeID \(place.placeID)")
//                print("Place attributions \(place.attributions)")
//            } else {
//                print("No place details for \(placeID)")
//            }
//        })
//    }
////    _lastUserLocation = newLocation.coordinate;
////    [_locationManager stopUpdatingLocation];
////
////    CLLocation *location = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
////    
////    [_loadingScreen removeFromSuperview];
////    
////    CLGeocoder *CLGeocoder = [[CLGeocoder alloc] init];
////    [geocoder reverseGeocodeLocation:location completionHandler:
////    ^(NSArray* placemarks, NSError* error){
////    [_loadingScreen removeFromSuperview];
////    
////    if([placemarks count]) {
////    CLPlacemark *placemark = [placemarks objectAtIndex:0];
////    NSString *locality = [NSString stringWithFormat:@"%@",placemark.locality];
////    NSString *countryCode = [NSString stringWithFormat:@"%@",placemark.ISOcountryCode];
////    
////    [self getWeather:locality andISO:countryCode];
////    }else{
////    [self getWeather:@"" andISO:@""];
////    }
////    
////    
////    
////    }];
//
//}

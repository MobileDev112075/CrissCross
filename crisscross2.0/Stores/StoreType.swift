//
//  StoreType.swift
//  RacCriss
//
//  Created by Daniel Karsh on 30/12/15.
//  Copyright © 2015 Daniel Karsh. All rights reserved.
//

import ReactiveCocoa
import GooglePlaces


struct TokenParameters {
    let token: String
}

struct LoginParameters {
    let email: String
    let pass: String
}



struct MatchParameters {
    let homePlayers: Set<Player>
    let awayPlayers: Set<Player>
    let homeGoals: Int
    let awayGoals: Int
}

protocol StoreType {
    
    // User
    func loginUser(parameters:LoginParameters) -> SignalProducer<(NSData,NSURLResponse),NSError> 
    func loginToken(token: String) -> SignalProducer<(NSData,NSURLResponse),NSError>
    func fetchToken() -> SignalProducer<String, NSError>
    func fetchUser(uid:String!) -> SignalProducer<User?, NSError> 
    func fetchImage(imageURL:NSURL) -> SignalProducer<UIImage, NSError>
    
    // MARK: - CoreLocation -> locationID -> CLLocation
    
    func fetchGPlaceChild(child:Children)   -> SignalProducer<LocationChild, NSError>
    func fetchGPlace(beens:[Beenthere])     -> SignalProducer<[Location], NSError>
    func fetchGPlaceImageD(locals:[LocationImage]) -> SignalProducer<Void, NSError>
    func fetchGPlaceImageMeta(plans:[Plan]) -> SignalProducer<[LocationImage], NSError>
    func fetchGPlaceAutocomplete(child: Children) -> SignalProducer<LocationChild, NSError>
    func fetchImagesSingleGPlace(place:GMSPlace) -> SignalProducer<UIImage, NSError>
    func fetchGPlaceAutoComp(str:String, bounds: GMSCoordinateBounds?, filter:GMSAutocompleteFilter?) -> SignalProducer<[GMSAutocompletePrediction], NSError>
    func lookUpPlaceID(str:String) -> SignalProducer<GMSPlace, NSError>
    func fetchGPlaceAutoCompSelected(strSearch:String,pred:GMSAutocompletePrediction) -> SignalProducer<[GMSAutocompletePrediction], NSError>
    // MARK: - Welcome
    func fetchWelcome(dict:[String:String]) -> SignalProducer<([Itin],[Friend]),NSError>
    // MARK: - Plans
    func fetchPlans() -> SignalProducer<[Plan], NSError>
    func savePlan(dict:[String:String]) -> SignalProducer<[Plan], NSError>
    
    // MARK: - Suggestions(btdt)
    func editSaveSugg (parameters:[String:String],image:UIImage?) -> SignalProducer<String, NSError>
    func filterSugg() -> SignalProducer<[String:[FilterModel]],NSError>
    func fetchSugg() -> SignalProducer<[Beenthere], NSError>
    func fetchSuggByLocation(locationID:String) -> SignalProducer<[NearMe], NSError>
    func fetchFeedback(chld:Children) -> SignalProducer<[Feedback], NSError>
    func fetchGroups() -> SignalProducer<[Group], NSError> 
    //-> SignalProducer<Void, NSError>
    
    // MARK: - Dream
    func fetchDream() -> SignalProducer<[Dreaming], NSError>
//    func savePlan(dict:[String:String]) -> SignalProducer<[Plan], NSError>
    
    // Matches
    func fetchMatches() -> SignalProducer<[Match], NSError>
    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError>
    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError>
    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError>

    // Players
    func fetchPlayers() -> SignalProducer<[Player], NSError>
    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError>

    // Rankings
    func fetchRankings() -> SignalProducer<[Ranking], NSError>
}

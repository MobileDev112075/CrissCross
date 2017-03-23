//
//  Store.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/05/15.
//  Copyright (c) 2015 Daniel Karsh. All rights reserved.
//

import Argo
import ReactiveCocoa
import GooglePlaces
import CoreLocation
import Alamofire

extension Dictionary {
    func merge(dict: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var mutableCopy = self
        for (key, value) in dict {
            // If both dictionaries have a value for same key, the value of the other dictionary is used.
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}

class RemoteStore: StoreType {
    
    enum RequestMethod {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    private let baseURL: NSURL
    private let loginUserPass: NSURL
    private let loginTokenURL: NSURL
    private let getUserURL:NSURL
    private let getSuggURL:NSURL
    private let getPlansURL:NSURL
    private let getDreamsURL:NSURL
    
    private let getGroupsURL:NSURL
    private let getFeedbackURL: NSURL
    private let getEditFeedbackURL: NSURL
    private let getBTDTSuggetionsURL: NSURL
    private let getWeatherURL: NSURL
    
    private let savePlanURL:NSURL
    private let matchesURL: NSURL
    private let playersURL: NSURL
    private let rankingsURL: NSURL
    
    // MARK: Lifecycle
    
    init(baseURL: NSURL) {
        self.baseURL = baseURL
        self.loginUserPass      = NSURL(string: "login/?v=11", relativeToURL: baseURL)!
        self.loginTokenURL      = NSURL(string: "loginWithToken/?v=11", relativeToURL: baseURL)!
        
        self.getUserURL         = NSURL(string: "getUser/?v=11", relativeToURL: baseURL)!
        self.getPlansURL        = NSURL(string: "getPlans/?v=11", relativeToURL: baseURL)!
        self.getGroupsURL       = NSURL(string: "getAllGroups/?v=11", relativeToURL: baseURL)!
        self.getWeatherURL      = NSURL(string: "getWeather/?v=11", relativeToURL: baseURL)!
        
        self.getDreamsURL       = NSURL(string: "dreamingOfEdit/?v=11", relativeToURL: baseURL)!
        
        self.getSuggURL             = NSURL(string: "communalBTDT/?v=11", relativeToURL: baseURL)!
        self.getFeedbackURL         = NSURL(string: "communalBTDTFeedback/?v=11", relativeToURL: baseURL)!
        self.getEditFeedbackURL     = NSURL(string: "beenThereDoneThatEdit/?v=11", relativeToURL: baseURL)!
        self.getBTDTSuggetionsURL   = NSURL(string: "getBTDTSuggetions/?v=11", relativeToURL: baseURL)!
        self.savePlanURL            = NSURL(string: "savingPlans/?v=11",relativeToURL: baseURL)!
        
        self.matchesURL         = NSURL(string: "matches", relativeToURL: baseURL)!
        self.playersURL         = NSURL(string: "players", relativeToURL: baseURL)!
        self.rankingsURL        = NSURL(string: "rankings", relativeToURL: baseURL)!
    }
    
    // MARK: User
    
    func loginUser(parameters: LoginParameters) -> SignalProducer<(NSData,NSURLResponse),NSError> {
        let request = mutableRequestWithURL(loginUserPass, method: .POST)
        request.HTTPBody = httpBodyForLoginParameters(parameters)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .flatMapError { error in
                print("Network error occurred: \(error)")
                return SignalProducer.empty
        }
    }
    
    
    func loginToken(token: String) -> SignalProducer<(NSData,NSURLResponse),NSError> {
        let request = mutableRequestWithURL(loginTokenURL, method: .POST)
        request.HTTPBody = httpBodyForUserParameters(token)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .flatMapError { error in
                print("Network error occurred: \(error)")
                return SignalProducer.empty
        }
    }
    
    func fetchToken() -> SignalProducer<String, NSError> {
        return SignalProducer.empty
    }
    
    
    func fetchUser(uid:String!) -> SignalProducer<User?, NSError> {
        let request = mutableRequestWithURL(getUserURL, method: .POST)
        request.HTTPBody = httpBodyForAPIcall(Shared.MyInfo.myToken,uid:uid)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .map { data, response in
                if  let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let user:User? = decode(json["user"]) {
                    return user
                } else {
                    return nil
                }
        }
    }
    
    // MARK: - Image
    func fetchImage(imageURL:NSURL) -> SignalProducer<UIImage, NSError> {
        let request = mutableRequestWithURL(imageURL, method: .GET)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if data.length > 0 ,
                    let image = UIImage(data: data)
                {
                    return image
                } else {
                    // In this when data is nil or empty then we can assign a placeholder image
                    return UIImage(imageLiteral:"")
                }
        }
    }
    
    // MARK: - Suggestions(btdt)
    
    
    func editSaveSugg (parameters:[String:String],image:UIImage?) -> SignalProducer<String, NSError>{
        return SignalProducer { observer, disposable in
        let URL = "https://m.crisscrosstheapp.com/api//beenThereDoneThatEdit/?v=11"

        Alamofire.upload(.POST, URL, multipartFormData: {
            multipartFormData in
            if let image = image ,
                let imageData = UIImageJPEGRepresentation(image, 1.0) {
                multipartFormData.appendBodyPart(data: imageData, name: "file", fileName: "banner.jpg", mimeType: "image/jpeg")
            }
            for (key, value) in parameters {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            }, encodingCompletion: {
                encodingResult in
  
                switch encodingResult {
                case .Success(let upload, _, _):
                    print("s")
                    upload.responseJSON { response in
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result)   // result of response serialization
                        if let data = response.data,
                            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                            let item:Item =  decode(json["item"]) {
                            observer.sendNext(item.tid)
                            observer.sendCompleted()
                            disposable.dispose()

                        }else{
                            observer.sendFailed(NSError(domain: "", code: 1, userInfo: nil))
                            observer.sendCompleted()
                            disposable.dispose()
                        }

                        
    
                    }
                    
                case .Failure(let encodingError):
                    observer.sendFailed(NSError(domain: "", code: 1, userInfo: nil))
                    observer.sendCompleted()
                    disposable.dispose()
                    print(encodingError)
                }
        })
        }
    }

    
    func fetchSuggByLocation(locationID:String) -> SignalProducer<[NearMe], NSError>{
        let request = mutableRequestWithURL(getBTDTSuggetionsURL, method: .POST)
        request.HTTPBody = httpBodyForSuggNearLocation(Shared.MyInfo.myToken, lid: locationID)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let nearMes:[NearMe] =  decode(json["data"]) {
                    return nearMes
                }else{
                    return []
                }
        }
    }
    
    
    func filterSugg() -> SignalProducer<[String:[FilterModel]],NSError>{
        return SignalProducer.empty
    }
    
    func fetchSugg() -> SignalProducer<[Beenthere], NSError>{
        let request = mutableRequestWithURL(getSuggURL, method: .POST)
        request.HTTPBody = httpBodyForUserParameters(Shared.MyInfo.myToken)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let beentheres:[Beenthere] =  decode(json["beenthere"]) {
                    return beentheres
                }else{
                    return []
                }
        }
    }
    
    func fetchFeedback(chld:Children) -> SignalProducer<[Feedback], NSError> {
        let request = mutableRequestWithURL(getFeedbackURL, method: .POST)
        var str = ""
        if let childalid = chld.allIds {
            for alid in childalid {
                str = "\(str)&item_ids[]=\(alid)"
            }
        }        
        request.HTTPBody = httpBodyForAllIdsParameters( Shared.MyInfo.myToken,allids: str)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let feed:[Feedback] = decode(json["data"]) {
                    return feed
                } else {
                    return []
                }
        }
    }
    
    // MARK: - CoreLocation -> locationID -> CLLocation
    
    func fetchGPlaceChild(child:Children) -> SignalProducer<LocationChild, NSError> {
        return SignalProducer { observer, disposable in
            let str = child.item_title
            GMSPlacesClient
                .sharedClient()
                .autocompleteQuery(str, bounds: nil, filter: nil, callback: { (autocompletePrediction, error) in
                    //                    let location = LocationChild(child:child ,place: place)
                    //                    observer.sendNext(location)
                    //                    observer.sendCompleted()
                })
        }
    }
    
    
    func fetchGPlace(beens:[Beenthere]) -> SignalProducer<[Location], NSError> {
        return SignalProducer { observer, disposable in
            var locations:[Location] = []
            for been in beens {
                if let locationId = been.locations_id {
                    GMSPlacesClient.sharedClient().lookUpPlaceID(locationId, callback: { (place:GMSPlace?, error) in
                        guard let place = place where error == nil else {
                            if been.lid == beens.last!.lid{
                                observer.sendNext(locations)
                                observer.sendCompleted()
                            }
                        return
                        }
                        
                        let location = Location(beenthere:been ,place:place)
                        locations.append(location)
                        if been.lid == beens.last!.lid{
                            observer.sendNext(locations)
                            observer.sendCompleted()
                        }
                    })
                }
            }
        }
    }
    
    func fetchGPlaceImageMeta(plans:[Plan]) -> SignalProducer<[LocationImage], NSError> {
        return SignalProducer { observer, disposable in
            var loctionImages:[LocationImage] = []
            for plan in plans {
                GMSPlacesClient.sharedClient()
                    .lookUpPhotosForPlaceID(plan.locationsId, callback: {(list, error) in
                        guard let list = list where error == nil else {
                            return
                        }
                        let locationImg = LocationImage(plan: plan, image: nil, photoMetadata: list)
                        loctionImages.append(locationImg)
                        if plan.planId == plans.last!.planId{
                            observer.sendNext(loctionImages)
                            observer.sendCompleted()
                        }
                    })
            }
        }
    }
    
    func fetchGPlaceImageD(locals:[LocationImage]) -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, disposable in
            for loc in locals {
                if Shared.MyInfo.plansImages[loc.plan.planId] != nil
                {
                    observer.sendNext()
                    return
                }
                if loc.photoMetadata.results.count > 0 {
                GMSPlacesClient.sharedClient()
                    .loadPlacePhoto(loc.photoMetadata.results[0], callback: { (image, error) in
                        guard let image = image where error == nil else {
                            return
                        }
                        Shared.MyInfo.plansImages[loc.plan.planId] = image
                        observer.sendNext()
                    })
                    
                }
            }
        }
    }
    
    
    func fetchGPlaceAutocomplete(child: Children) -> SignalProducer< LocationChild, NSError> {
        return SignalProducer { observer, disposable in
            var tplace:GMSPlace?
            GMSPlacesClient.sharedClient().lookUpPlaceID(child.locations_id,
                callback: { (place:GMSPlace?, error) in
                    guard let place = place where error == nil else {
                        observer.sendFailed(error!)
                        observer.sendCompleted()
                        return
                    }
                tplace = place
                let filter = GMSAutocompleteFilter()
                filter.type = .Establishment
                let coordinateBounds =  GMSCoordinateBounds().includingCoordinate(place.coordinate)
                
                GMSPlacesClient.sharedClient().autocompleteQuery(child.item_title,
                    bounds: coordinateBounds,
                    filter: filter,
                    callback: { (results: [GMSAutocompletePrediction]?, error: NSError?) -> Void in
                        guard error == nil else {
                        print("Autocomplete error \(error)")
                        observer.sendFailed(error!)
                        return
                    }
                    if let results = results {
                        if results.count>0{
                            GMSPlacesClient.sharedClient().lookUpPlaceID(results.first!.placeID!,
                                callback: { (place:GMSPlace?, error) in guard let place = place where error == nil else {
                                observer.sendFailed(error!)
                                observer.sendCompleted()
                                disposable.dispose()
                                return
                                }
                                
                                let location = LocationChild(child: child, place: place)
                                    observer.sendNext(location)
                                    observer.sendCompleted()
                                    disposable.dispose()
                            })
                        }
                        else {
                            if let place = tplace {
                            let location = LocationChild(child: child, place: place)
                            observer.sendNext(location)
                            observer.sendCompleted()
                            disposable.dispose()
                            }
                        }
                    }
               
                })
            })   
        }
    }

    
    func fetchGPlaceAutoComp(str:String, bounds: GMSCoordinateBounds?, filter:GMSAutocompleteFilter?) -> SignalProducer<[GMSAutocompletePrediction], NSError> {
        return SignalProducer { observer, disposable in
            GMSPlacesClient.sharedClient().autocompleteQuery(str, bounds:bounds, filter:filter, callback:
            {(results: [GMSAutocompletePrediction]?, error: NSError?) -> Void in
                guard error == nil else {
                    print("Autocomplete error \(error)")
                    observer.sendFailed(error!)
                    return}
                if let autocomp = results {
                    observer.sendNext(autocomp)
                    observer.sendCompleted()
                }else{
                    observer.sendNext([])
                    observer.sendCompleted()
                }
            })
        }
    }
    
    func fetchGPlaceAutoCompSelected(strSearch:String,pred:GMSAutocompletePrediction) -> SignalProducer<[GMSAutocompletePrediction], NSError> {
        return SignalProducer { observer, disposable in
            if let pid = pred.placeID {
                GMSPlacesClient.sharedClient().lookUpPlaceID(pid,
                    callback:
                    { (place:GMSPlace?, error) in guard let _ = place where error == nil else {
                        observer.sendFailed(error!)
                        observer.sendCompleted()
                        disposable.dispose()
                        return
                        }
                        let filter = GMSAutocompleteFilter()
                        filter.type = .Establishment
                        GMSPlacesClient.sharedClient().autocompleteQuery(strSearch, bounds:nil, filter:filter, callback:
                            {(results: [GMSAutocompletePrediction]?, error: NSError?) -> Void in
                                guard error == nil else {
                                    print("Autocomplete error \(error)")
                                    observer.sendFailed(error!)
                                    return}
                                if let autocomp = results {
                                    observer.sendNext(autocomp)
                                    observer.sendCompleted()
                                    disposable.dispose()
                                }else{
                                    observer.sendNext([])
                                    observer.sendCompleted()
                                    disposable.dispose()
                                }
                        })
                })
            }
        }
    }

    
    func fetchImagesSingleGPlace(place:GMSPlace) -> SignalProducer<UIImage, NSError> {
        return SignalProducer { observer, disposable in

                GMSPlacesClient.sharedClient()
                    .lookUpPhotosForPlaceID(place.placeID, callback: {(list, error) in
                        guard let list = list where error == nil else {
                            observer.sendFailed(error!)
                            disposable.dispose()
                            return
                        }
                        for lis in list.results {
                                GMSPlacesClient
                                .sharedClient()
                                .loadPlacePhoto(lis , callback: { (image, error) in
                                    guard let image = image where error == nil else {
                                        return
                                    }
                                    observer.sendNext(image)
                                    disposable.dispose()
                                })
                        }
                    })
            
        }
    }
    
    func lookUpPlaceID(str:String) -> SignalProducer<GMSPlace, NSError> {
        return SignalProducer { observer, disposable in
            GMSPlacesClient.sharedClient().lookUpPlaceID(str,
                callback:
                { (place:GMSPlace?, error) in guard let place = place where error == nil else {
                    observer.sendFailed(error!)
                    observer.sendCompleted()
                    disposable.dispose()
                    return
                }
                    observer.sendNext(place)
                    observer.sendCompleted()
                    disposable.dispose()
            })
        }
    }

    // MARK: - Welcome
    
    func fetchWelcome(dict:[String:String]) -> SignalProducer<([Itin],[Friend]),NSError> {
        let request = mutableRequestWithURL(getWeatherURL, method: .POST)
        request.HTTPBody = httpBodyForDict(dict)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .flatMapError { error in
                print("Network error occurred: \(error)")
                return SignalProducer.empty
                
            }.map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []){
                    let jinit = json["itin"]
                    let jclse = json["close_by"]
                    
                    let itins:[Itin]? = decode(jinit)
                    let closeby:[Friend]? = decode(jclse)
                    
                    return (itins ?? [],closeby ?? [])
                } else {

                    return ([],[])
                }
        }
    }
    
    func fetchPlans() -> SignalProducer<[Plan], NSError>{
        let request = mutableRequestWithURL(getPlansURL, method: .POST)
        request.HTTPBody = httpBodyForPlansParameters(Shared.MyInfo.myToken)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let plans:[Plan] =  decode(json["plans"]) {
                    return plans
                }else{
                    return []
                }
        }
    }
    
    func savePlan(dict:[String:String]) -> SignalProducer<[Plan], NSError> {
        let request = mutableRequestWithURL(savePlanURL, method: .POST)
        request.HTTPBody = httpBodyForDict(dict)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .flatMapError { error in
                print("Network error occurred: \(error)")
                return SignalProducer.empty}
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let plans:[Plan] =  decode(json["plans"]) {
                    return plans
                }else{
                    return []
                }
        }

    }
    
    func fetchGroups() -> SignalProducer<[Group], NSError> {
        let request = mutableRequestWithURL(getGroupsURL, method: .POST)
        request.HTTPBody = httpBodyForPlansParameters(Shared.MyInfo.myToken)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let groups:[Group] =  decode(json["groups"]) {
                    return groups
                }else{
                    return []
                }
        }
    }
    
    // MARK: - Dreaming
    
    func fetchDream() -> SignalProducer<[Dreaming], NSError> {
        let request = mutableRequestWithURL(getDreamsURL, method: .POST)
        let dict = ["user_id":Shared.MyInfo.myIdentifier,"fetch":"Y"]
        request.HTTPBody = httpBodyForDict(dict)
        return NSURLSession.sharedSession()
            .rac_dataWithRequest(request)
            .retry(2)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let plans:[Dreaming] =  decode(json["data"]) {
                    return plans
                }else{
                    return []
                }
        }
 
        
    }
    // MARK: - Matches
    
    func fetchMatches() -> SignalProducer<[Match], NSError> {
        let request = mutableRequestWithURL(matchesURL, method: .GET)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let matches: [Match] = decode(json) {
                    return matches
                } else {
                    return []
                }
        }
    }
    
    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        
        let request = mutableRequestWithURL(matchesURL, method: .POST)
        request.HTTPBody = httpBodyForMatchParameters(parameters)
        
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 201
                } else {
                    return false
                }
        }
    }
    
    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        let request = mutableRequestWithURL(urlForMatch(match), method: .PUT)
        request.HTTPBody = httpBodyForMatchParameters(parameters)
        
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 200
                } else {
                    return false
                }
        }
    }
    
    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError> {
        let request = mutableRequestWithURL(urlForMatch(match), method: .DELETE)
        
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 200
                } else {
                    return false
                }
        }
    }
    
    // MARK: Players
    
    func fetchPlayers() -> SignalProducer<[Player], NSError> {
        let request = NSURLRequest(URL: playersURL)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let players: [Player] = decode(json) {
                    return players
                } else {
                    return []
                }
        }
    }
    
    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError> {
        let request = mutableRequestWithURL(playersURL, method: .POST)
        request.HTTPBody = httpBodyForPlayerName(name)
        
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let httpResponse = response as? NSHTTPURLResponse {
                    return httpResponse.statusCode == 201
                } else {
                    return false
                }
        }
    }
    
    // MARK: Rankings
    
    func fetchRankings() -> SignalProducer<[Ranking], NSError> {
        let request = NSURLRequest(URL: rankingsURL)
        return NSURLSession.sharedSession().rac_dataWithRequest(request)
            .map { data, response in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let rankings: [Ranking] = decode(json) {
                    return rankings
                } else {
                    return []
                }
        }
    }
    
    // MARK: Private Helpers
    
    private func httpBodyForMatchParameters(parameters: MatchParameters) -> NSData? {
        let jsonObject = [
            "home_player_ids": Array(parameters.homePlayers).map { $0.identifier },
            "away_player_ids": Array(parameters.awayPlayers).map { $0.identifier },
            "home_goals": parameters.homeGoals,
            "away_goals": parameters.awayGoals
        ]
        return try? NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
    }
    
    private func httpBodyForDict(dict:[String:String]) -> NSData? {
        var tokenDict = ["token":Shared.MyInfo.myToken]
        tokenDict = tokenDict.merge(dict)
        var bodyData = ""
        
        for (key,value) in tokenDict{
            let scapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            let scapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            bodyData += "\(scapedKey)=\(scapedValue)&"
        }
        return bodyData.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    
    
    private func  httpBodyForLoginParameters(parameters: LoginParameters) -> NSData? {
        let stringObject = "email=\(parameters.email)&pass=\(parameters.pass)"
        return stringObject.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    private func httpBodyForPlansParameters(token: String) -> NSData? {
        let stringObject = "token=\(token)&plan_type=all"
        return stringObject.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    
    private func httpBodyForUserParameters(token: String) -> NSData? {
        let stringObject = "token=\(token)"
        return stringObject.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    private func httpBodyForSuggNearLocation(token: String, lid: String) -> NSData? {
        let stringObject = "token=\(token)&locations_id=\(lid)"
        return stringObject.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    private func httpBodyForAPIcall(token: String, uid:String) -> NSData? {
        let stringObject = "token=\(token)&user_id=\(uid)"
        return stringObject.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    
    private func  httpBodyForAllIdsParameters(token: String,allids:String) -> NSData? {
        let stringObject = "token=\(token)\(allids)"
        return stringObject.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    
    
    private func httpBodyForPlayerName(name: String) -> NSData? {
        let jsonObject = [
            "name": name
        ]
        return try? NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
    }
    
    private func urlForMatch(match: Match) -> NSURL {
        return matchesURL.URLByAppendingPathComponent(match.identifier)!
    }
    
    private func mutableRequestWithURL(url: NSURL, method: RequestMethod) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        
        switch method {
        case .GET:
            request.HTTPMethod = "GET"
        case .POST:
            request.HTTPMethod = "POST"
        case .PUT:
            request.HTTPMethod = "PUT"
        case .DELETE:
            request.HTTPMethod = "DELETE"
        }
        
        return request
    }
}

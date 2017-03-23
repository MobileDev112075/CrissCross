//
//  LocalStore.swift
//  RacCriss
//
//  Created by Daniel Karsh on 31/12/15.
//  Copyright © 2015 Daniel Karsh. All rights reserved.
//

import Argo
import Result
import ReactiveCocoa
import CoreLocation
import GooglePlaces
import Alamofire
import AlamofireImage

let COLOR_CC_GREEN          = "#30C720"
let COLOR_CC_TEAL           = "#00DBFF"
let COLOR_CC_BLUE           = "#005AE8"
let COLOR_CC_RED            = "#E04247"
let COLOR_CC_BLUE_BG        = "#000044"
let COLOR_CC_BLUE_BG2       = "#010C55"
let COLOR_GREEN             = "#36CB31"
let API_CC                  = "https://m.crisscrosstheapp.com/api//"

class Shared {
    struct MyInfo {
        
        static var allFilterModels:     [String:[FilterModel]]  = [:]
        static var feedbackCache:       [String:[Feedback]]       = [:]
        
        static var myNears:[NearMe]    = []
        static var myIntis:[Itin]      = []
        static var myClose:[Friend]    = []
        
        static var myToken            = ""
        static var myIdentifier       = ""
        
        static let myLocation         = MutableProperty<CLLocation?>(nil)
        static let myAvatar           = MutableProperty<UIImage?>(nil)
        static let myLoginUser        = MutableProperty<User?>(nil)
        
        static let selectedSugg       = MutableProperty<LocationChild?>(nil)
        static let selectedChild      = MutableProperty<Children?>(nil)
        
//        static var locationChildrens:   [String:LocationChild]  = [:]

        static var plansImages:         [String:UIImage]        = [:]
        
     
        static let showUserFriends  = MutableProperty<[Friend]>([])
        static let showFriendsTree  = MutableProperty<[Friend]>([])
        
        static let userLoader       = MutableProperty(false)
        static let imageCache       = AutoPurgingImageCache()
        
        static var store            = RemoteStore(baseURL: NSURL(string:API_CC)!)
        static let localStore       = LocalStore()
        
//        static let read_filterHistory   = MutableProperty<[(Int,Int)]>([])
//        static let wtite_filterHistory  = MutableProperty<[(Int,Int)]>([])
//        
//        static let read_sugg_FilterModels   = MutableProperty<[[FilterModel]]>([])
//        static let write_sugg_FilterModels  = MutableProperty<[[FilterModel]]>([])
        
//        static let vis_Plan_FilterModels = MutableProperty<[[FilterModel]]>([])
        
    }
}

class LocalStore: StoreType {
    
    private var users               = [String:User]()
    private var locations           = [String:Location]()
    private var locationsChild      = [String:LocationChild]()
    
    private let myUser  = [User]()
    
    private var matches = [Match]()
    private var players = [Player]()
    
    private let rankingEngine = RankingEngine()
    
    private let tokenKey    = "token"
    private let matchesKey  = "matches"
    private let playersKey  = "players"
    private let archiveFileName = "LocalStore"
    
    
    
    func saveUser(user:User)  -> SignalProducer<Void, NSError> {
        self.users[user.identifier] = user
        return SignalProducer.empty
    }
    
    
    // MARK: User
    

    func loginUser(parameters: LoginParameters) -> SignalProducer<(NSData,NSURLResponse),NSError> {
        return SignalProducer.empty
    }
    
    func loginToken(token: String) -> SignalProducer<(NSData,NSURLResponse),NSError>{
        return SignalProducer.empty
    }
    
    func fetchToken() -> SignalProducer<String, NSError> {
        return SignalProducer(value:Shared.MyInfo.myToken)
    }
    
    func saveToken(token: String) ->  SignalProducer<Bool, NSError> {
        Shared.MyInfo.myToken = token
        self.archiveToDisk()
        return SignalProducer(value: true)
    }
    
    func fetchUser(uid:String!) -> SignalProducer<User?, NSError> {
        if let user = self.users[uid]{
            return SignalProducer(value:user)
        }else{
            return SignalProducer(value: nil)
        }
    }
    
    func fetchImage(imageURL:NSURL) -> SignalProducer<UIImage, NSError> {
        return SignalProducer.empty
    }
    
    
    // MARK: - Timeline
    
    // MARK: - CoreLocation -> locationID -> CLLocation
    
    func fetchGPlaceChild(child:Children) -> SignalProducer<LocationChild, NSError>
    {
        
        return SignalProducer.empty
    }
    
    func fetchGPlace(beens:[Beenthere]) -> SignalProducer<[Location], NSError>{
        
         return SignalProducer.empty
    }
    
    func fetchGPlaceImageMeta(plans:[Plan]) -> SignalProducer<[LocationImage], NSError> {
        return SignalProducer.empty
    }
    
    func fetchGPlaceImageD(locals:[LocationImage]) -> SignalProducer<Void, NSError> {
        return SignalProducer.empty
    }
    
    func fetchGPlaceAutocomplete(child: Children) -> SignalProducer<LocationChild, NSError> {
        return SignalProducer.empty
    }
    
    func fetchImagesSingleGPlace(place:GMSPlace) -> SignalProducer<UIImage, NSError> {
        return SignalProducer.empty
    }
    
    func fetchGPlaceAutoComp(str:String, bounds: GMSCoordinateBounds?, filter:GMSAutocompleteFilter?) -> SignalProducer<[GMSAutocompletePrediction], NSError> {
        return SignalProducer.empty
    }
    
    func lookUpPlaceID(str:String) -> SignalProducer<GMSPlace, NSError> {
        return SignalProducer.empty
    }
    
    func fetchGPlaceAutoCompSelected(strSearch:String,pred:GMSAutocompletePrediction) -> SignalProducer<[GMSAutocompletePrediction], NSError> {
         return SignalProducer.empty
    }
    
    func fetchWelcome(dict:[String:String]) -> SignalProducer<([Itin],[Friend]),NSError>{
        return SignalProducer.empty
    }
    // MARK: - Plans
    
    func fetchPlans() -> SignalProducer<[Plan], NSError> {
        return SignalProducer.empty
    }
    
    func savePlan(dict:[String:String]) -> SignalProducer<[Plan], NSError>{
        return SignalProducer.empty
    }
    
    // MARK: - Dreams
    
    func fetchDream() -> SignalProducer<[Dreaming], NSError> {
         return SignalProducer.empty
    }
    
    // MARK: - Suggestions(btdt)
    
    func editSaveSugg (parameters:[String:String],image:UIImage?) -> SignalProducer<String, NSError>{
         return SignalProducer.empty
    }
    
    func filterSugg() -> SignalProducer<[String:[FilterModel]],NSError>{
        var plistData:[String:AnyObject] = [:]
        var format = NSPropertyListFormat.XMLFormat_v1_0 //format of the property list
        let plistPath:String? = NSBundle.mainBundle().pathForResource("FilterList", ofType: "plist")!
        let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)!
        
        do{
            plistData = try NSPropertyListSerialization.propertyListWithData(plistXML,
                                                                             options: .MutableContainersAndLeaves,
                                                                             format: &format) as! [String : AnyObject]
            
            let foo = plistData.map({$0})
                .reduce([String:[FilterModel]]()) { acc, comps in
                    var ret = acc
                    ret[comps.0] = decode(comps.1)
                    return ret
            }
            return SignalProducer(value:foo)
        }
        catch{
            print("Error reading plist: \(error), format: \(format)")
        }
        return SignalProducer(value: [:])
    }
    
    
    func fetchSugg() -> SignalProducer<[Beenthere], NSError>{
        return SignalProducer.empty
    }
    
    func fetchSuggByLocation(locationID:String) -> SignalProducer<[NearMe], NSError>{
        return SignalProducer.empty
    }
    
    func fetchFeedback(chld:Children) -> SignalProducer<[Feedback], NSError> {
        return SignalProducer.empty
    }
    
    
    func fetchGroups() -> SignalProducer<[Group], NSError> 
    {
          return SignalProducer.empty
    }
    // MARK: Matches
    
    func fetchMatches() -> SignalProducer<[Match], NSError> {
        return SignalProducer(value: matches)
    }
    
    func createMatch(parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        let identifier = randomIdentifier()
        let match = matchFromParameters(parameters, withIdentifier: identifier)
        matches.append(match)
        
        return SignalProducer(value: true)
    }
    
    func updateMatch(match: Match, parameters: MatchParameters) -> SignalProducer<Bool, NSError> {
        if let oldMatchIndex = matches.indexOf(match) {
            let newMatch = matchFromParameters(parameters, withIdentifier: match.identifier)
            matches.removeAtIndex(oldMatchIndex)
            matches.insert(newMatch, atIndex: oldMatchIndex)
            return SignalProducer(value: true)
        } else {
            return SignalProducer(value: false)
        }
    }
    
    func deleteMatch(match: Match) -> SignalProducer<Bool, NSError> {
        if let index = matches.indexOf(match) {
            matches.removeAtIndex(index)
            return SignalProducer(value: true)
        } else {
            return SignalProducer(value: false)
        }
    }
    
    // MARK: Players
    
    func fetchPlayers() -> SignalProducer<[Player], NSError> {
        return SignalProducer(value: players)
    }
    
    func createPlayerWithName(name: String) -> SignalProducer<Bool, NSError> {
        let player = Player(identifier: randomIdentifier(), name: name)
        
        // Keep alphabetical order when inserting player
        let alphabeticalIndex = players.indexOf { existingPlayer in
            existingPlayer.name > player.name
        }
        if let index = alphabeticalIndex {
            players.insert(player, atIndex: index)
        } else {
            players.append(player)
        }
        
        return SignalProducer(value: true)
    }
    
    // MARK: Rankings
    
    func fetchRankings() -> SignalProducer<[Ranking], NSError> {
        let rankings = rankingEngine.rankingsForPlayers(players, fromMatches: matches)
        return SignalProducer(value: rankings)
    }
    
    // MARK: Persistence
    
    func archiveToDisk() {
        let dataDict = [tokenKey:Shared.MyInfo.myToken]
        if let filePath = persistentFilePath() {
            NSKeyedArchiver.archiveRootObject(dataDict, toFile: filePath)
        }
    }
    
    func unarchiveFromDisk() {
        if  let path = persistentFilePath(),
            let dataDict = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [String: AnyObject],
            let token = dataDict[tokenKey]
        {
            Shared.MyInfo.myToken = token as! String
        }
    }
    
    
    
    // MARK: Private Helpers
    
    private func randomIdentifier() -> String {
        return NSUUID().UUIDString
    }
    
    private func matchFromParameters(parameters: MatchParameters, withIdentifier identifier: String) -> Match {
        let sortByName: (Player, Player) -> Bool = { players in
            players.0.name < players.1.name
        }
        
        return Match(
            identifier: identifier,
            homePlayers: parameters.homePlayers.sort(sortByName),
            awayPlayers: parameters.awayPlayers.sort(sortByName),
            homeGoals: parameters.homeGoals,
            awayGoals: parameters.awayGoals
        )
    }
    
    private func persistentFilePath() -> String? {
        let basePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as NSString?
        return basePath?.stringByAppendingPathComponent(archiveFileName)
    }
}

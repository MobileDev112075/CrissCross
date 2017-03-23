//
//  LoginViewModel.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/19/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//
import Argo
import ReactiveCocoa
import Result

class LoginViewModel {
    
    
    //    typealias UserChangeset = Changeset<User>
    
    // Inputs
    let active = MutableProperty(false)
    let loginEmail = MutableProperty("")
    let loginPass = MutableProperty("")
    let refreshObserver: Observer<Void, NoError>
    
    // Outputs
    let title: String
    let isLoading:          MutableProperty<Bool>
    let alertMessageSignal: Signal<AnyObject, NoError>
    let tokenFetchResults:  Signal<User?, NSError>
    
    let inputIsValid =      MutableProperty(false)
    let tokenIsValid =      MutableProperty(false)
    let userIsValid =       MutableProperty(false)
    let avatarIsValid =     MutableProperty(false)
    
//    let myUser =            MutableProperty<User?>(nil)
    let alertMessageObserver: Observer<AnyObject, NoError>
    
    
    // Actions
    lazy var loginAction: Action<Void, Bool, NSError> =
        { [unowned self] in
        return Action(enabledIf: self.inputIsValid, { _ in
            let parameters = LoginParameters(
                email: self.loginEmail.value,
                pass: self.loginPass.value
            )
            return self.store.loginUser(parameters)
                .map{ data, response in
                    if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []){                        
                        if  let statusJson = json["status"]{
                            if statusJson == 2 {
                                self.alertMessageObserver.sendNext(json)
                                return false
                            }
                            if statusJson == 1,
                                let ujson = json["user"]
                            {
                                let user:User? = decode(ujson)
                                LocalStore().saveToken(user!.token!)
                                Shared.MyInfo.myLoginUser.swap(user)
                                return true
                            }
                        }
                    }
                return false
            }
        })
        }()
    
    
    private let store: StoreType
    private let userToken = MutableProperty("")
    
    init(store: StoreType) {
        
        self.title = "Login"
        self.store = store
        
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AnyObject, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        let localStore = LocalStore()
        localStore.unarchiveFromDisk()
        
        SignalProducer(signal: refreshSignal)
            .startWithNext { _ in
                return Shared.MyInfo.localStore.filterSugg()
                    .startWithResult({ (result) in
                        Shared.MyInfo.allFilterModels = result.value!
                    })
        }
        
        self.tokenFetchResults = userToken.signal
            .flatMap(.Latest, transform:{ (token:String) -> SignalProducer<(NSData,NSURLResponse),NSError> in
                return store.loginToken(token)
                    .flatMapError({ (error) in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer.empty
                    })})
            .map { (data, URLResponse) -> User? in
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let user:User = decode(json["user"]){
                    return user
                } else {
                    return nil
                }}

        tokenFetchResults.observeResult{(result) in
            switch result{
            case let .Success(user):
                if let user = user {
                 Shared.MyInfo.myLoginUser.swap(user)
                 Shared.MyInfo.myIdentifier = user.identifier
                }
            case .Failure(_):break
            }
        }
        
        SignalProducer(signal:Shared.MyInfo.myLoginUser.signal)
            .flatMap(.Latest, transform:{ (user) -> SignalProducer<UIImage, NSError>  in
                let url = NSURL(string: user!.image_url!)
                return store.fetchImage(url!)
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer.empty
                }
        })
            .startWithResult {(result) in
            Shared.MyInfo.myAvatar.value = result.value
        }


        
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        SignalProducer(signal: refreshSignal)
            .on(next: { _ in isLoading.value = true })
            .flatMap(.Latest, transform: { _ in
                return localStore.fetchToken()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: "")
                }
            })
            .on(next: { _ in isLoading.value = false })
            .startWithNext({ [weak self] (token) in
                if (token.characters.count>1){
                         self?.userToken.value = token // "31456b616c744762745a56644b5a565a79683356616846617945325678514655754a6c5653646b574756564f776f485a705a6c62536c3361735632566f746d56"
                }
                })
        
        self.userIsValid <~ Shared.MyInfo.myLoginUser.producer
            .map { (user) in
                return user != nil
        }
        
        
        self.inputIsValid <~ combineLatest(loginEmail.producer, loginPass.producer)
            .map { (email, pass) in
                return !email.isEmpty && !pass.isEmpty
        }
        
        self.tokenIsValid <~ userToken.producer
            .map { (token) in
                return token.characters.count>1
        }
    }
    
}

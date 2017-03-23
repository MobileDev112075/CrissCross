//
//  AppSharedController.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/21/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Foundation

class AppSharedController{
    static let sharedInstance = AppSharedController()
    
    var localStore = LocalStore()
    
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
//    func unarchiveTokenFromDisk() {
//         localStore.unarchiveTokenFromDisk()
//    }
    
//    func checkUserLogin() -> String {
//        localStore.unarchiveTokenFromDisk()
//        return localStore.tokenUser()
//    }
//    
//    func storeUserToken(token:String){
//        return localStore.archiveTokenToDisk(token)
//    }

}

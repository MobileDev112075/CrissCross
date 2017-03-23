//
//  Encodable.swift
//  RacCriss
//
//  Created by Daniel Karsh on 01/01/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

protocol Encodable {
    func encode() -> [String: AnyObject]
}

//
//  Items.swift
//  localhost
//
//  Created by Pedro Alves on 04/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation

class Items{
    static let sharedInstance = Items()
    var locals = [Local]()
    var favorites = [Local]()
}

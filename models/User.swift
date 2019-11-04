//
//  User.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation

class User: Decodable {
}

extension User
{
    public static func hasUserLoggedIn() -> Bool {
        let id = UserDefaults.standard.value(forKey: "UserID")
        
        return id != nil
    }
}

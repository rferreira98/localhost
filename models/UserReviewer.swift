//
//  UserReviewer.swift
//  localhost
//
//  Created by Pedro Alves on 02/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation

class UserReviewer: Decodable {
    var profile_url:String
    var image_url:String?
    var name:String
    
    required convenience init(from decoder: Decoder) throws
    {
        var container:KeyedDecodingContainer<UserReviewer.CodingKeys>
        do
        {
            container = try decoder.container(keyedBy: UserReviewer.CodingKeys.self)
        }
        catch
        {
            throw error
        }
        
        var profile_url:String
        var image_url:String?
        var name:String
        
        do
        {
            profile_url = try container.decode(String.self, forKey: .profile_url)
            image_url = try? container.decode(String?.self, forKey: .image_url) ?? nil
            name = try container.decode(String.self, forKey: .name)
            
            
            
        }
        self.init(profile_url, image_url, name)
    }
    

    init(_  profile_url: String, _ image_url: String?, _ name: String) {
        self.profile_url = profile_url
        self.image_url = image_url
        self.name = name
        
    }
}

extension UserReviewer
{
    enum CodingKeys: String, CodingKey {
        case profile_url = "profile_url"
        case image_url = "image_url"
        case name = "name"
    }
    
}


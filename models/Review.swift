//
//  Review.swift
//  localhost
//
//  Created by Pedro Alves on 28/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation


class Review: Decodable {
    var user_name:String
    var user_image:String
    var text:String
    var rating:Double
    
    required convenience init(from decoder: Decoder) throws
    {
        var container:KeyedDecodingContainer<Review.CodingKeys>
        do
        {
            container = try decoder.container(keyedBy: Review.CodingKeys.self)
        }
        catch
        {
            throw error
        }
        
        var user_name:String
        var user_image:String
        var text:String
        var rating:Double
        
        do
        {
            user_name = try container.decode(String.self, forKey: .user_name)
            user_image = try container.decode(String.self, forKey: .user_image)
            text = try container.decode(String.self, forKey: .text)
            rating = try container.decode(Double.self, forKey: .rating)
        }
        self.init(user_name, user_image, text, rating)
    }
    
    
    init(_  user_name: String,_ user_image: String, _ text: String, _ rating: Double) {
        self.user_name = user_name
        self.user_image = user_image
        self.text = text
        self.rating = rating
    }
}

extension Review
{
    enum CodingKeys: String, CodingKey {
        case user_name = "user_name"
        case user_image = "user_image"
        case text = "text"
        case rating = "rating"
    }
    
}

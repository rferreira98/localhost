//
//  Review.swift
//  localhost
//
//  Created by Pedro Alves on 28/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation


class Review: Decodable {
    private var user:String
    private var review:String
    private var rating:Float
    
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
            
            var user:String
            var review:String
            var rating:Float
            
            do
            {
                user = try container.decode(String.self, forKey: .user)
                review = try container.decode(String.self, forKey: .review)
                rating = try container.decode(Float.self, forKey: .rating)
                
                
            }
            self.init(user, review, rating)
        }
        
    
        init(_  user: String, _ review: String, _ rating: Float) {
            self.user = user
            self.review = review
            self.rating = rating
            
        }
    }

    extension Review
    {
        enum CodingKeys: String, CodingKey {
            case user = "user"
            case review = "review"
            case rating = "rating"
        }
        
    }

//
//  Review.swift
//  localhost
//
//  Created by Pedro Alves on 28/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation


class Review: Decodable {
     var user:UserReviewer
     var text:String
     var rating:Double
     var url:String

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

            var user:UserReviewer
            var text:String
            var rating:Double
            var url:String

            do
            {
                user = try container.decode(UserReviewer.self, forKey: .user)
                text = try container.decode(String.self, forKey: .text)
                rating = try container.decode(Double.self, forKey: .rating)
                url = try container.decode(String.self, forKey: .url)


            }
            self.init(user, text, rating, url)
        }


    init(_  user: UserReviewer, _ text: String, _ rating: Double, _ url: String) {
            self.user = user
            self.text = text
            self.rating = rating
            self.url = url

        }
    }

    extension Review
    {
        enum CodingKeys: String, CodingKey {
            case user = "user"
            case text = "text"
            case rating = "rating"
            case url = "url"
        }

    }

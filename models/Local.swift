//
//  Local.swift
//  localhost
//
//  Created by Pedro Alves on 28/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
class Local: Decodable {
    var types:[String]
    var name:String
    var address:String
    var city:String
    var latitude:Double
    var longitude:Double
    var avgRating:Double
    var imageUrl:String
    //private var photos:[String]
    //var reviews:[Review?]
    var qtReviews:Int
    
    
    required convenience init(from decoder: Decoder) throws
    {
        var container:KeyedDecodingContainer<Local.CodingKeys>
        do
        {
            container = try decoder.container(keyedBy: Local.CodingKeys.self)
        }
        catch
        {
            throw error
        }
        
        var types:[String]
        var name:String
        var address:String
        var city:String
        var avgRating:Double
        var imageUrl:String
        //var photos:[String]
        //var reviews:[Review?]
        var latitude:Double
        var longitude:Double
        var qtReviews:Int
        
        do
        {
            types = try container.decode([String].self, forKey: .types)
            name = try container.decode(String.self, forKey: .name)
            address = try container.decode(String.self, forKey: .address)
            city = try container.decode(String.self, forKey: .city)
            avgRating = try container.decode(Double.self, forKey: .avgRating)
            imageUrl = try container.decode(String.self, forKey: .imageUrl)
            //photos = try container.decode([String].self, forKey: .photos)
            //reviews = try container.decode([Review?].self, forKey: .reviews)
            latitude = try container.decode(Double.self, forKey: .latitude)
            longitude = try container.decode(Double.self, forKey: .longitude)
            qtReviews = try container.decode(Int.self, forKey: .qtReviews)
            
        }
        //self.init(types, name, address, city, avgRating, photos, reviews, latitude, longitude)
        self.init(types, name, address, city, avgRating, imageUrl, /*reviews,*/ latitude, longitude, qtReviews)
    }
    
    /*convenience init(_  types: [String], _ name: String, _ address: String, _ city: String, _ avgRating: Float, _ photos: [String], _ latitude:Double, _ longitude: Double) {
        self.init(types, name, address, city, avgRating, photos, nil, latitude, longitude)*/
    /*convenience init(_  types: [String], _ name: String, _ address: String, _ city: String, _ avgRating: Double, _ imageUrl: String, _ latitude:Double, _ longitude: Double, _ qtReviews: Int) {
    self.init(types, name, address, city, avgRating, imageUrl, /*[nil],*/ latitude, longitude, qtReviews)
    }
 */
    //init(_  types: [String], _ name: String, _ address: String, _ city: String, _ avgRating: Float, _ photos: [String], _ reviews:Review?, _ latitude:Double, _ longitude: Double) {
    init(_  types: [String], _ name: String, _ address: String, _ city: String, _ avgRating: Double, _ imageUrl: String, /*_ reviews:[Review?],*/ _ latitude:Double, _ longitude: Double, _ qtReviews: Int) {
        self.types = types
        self.name = name
        self.address = address
        self.city = city
        self.avgRating = avgRating
        self.imageUrl = imageUrl
        //self.photos = photos
        //self.reviews = reviews
        self.latitude = latitude
        self.longitude = longitude
        self.qtReviews = qtReviews
        
    }
}

extension Local
{
    enum CodingKeys: String, CodingKey {
        case types = "types"
        case name = "name"
        case address = "address"
        case city = "city"
        case avgRating = "average_rating"
        case imageUrl = "image_url"
        //case photos = "photos"
        //case reviews = "reviews"
        case latitude = "latitude"
        case longitude = "longitude"
        case qtReviews = "qt_reviews"
    }
    
}







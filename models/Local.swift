//
//  Local.swift
//  localhost
//
//  Created by Pedro Alves on 28/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
class Local: Decodable {
    private var type:String
    private var name:String
    private var address:String
    private var city:String
    private var latitude:Double
    private var longitude:Double
    private var avgRating:Float
    private var photos:[String]
    private var reviews:Review?
    
    
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
        
        var type:String
        var name:String
        var address:String
        var city:String
        var avgRating:Float
        var photos:[String]
        var reviews:Review?
        var latitude:Double
        var longitude:Double
        
        do
        {
            type = try container.decode(String.self, forKey: .type)
            name = try container.decode(String.self, forKey: .name)
            address = try container.decode(String.self, forKey: .address)
            city = try container.decode(String.self, forKey: .city)
            avgRating = try container.decode(Float.self, forKey: .avgRating)
            photos = try container.decode([String].self, forKey: .photos)
            reviews = try? container.decode(Review.self, forKey: .reviews)
            latitude = try container.decode(Double.self, forKey: .latitude)
            longitude = try container.decode(Double.self, forKey: .longitude)
            
        }
        self.init(type, name, address, city, avgRating, photos, reviews, latitude, longitude)
    }
    
    convenience init(_  type: String, _ name: String, _ address: String, _ city: String, _ avgRating: Float, _ photos: [String], _ latitude:Double, _ longitude: Double) {
        self.init(type, name, address, city, avgRating, photos, nil, latitude, longitude)
    }
    init(_  type: String, _ name: String, _ address: String, _ city: String, _ avgRating: Float, _ photos: [String], _ reviews:Review?, _ latitude:Double, _ longitude: Double) {
        self.type = type
        self.name = name
        self.address = address
        self.city = city
        self.avgRating = avgRating
        self.photos = photos
        self.reviews = reviews
        self.latitude = latitude
        self.longitude = longitude
        
    }
}

extension Local
{
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case name = "name"
        case address = "address"
        case city = "city"
        case avgRating = "avgRating"
        case photos = "photos"
        case reviews = "reviews"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
}







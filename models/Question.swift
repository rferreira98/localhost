//
//  Question.swift
//  localhost
//
//  Created by Rúben Ricardo Monge Lauro on 30/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation

class Question: Decodable {
    var id:Int
    var place_name:String
    var place_image_url:String
    var place_city:String
    var isMine:Int
    
    required convenience init(from decoder: Decoder) throws
    {
        var container:KeyedDecodingContainer<Question.CodingKeys>
        do
        {
            container = try decoder.container(keyedBy: Question.CodingKeys.self)
        }
        catch
        {
            throw error
        }
        
        var id:Int
        var place_name:String
        var place_image_url:String
        var place_city:String
        var isMine:Int
        
        do
        {
            id = try container.decode(Int.self, forKey: .id)
            place_name = try container.decode(String.self, forKey: .place_name)
            place_image_url = try container.decode(String.self, forKey: .place_image_url)
            place_city = try container.decode(String.self, forKey: .place_city)
            isMine = try container.decode(Int.self, forKey: .isMine)
        }
        self.init(id, place_name, place_image_url, place_city, isMine)
    }
    
    
    init(_  id: Int,_ place_name: String,_ place_image_url: String,_ place_city: String,_ isMine:Int) {
        self.id = id
        self.place_name = place_name
        self.place_image_url = place_image_url
        self.place_city = place_city
        self.isMine = isMine
    }
}

extension Question
{
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case place_name = "place_name"
        case place_image_url = "place_image_url"
        case place_city = "place_city"
        case isMine = "isMine"
    }
    
}

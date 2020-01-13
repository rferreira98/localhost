//
//  PushNotificationSender.swift
//  localhost
//
//  Created by Pedro Alves on 13/01/2020.
//  Copyright © 2020 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAArqCMkAI:APA91bGLZ4ZgSGXBFP8cvdda3NjZQFbZImQW4lrwW9YpbkwTe99AhGJ8RO9Tw1GewjSXnJ9oYZRsKjosT7hnxle7fAO8YOzD-5HEWR9omc1zAV1NcNeOYiJl8w4lDfiM3tTTEvx5ZJ7F", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}

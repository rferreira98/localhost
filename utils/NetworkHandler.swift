//
//  NetworkHandler.swift
//  localhost
//
//  Created by Pedro Alves on 17/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import SwiftHTTP
import Alamofire

class NetworkHandler {
    static var domainUrl = "http://hostlocal.sytes.net"
    //static var domainUrl = "http://178.62.5.112"

    static var baseUrl = domainUrl + "/api"
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate

    static func buildRequestQueryString(urlString: String) -> URL {
        /*let token = UserDefaults.standard.value(forKey: "Token") as? String

        var urlWithToken = urlString
        if let token = token {

            if urlString.range(of: "?") != nil {
                urlWithToken = urlWithToken + "&"
            } else {
                urlWithToken = urlWithToken + "?"
            }

            urlWithToken = urlWithToken + "token=" + token
        }*/

        return URL(string: urlString)!
    }
    
    static func preparePostRequest<T: Encodable>(_ data: T?, urlString: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void) -> PostRequest? {
        let url = buildRequestQueryString(urlString: baseUrl + urlString)

        guard url != nil else {
            completion(false, nil)
            return nil;
        }

        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Make sure that headers are included specifying that our request HTTP body will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers

        if (data != nil) {
            // Now let's encode Post struct into JSON data...
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(data)
                // ... and set our request's HTTP body
                request.httpBody = jsonData
                //print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
            } catch {
                completion(false, "Erro ao encodificar JSON")
            }
        }

        // Create and run a URLSession data task with JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let postRequest = PostRequest(session: session, request: request)
        return postRequest
    }
    
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    static func getServerError(responseData: Data?, response: URLResponse?, responseError: Error?) -> String? {
        guard responseError == nil else {
            return "Erro desconhecido"
        }

        do {
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode < 200) || (httpResponse.statusCode >= 300) {

                    return "Erro \(httpResponse.statusCode)"
                } else {
                    return nil
                }
            }
        }
        return nil

    }


    struct PostRegister: Codable {
        let first_name: String
        let last_name: String
        let password: String
        let password_confirmation: String
        let email: String
        let local: String
    }

    static func register(post: PostRegister, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, "Sem conexão de Internet")
            return
        }
        let postRequest = preparePostRequest(post, urlString: "/register", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(false, error)
            }

            do {
                
                
                //let jsonResponse = try JSONSerialization.jsonObject(with:responseData!, options: .allowFragments)
                let jsonResponse = try JSONSerialization.jsonObject(with:
                responseData!, options: [])
                
                
                if let dictionary = jsonResponse as? [String: Any] {
                    if dictionary["message"] as? String == "User created successfully!" {

                        //UserDefaults.standard.setValue(token, forKey: "Token")
                        UserDefaults.standard.setValue(post.first_name, forKey: "FirstName")
                        UserDefaults.standard.setValue(post.last_name, forKey: "LastName")
                        UserDefaults.standard.setValue(post.email, forKey: "Email")
                        UserDefaults.standard.setValue(post.local, forKey: "Local")
                        UserDefaults.standard.synchronize()
                        //logs in the user
                        
                        completion(true, nil)
                    }
                    /*if let userID = dictionary["id"] as? Int {
                        print(userID)
                        UserDefaults.standard.setValue(userID, forKey: "UserID")
                        UserDefaults.standard.synchronize()
                    }
                    guard let token = dictionary["token"] as? String else {
                        completion(false, nil)
                        return
                    }
                    //print(token)*/
                    
                    completion(true, nil)
                }

            } catch let parsingError {
                print("Error", parsingError)
                completion(false, "Erro no parse de JSON no Registo")
            }

        }
        task.resume()
    }

    struct PostLogin: Codable {
        let password: String
        let email: String
    }

    
    static func login(post: PostLogin, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, "Sem conexão de Internet")
            return
        }
        let postRequest = preparePostRequest(post, urlString: "/login", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(false, error)
            }
            
            //let dataStr = String(responseData)

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:
                responseData!, options: [])
                
                
                if let dictionary = jsonResponse as? [String: Any] {
                    //let saved = saveUserInStorage(userJson: jsonResponse as! [String: Any])
                    let saved = saveUserInStorage(userJson: jsonResponse as! [String: Any])
                    completion(saved, nil)
                }

            } catch let parsingError {
                print("Error", parsingError)
                completion(false, "Erro no parse de JSON no login" )
            }
        }
        task.resume()
    }

    static func saveUserInStorage(userJson: [String: Any]) -> Bool {
        var dataJson: [String: Any]
        dataJson = userJson["data"] as! [String : Any]
        
        
        guard
            let firstName = dataJson["first_name"] as? String,
                let lastName = dataJson["last_name"] as? String,
                let email = dataJson["email"] as? String,
                let local = dataJson["local"] as? String,
                let token = dataJson["token"] as? String,
                let avatarUrl = dataJson["avatar"] as? String
                else {
            print("Invalid user received")
            return false
        }

        UserDefaults.standard.setValue(firstName, forKey: "FirstName")
        UserDefaults.standard.setValue(lastName, forKey: "LastName")
        UserDefaults.standard.setValue(email, forKey: "Email")
        UserDefaults.standard.setValue(local, forKey: "Local")
        UserDefaults.standard.setValue(token, forKey: "Token")
        UserDefaults.standard.setValue(avatarUrl, forKey: "AvatarURL")

        UserDefaults.standard.synchronize()
        return true
    }


    static func uploadAvatar(avatar: UIImage, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, "Sem conexão de Internet")
            return
        }
        
        let token = UserDefaults.standard.value(forKey: "Token") as! String
        
        // the image in UIImage type
        let image = avatar
        

        let filename = "avatar.png"

        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString


        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: baseUrl+"/avatar")!)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var data = Data()

        
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        let task = session.uploadTask(with: urlRequest as URLRequest, from: data, completionHandler:
        { (responseData, response, responseError) -> Void in

            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                completion(false, error)
                return;
            }

            let avatarEncoded = image.pngData()!.base64EncodedString()
            UserDefaults.standard.set(avatarEncoded, forKey: "AvatarEncoded")
            UserDefaults.standard.synchronize()
            completion(true, nil)
        })
        
        task.resume()
        
    }

    
    static func downloadImage(from urlString: String, completion: @escaping (UIImage?, Error?) -> ()) {
        print("Download Started")
        let url = URL(string: urlString);
        NetworkHandler.getData(from: url!) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            print("Download Finished")

            completion(UIImage(data: data), error)
        }
    }



}

class PostRequest {
    let session: URLSession
    let request: URLRequest
    
    init(session: URLSession, request: URLRequest) {
        self.session = session
        self.request = request
    }
}


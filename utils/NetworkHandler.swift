//
//  NetworkHandler.swift
//  localhost
//
//  Created by Pedro Alves on 17/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import SwiftHTTP

class NetworkHandler {
    static var domainUrl = "http://hostlocal.sytes.net"
    //static var domainUrl = "http://178.62.5.112"

    static var baseUrl = domainUrl + "/api"
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate

    static func buildRequestQueryString(urlString: String) -> URL {
        let token = UserDefaults.standard.value(forKey: "Token") as? String

        var urlWithToken = urlString
        if let token = token {

            if urlString.range(of: "?") != nil {
                urlWithToken = urlWithToken + "&"
            } else {
                urlWithToken = urlWithToken + "?"
            }

            urlWithToken = urlWithToken + "token=" + token
        }

        return URL(string: urlWithToken)!
    }
    
    static func preparePostRequest<T: Encodable>(_ data: T?, urlString: String, completion: @escaping (_ success: Bool, NetworkError?) -> Void) -> PostRequest? {
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
                print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
            } catch {
                completion(false, NetworkError(code: NetworkError.ERROR_CODE_UNKNOWN))
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
    
    static func getServerError(responseData: Data?, response: URLResponse?, responseError: Error?) -> NetworkError? {
        guard responseError == nil else {
            return NetworkError(code: NetworkError.ERROR_CODE_UNKNOWN)
        }

        do {
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode < 200) || (httpResponse.statusCode >= 300) {

                    let jsonResponse = try JSONSerialization.jsonObject(with:
                    responseData!, options: [])

                    if let dictionary = jsonResponse as? [String: Any] {
                        let code = dictionary["code"] as! Int
                        return NetworkError(code: code);
                    }
                } else {
                    return nil
                }
            }
        } catch let _ {

        }
        return NetworkError(code: NetworkError.ERROR_CODE_UNKNOWN)

    }


    struct PostRegister: Codable {
        let first_name: String
        let last_name: String
        let password: String
        let password_confirmation: String
        let email: String
        let local: String
    }

    static func register(post: PostRegister, completion: @escaping (_ success: Bool, NetworkError?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, NetworkError(code: NetworkError.ERROR_NETWORK_CONNECTION))
            return
        }
        let postRequest = preparePostRequest(post, urlString: "/register", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(false, error)
            }

            do {
                
                
                let jsonResponse = try JSONSerialization.jsonObject(with:
                responseData!, options: .allowFragments)
                
                

                if let dictionary = jsonResponse as? [String: Any] {
                    if dictionary["message"] as? String == "User created successfully!" {
                        
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
                    //UserDefaults.standard.setValue(token, forKey: "Token")
                    UserDefaults.standard.setValue(post.first_name, forKey: "FirstName")
                    UserDefaults.standard.setValue(post.last_name, forKey: "LastName")
                    UserDefaults.standard.setValue(post.email, forKey: "Email")
                    UserDefaults.standard.setValue(post.local, forKey: "Local")
                    UserDefaults.standard.synchronize()
                    //logs in the user
                    
                    completion(true, nil)
                }

            } catch let parsingError {
                print("Error", parsingError)

            }

        }
        task.resume()
    }

    struct PostLogin: Codable {
        let password: String
        let email: String
    }

    
    static func login(post: PostLogin, completion: @escaping (_ success: Bool, NetworkError?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, NetworkError(code: NetworkError.ERROR_NETWORK_CONNECTION))
            return
        }
        let postRequest = preparePostRequest(post, urlString: "/login", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(false, error)
            }
            
            //let dataStr = String(responseData)\
            
            

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:
                responseData!, options: [])
                let str = String(data: responseData!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(str);
                
                if let dictionary = jsonResponse as? [String: Any] {
                    
                    print(jsonResponse);
                    let saved = saveUserInStorage(userJson: dictionary)
                    completion(saved, nil)
                }

            } catch let parsingError {
                print("Error", parsingError)
                completion(false, NetworkError(code: NetworkError.ERROR_CODE_UNKNOWN))
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
                let token = dataJson["token"] as? String
                else {
            print("Invalid user received")
            return false
        }

        UserDefaults.standard.setValue(firstName, forKey: "FirstName")
        UserDefaults.standard.setValue(lastName, forKey: "LastName")
        UserDefaults.standard.setValue(email, forKey: "Email")
        UserDefaults.standard.setValue(local, forKey: "Local")
        UserDefaults.standard.setValue(token, forKey: "Token")

        UserDefaults.standard.synchronize()
        return true
    }


    static func uploadAvatar(avatar: UIImage, userId: Int, completion: @escaping (_ success: Bool, NetworkError?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, NetworkError(code: NetworkError.ERROR_NETWORK_CONNECTION))
            return
        }

        let imageData: NSData = avatar.pngData()! as NSData
        let token = UserDefaults.standard.value(forKey: "Token") as? String
        let urlString = baseUrl + "/user/\(userId)/edit/avatar?token=" + token!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let mutableURLRequest = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        mutableURLRequest.httpMethod = "POST"
        let boundaryConstant = "----------------12345";
        let contentType = "multipart/form-data;boundary=" + boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        // create upload data to send
        let uploadData = NSMutableData()
        // add image
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar-user-\(userId).png\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(imageData as Data)
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)

        mutableURLRequest.httpBody = uploadData as Data

        let task = session.dataTask(with: mutableURLRequest as URLRequest, completionHandler:
        { (responseData, response, responseError) -> Void in

            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                completion(false, error)
                return;
            }

            let avatarEncoded = imageData.base64EncodedString()
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


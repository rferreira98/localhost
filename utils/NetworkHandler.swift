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
    
    static func prepareRequest<T: Encodable>(_ data: T?, needsToken: Bool, urlString: String, request_type: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void) -> PostRequest? {
        let url = buildRequestQueryString(urlString: baseUrl + urlString)
        
        guard url != nil else {
            completion(false, nil)
            return nil;
        }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = request_type
        // Make sure that headers are included specifying that our request HTTP body will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        if needsToken == true{
            let token = UserDefaults.standard.value(forKey: "Token") as? String
            headers["Authorization"] = "Bearer " + token!
        }
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
        let postRequest = prepareRequest(post, needsToken: false, urlString: "/register", request_type: "POST", completion: completion)!
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
        let postRequest = prepareRequest(post, needsToken: false, urlString: "/login", request_type: "POST", completion: completion)!
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
            
            /*do {
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
             }*/
            
            let avatarEncoded = image.pngData()!.base64EncodedString()
            UserDefaults.standard.set(avatarEncoded, forKey: "AvatarEncoded")
            UserDefaults.standard.synchronize()
            completion(true, nil)
        })
        
        task.resume()
        
    }
    
    struct PostUserData: Codable {
        let first_name: String
        let last_name: String
        let local: String
    }
    
    static func updateUser(post: PostUserData, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, "Sem conexão de Internet")
            return
        }
        
        let postRequest = prepareRequest(post, needsToken: true, urlString: "/me/update/", request_type: "PUT", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            /*guard error == nil else {
             return completion(false, error)
             }*/
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    responseData!, options: .allowFragments) as? [[String: Any]]
                let str = String(data: responseData!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(str);
                
                if let dictionary = jsonResponse as? [String: Any] {
                    
                    print(jsonResponse);
                    let saved = saveUserInStorage(userJson: dictionary)
                    completion(saved, nil)
                }
                
                
            } catch let parsingError {
                print("Error", parsingError)
                completion(false, "Erro no parse JSON no Update")
            }
        }
        task.resume()
    }
    
    struct PostResetPassword: Codable {
        let email: String
    }
    
    static func resetPassword(post: PostResetPassword, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, "Sem conexão de Internet")
            return
        }
        
        let postRequest = prepareRequest(post, needsToken: false, urlString: "/reset/password", request_type: "POST", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(false, error)
            }
            
            completion(true, nil)
        }
        task.resume()
    }
    
    static func getLocals(latitude: Double?, longitude: Double?, completionHandler: @escaping ([Local]?, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completionHandler(nil, "Sem ligação à internet")
            return
        }
        
        var urlLocals: URL
        
        if latitude != nil && longitude != nil {
            urlLocals = URL(string: baseUrl + "/search?latitude="+String(latitude!)+"&longitude="+String(longitude!)+"&radius=3000")!
        }else {
            urlLocals = URL(string: baseUrl + "/search")!
        }
        
        
        
        //let urlLocals = URL(string:"https://5de010c2bb46ce001434c034.mockapi.io/locals")!
        
        let localsTask = URLSession.shared.dataTask(with: urlLocals) { data, response, responseError in
            let error = getServerError(responseData: data, response: response, responseError: responseError)
            guard error == nil else {
                return completionHandler(nil, error)
            }
            
            var locals = [Local]()
            /*
             var str = """
             [
             {
             "id": 1,
             "name": "Mooo Hamburgueria",
             "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/tQXdMBkDtezM6lj-jeFufw/o.jpg",
             "address": "R. de Alcobaça, 7",
             "city": "leiria",
             "average_rating": 4.5,
             "latitude": 39.742876,
             "longitude": -8.810679,
             "qt_reviews": 0,
             "provider": "yelp",
             "created_at": "2019-12-07 12:50:22",
             "updated_at": "2019-12-07 12:50:22",
             "deleted_at": null,
             "types": [
             "burgers"
             ]
             },
             {
             "id": 2,
             "name": "O Feijão Branco - Actividades Hoteleiras",
             "image_url": "",
             "address": "Av. Marquês de Pombal, Lote 1 Bloco B.",
             "city": "leiria",
             "average_rating": 3,
             "latitude": 39.739445,
             "longitude": -8.80791,
             "qt_reviews": 0,
             "provider": "yelp",
             "created_at": "2019-12-07 12:50:22",
             "updated_at": "2019-12-07 12:50:22",
             "deleted_at": null,
             "types": [
             "bars",
             "restaurants"
             ]
             },
             ]
             """.data(using: .utf8)
             */
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    print(String(data: data, encoding: .utf8) ?? "no body data")
                    print(data)
                    locals = try decoder.decode([Local].self, from: data)
                    
                } catch let exception {
                    completionHandler(nil, exception.localizedDescription)
                    return
                }
                
            }
            completionHandler(locals, nil)
        }
        
        localsTask.resume()
    }
    
    static func getLocalsFilteredByDistance(currentLocationLatitude: Double, currentLocationLongitude: Double, radius: Int, completionHandler: @escaping ([Local]?, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completionHandler(nil, "Sem ligação à internet")
            return
        }
        
        let urlLocals = URL(string: baseUrl + "/search?latitude=\(currentLocationLatitude)&longitude=\(currentLocationLongitude)&radius=\(radius)")!
        //let urlLocals = URL(string:"https://5de010c2bb46ce001434c034.mockapi.io/locals")!
        
        let localsTask = URLSession.shared.dataTask(with: urlLocals) { data, response, responseError in
            let error = getServerError(responseData: data, response: response, responseError: responseError)
            guard error == nil else {
                return completionHandler(nil, error)
            }
            
            var locals = [Local]()
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    //print(String(data: data, encoding: .utf8) ?? "no body data")
                    locals = try decoder.decode([Local].self, from: data)
                    
                } catch let exception {
                    completionHandler(nil, exception.localizedDescription)
                    return
                }
                
            }
            completionHandler(locals, nil)
        }
        
        localsTask.resume()
    }
    
    static func storeFavorite(local_id:Int ,completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, "Sem conexão de Internet")
            return
        }
        let postRequest = prepareRequest(nil as String? ,needsToken: true, urlString: "/favorite/\(local_id)", request_type: "POST", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(false, error)
            }
            
            completion(true, nil)
        }
        task.resume()
    }
    
    static func deleteFavorite(local_id:Int ,completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(false, "Sem conexão de Internet")
            return
        }
        let postRequest = prepareRequest(nil as String? ,needsToken: true, urlString: "/favorite/\(local_id)", request_type: "DELETE", completion: completion)!
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(false, error)
            }
            
            completion(true, nil)
        }
        task.resume()
    }
    
    static func getFavorites(completion: @escaping ([Local]?, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completion(nil, "Sem conexão de Internet")
            return
        }
        
        // Specify this request as being a POST method
        let url = URL(string: baseUrl + "/favorites")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Make sure that headers are included specifying that our request HTTP body will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        let token = UserDefaults.standard.value(forKey: "Token") as? String
        headers["Authorization"] = "Bearer " + token!
        request.allHTTPHeaderFields = headers
        
        // Create and run a URLSession data task with JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let postRequest = PostRequest(session: session, request: request)
        let task = postRequest.session.dataTask(with: postRequest.request) { (responseData, response, responseError) in
            let error = getServerError(responseData: responseData, response: response, responseError: responseError)
            guard error == nil else {
                return completion(nil, error)
            }
            var locals = [Local]()
            
            if let data = responseData {
                let decoder = JSONDecoder()
                do {
                    //print(String(data: data, encoding: .utf8) ?? "no body data")
                    locals = try decoder.decode([Local].self, from: data)
                } catch let exception {
                    completion(nil, exception.localizedDescription)
                    return
                }
                
            }
            completion(locals, nil)
        }
        task.resume()
    }
    
    static func getLocalsFilteredByCity(city: String, completionHandler: @escaping ([Local]?, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completionHandler(nil, "Sem ligação à internet")
            return
        }
        let currentCityEscaped = city.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)
        
        print(currentCityEscaped!)
        let urlLocals = URL(string: baseUrl + "/searchByCity?city=\(currentCityEscaped!)")!
        print(urlLocals)
        let localsTask = URLSession.shared.dataTask(with: urlLocals) { data, response, responseError in
            let error = getServerError(responseData: data, response: response, responseError: responseError)
            guard error == nil else {
                return completionHandler(nil, error)
            }

            var locals = [Local]()

            if let data = data {
                let decoder = JSONDecoder()
                do {
                    //print(String(data: data, encoding: .utf8) ?? "no body data")
                    locals = try decoder.decode([Local].self, from: data)
                    
                } catch let exception {
                    completionHandler(nil, exception.localizedDescription)
                    return
                }

            }
            completionHandler(locals, nil)
        }

        localsTask.resume()
    }
    
    static func getLocalsFilteredByRating(rating: Double, latitude: Double, longitude: Double, completionHandler: @escaping ([Local]?, _ error: String?) -> Void) {
        if !NetworkHandler.appDelegate.isNetworkOn {
            completionHandler(nil, "Sem ligação à internet")
            return
        }
        
        let urlLocals = URL(string: baseUrl + "/searchByRanking?ranking=\(rating)"+"&latitude=\(latitude)"+"&longitude=\(longitude)")!
        print(urlLocals)
        let localsTask = URLSession.shared.dataTask(with: urlLocals) { data, response, responseError in
            let error = getServerError(responseData: data, response: response, responseError: responseError)
            print(data)
            guard error == nil else {
                return completionHandler(nil, error)
            }

            var locals = [Local]()

            if let data = data {
                let decoder = JSONDecoder()
                do {
                    //print(String(data: data, encoding: .utf8) ?? "no body data")
                    locals = try decoder.decode([Local].self, from: data)
                    
                } catch let exception {
                    completionHandler(nil, exception.localizedDescription)
                    return
                }

            }
            completionHandler(locals, nil)
        }

        localsTask.resume()
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


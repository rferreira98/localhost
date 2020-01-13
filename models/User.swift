//
//  User.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation

class User: Decodable {
    private var _firstName:String
    private var _lastName:String
    private var _avatar:String?
    private(set) var profileChanged:Bool
    let id:Int
    let token:String
    let email:String
    private var _local:String
    private var _messagingToken:String
    
    var firstName:String{
        get{
            return self._firstName;
        }
        
        set(newVal){
            if(self._firstName.compare(newVal) != .orderedSame){
                self.profileChanged = true
                self._firstName=newVal
            }
        }
    }
    
    var lastName:String{
        get{
            return self._lastName;
        }
        
        set(newVal){
            if(self._lastName.compare(newVal) != .orderedSame){
                self.profileChanged = true
                self._lastName=newVal
            }
        }
    }
    
    var avatar:String?{
        get{
            return self._avatar;
        }
        
        set(newVal){
            if self._avatar != newVal {
                if let newVal = newVal {
                    if(self._avatar?.compare(newVal) != .orderedSame){
                        self.profileChanged = true;
                        self._avatar=newVal
                    }
                }
            }
        }
    }
    var local:String{
        get{
            return self._local;
        }
        
        set(newVal){
            if(self._local.compare(newVal) != .orderedSame){
                self.profileChanged = true
                self._local=newVal
            }
        }
    }
    var messagingToken:String{
        get{
            return self._messagingToken;
        }
    }
    
    required convenience init(from decoder: Decoder) throws
    {
        var container:KeyedDecodingContainer<User.CodingKeys>
        do
        {
            container = try decoder.container(keyedBy: User.CodingKeys.self)
        }
        catch
        {
            throw error
        }
        
        var id:Int
        var token:String
        var firstName:String
        var lastName:String
        var email:String
        var avatar:String?
        var local: String
        var messagingToken: String
        do
        {
            id = try! container.decode(Int.self, forKey: .id)
            token = try! container.decode(String.self, forKey: .token)
            firstName = (try? container.decode(String.self, forKey: .firstName)) ?? ""
            lastName = (try? container.decode(String.self, forKey: .lastName)) ?? ""
            email = (try? container.decode(String.self, forKey: .email)) ?? ""
            avatar = try? container.decode(String.self, forKey: .avatar)
            local = (try? container.decode(String.self, forKey: .local)) ?? ""
            messagingToken = try! container.decode(String.self, forKey: .messagingToken)
        }
        self.init(id, token, firstName, lastName, email ,local, avatar, messagingToken)
    }
    
    convenience init(){
        guard let token = UserDefaults.standard.value(forKey: "Token") as? String else {
            self.init(-1,"","","", "", "",nil, "")
            return
        }
        self.init(UserDefaults.standard.value(forKey: "Id") as! Int,
                  token,
                  UserDefaults.standard.value(forKey: "FirstName") as! String,
                  UserDefaults.standard.value(forKey: "LastName") as! String,
                  UserDefaults.standard.value(forKey: "Email") as! String,
                  UserDefaults.standard.value(forKey: "Local") as! String,
                  UserDefaults.standard.value(forKey: "AvatarString") as? String,
                  UserDefaults.standard.value(forKey: "MessagingToken") as! String)
    }
    
    convenience init(_ id:Int,_ token: String, _ firstName:String, _ lastName:String, _ email:String, _ local:String, _ messagingToken: String) {
        self.init(id, token, firstName, lastName, email, local, nil, messagingToken)
    }
    

    init(_ id:Int, _ token:String, _ firstName:String, _ lastName:String, _ email:String, _ local:String, _ avatar:String?, _ messagingToken:String) {
        self.id=id
        self.token=token
        self._firstName = firstName
        self._lastName = lastName
        self.email = email
        self._local = local
        self._avatar = avatar
        self.profileChanged = false
        self._messagingToken = messagingToken
    }
}

extension User:Encodable
{
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case token = "token"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case local = "local"
        case avatar = "avatar"
        case messagingToken = "messagingToken"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self._firstName, forKey: .firstName)
        try container.encode(self._lastName, forKey: .lastName)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.local, forKey: .local)
        try container.encode(self._avatar, forKey: .avatar)
        try container.encode(self._messagingToken, forKey: .messagingToken)
    }
}


extension User
{
    public static func hasUserLoggedIn() -> Bool {
        let token = UserDefaults.standard.value(forKey: "Token")
        
        return token != nil
    }
}

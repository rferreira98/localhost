//
//  AppDelegate.swift
//  localhost
//
//  Created by Ricardo Filipe Ribeiro Ferreira on 25/10/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import IQKeyboardManager
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let manager = NetworkReachabilityManager(host: "www.google.com")
    public var isNetworkOn:Bool = true
    
    
     var window: UIWindow?
    
    override public init()
    {
        super.init()
        self.manager?.listener = { status in
            self.isNetworkOn = (status == .reachable(.ethernetOrWiFi) || status == .reachable(.wwan))
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
        let pushManager = PushNotificationManager(userID: "currently_logged_in_user_id")
        pushManager.registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        
        IQKeyboardManager.shared().isEnabled = true
    
        NotificationCenter.default.addObserver(self, selector: #selector( languageWillChange), name: NSNotification.Name(rawValue: "LANGUAGE_WILL_CHANGE"), object: nil)
        
        let systemLanguage = NSLocale.current.languageCode
        let userLanguage = UserDefaults.standard.string(forKey: "AppLanguage")

        if userLanguage == nil{
            UserDefaults.standard.set(systemLanguage, forKey: "AppLanguage")
            Bundle.setLanguage(systemLanguage!)
        }else{
            Bundle.setLanguage(userLanguage!)
        }
    

        //let targetLang = UserDefaults.standard.string(forKey: "AppLanguage")

        //Bundle.setLanguage((targetLang != nil) ? targetLang! : "pt")

        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        let handled = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        return handled
    }
    
    @objc func languageWillChange(notification:NSNotification){
        let targetLang = notification.object as! String
        UserDefaults.standard.set(targetLang, forKey: "AppLanguage")
        Bundle.setLanguage(targetLang)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LANGUAGE_DID_CHANGE"), object: targetLang)
    } 

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
           //print(response.notification.request.content.userInfo["balela"] as! String)
        if response.actionIdentifier == "like" {
            let message = Message(id: UUID().uuidString, content: "👍", created: Timestamp(), senderID: "\(UserDefaults.standard.value(forKey: "Id") as! Int)",
                senderName: "\(UserDefaults.standard.value(forKey: "FirstName") as! String) \(UserDefaults.standard.value(forKey: "LastName") as! String)", senderPhoto: UserDefaults.standard.value(forKey: "AvatarURL") as? String ?? "")
            //print(response.notification.request.content.userInfo["chat_id"] as! String)
            
            save(message, response.notification.request.content.userInfo["chat_id"] as! String)
        }else if response.actionIdentifier == "dislike" {
            let message = Message(id: UUID().uuidString, content: "👎", created: Timestamp(), senderID: "\(UserDefaults.standard.value(forKey: "Id") as! Int)",
            senderName: "\(UserDefaults.standard.value(forKey: "FirstName") as! String) \(UserDefaults.standard.value(forKey: "LastName") as! String)", senderPhoto: UserDefaults.standard.value(forKey: "AvatarURL") as? String ?? "")
            
            save(message, response.notification.request.content.userInfo["chat_id"] as! String)
            /*
        OperationQueue.main.addOperation {
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homePage = mainStoryboard.instantiateViewController(withIdentifier: "loginViewController_1") as! LoginViewController
        //let navigationController = UINavigationController.init(rootViewController: homePage)
           //
            
            //self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController?.present(homePage, animated: false)
            //self.window?.mak
             eKeyAndVisible()
            */
        }
        
        completionHandler()
       }

    private func save(_ message: Message, _ chat_id: String) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName,
            "senderPhoto": message.senderPhoto
        ]
        //Writing it to the thread using the saved document reference we saved in load chat function
        Firestore.firestore().collection("Chats").document(chat_id).collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
        })
    }

}


import ObjectiveC

private var associatedLanguageBundle:Character = "0"

class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedLanguageBundle) as? Bundle
        return (bundle != nil) ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : (super.localizedString(forKey: key, value: value, table: tableName))

    }
}

extension Bundle {
    class func setLanguage(_ language: String) {
        var onceToken: Int = 0

        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle, (language != nil) ? Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? "") : nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}



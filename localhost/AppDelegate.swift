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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
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
        
        let pushManager = PushNotificationManager(userID: "currently_logged_in_user_id")
        pushManager.registerForPushNotifications()
        
        FirebaseApp.configure()
        
        IQKeyboardManager.shared().isEnabled = true
        

        if UserDefaults.standard.string(forKey: "AppLanguage") == nil{
                UserDefaults.standard.set("en", forKey: "AppLanguage")
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector( languageWillChange), name: NSNotification.Name(rawValue: "LANGUAGE_WILL_CHANGE"), object: nil)

        let targetLang = UserDefaults.standard.string(forKey: "AppLanguage")

        Bundle.setLanguage((targetLang != nil) ? targetLang! : "en")

        
        return true
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



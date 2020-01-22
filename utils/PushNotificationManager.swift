//
//  PushNotificationManager.swift
//  localhost
//
//  Created by Pedro Alves on 13/01/2020.
//  Copyright © 2020 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications
class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            let likeAction = UNNotificationAction(identifier: "like", title: "👍", options: [])
            let dislikeAction = UNNotificationAction(identifier: "dislike", title: "👎", options: [])
            let saveAction = UNNotificationAction(identifier: "save", title: "Go to chat", options: [.foreground])
            let category = UNNotificationCategory(identifier: "local", actions: [likeAction, dislikeAction, saveAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users_table").document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
        }
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }
    /*
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //print(response.notification.request.content.userInfo["balela"] as! String)
        if response.actionIdentifier == "like" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let first = storyBoard.instantiateViewController(withIdentifier: "RecommendationsViewController")
            //self.window.rootViewController = first
            print("Handle like action identifier")
        } else if response.actionIdentifier == "save" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let first = storyBoard.instantiateViewController(withIdentifier: "RecommendationsViewController")
            //self.window.rootViewController = first
            print("Handle save action identifier")
        } else {
            print("No custom action identifiers chosen")
        }
        // Make sure completionHandler method is at the bottom of this func
        completionHandler()
    }
    */
}

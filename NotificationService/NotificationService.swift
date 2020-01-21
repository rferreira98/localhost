//
//  NotificationService.swift
//  NotificationService
//
//  Created by Miguel Sousa on 19/01/2020.
//  Copyright © 2020 Pedro Miguel Prates Alves. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension, UNUserNotificationCenterDelegate {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        UNUserNotificationCenter.current().delegate = self

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            //contentHandler(bestAttemptContent)
        }
        
        contentHandler(bestAttemptContent!)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

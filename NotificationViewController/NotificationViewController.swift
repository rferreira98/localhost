//
//  NotificationViewController.swift
//  NotificationViewController
//
//  Created by Miguel Sousa on 19/01/2020.
//  Copyright © 2020 Pedro Miguel Prates Alves. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import MapKit
import Contacts

class NotificationViewController: UIViewController, MKMapViewDelegate, UNNotificationContentExtension {
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet var label: UILabel?
    @IBOutlet weak var txtAnswer: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var coordinate: CLLocationCoordinate2D!
    @IBOutlet weak var lblLocal: UILabel!
    @IBOutlet weak var lblQuestao: UILabel!
    /*
    var currentUser: User = User(UserDefaults.standard.value(forKey: "Id") as! Int,
                                 UserDefaults.standard.value(forKey: "Token") as! String,
                                 UserDefaults.standard.value(forKey: "FirstName") as! String,
                                 UserDefaults.standard.value(forKey: "LastName") as! String,
                                 UserDefaults.standard.value(forKey: "Email") as! String,
                                 UserDefaults.standard.value(forKey: "Local") as! String,
                                 UserDefaults.standard.value(forKey: "AvatarURL") as? String,
                                 UserDefaults.standard.value(forKey: "MessagingToken") as! String)
    
    private var docReference: DocumentReference?
    
    //I've fetched the profile of user 2 in previous class from which
    //I'm navigating to chat view. So make sure you have the following
    //three variables information when you are on this class.
    
    var question: Question!
 */
    //private var docReference: DocumentReference?
    //var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = false
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = true
        mapView.isUserInteractionEnabled = false
        /*
 */
        // Do any required interface initialization here.
        /*
        self.title = "Tou"
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = UIColor(named: "AppGreenPrimary")
        if traitCollection.userInterfaceStyle == .dark {
            messageInputBar.inputTextView.backgroundColor = UIColor.black
            messagesCollectionView.backgroundColor = UIColor.black
            messageInputBar.contentView.backgroundColor = UIColor.black
            messageInputBar.backgroundView.backgroundColor = UIColor.black
        }
        messageInputBar.sendButton.setTitleColor(UIColor(named: "AppGreenPrimary"), for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        */
        //loadChat()
    }
    
     func didReceive(_ notification: UNNotification) {
       
    
        //local = Local(1, ["Tou"], "Tou", "Leiria", "Marrazes", 3.0, "", 39.764263, -8.804479, 3)
        
        //self.messagesTableView.delegate = self
        //self.messagesTableView.dataSource = self
        self.lblLocal.text = notification.request.content.userInfo["place_name"] as? String
        self.lblQuestao.text = notification.request.content.userInfo["questao"] as? String
        let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: CLLocationDegrees(Double(notification.request.content.userInfo["place_lat"] as! String)!))!, longitude: CLLocationDegrees(exactly: CLLocationDegrees(Double(notification.request.content.userInfo["place_lng"] as! String)!))!)
        let marker = MKPointAnnotation()
        marker.title = notification.request.content.userInfo["place_name"] as? String
        marker.coordinate = center
        mapView.addAnnotation(marker)
        //self.txtAnswer.becomeFirstResponder()
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(region, animated: true)
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isMultipleTouchEnabled = false
        mapView.isScrollEnabled = false
        
        /*
        self.title = "Tou"
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = UIColor(named: "AppGreenPrimary")
        if traitCollection.userInterfaceStyle == .dark {
            messageInputBar.inputTextView.backgroundColor = UIColor.black
            messagesCollectionView.backgroundColor = UIColor.black
            messageInputBar.contentView.backgroundColor = UIColor.black
            messageInputBar.backgroundView.backgroundColor = UIColor.black
        }
        messageInputBar.inputTextView.becomeFirstResponder()
        messageInputBar.sendButton.setTitleColor(UIColor(named: "AppGreenPrimary"), for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        */
       // loadChat()
        
        //self.drawMapWithLocation(selectedCoordinate: self.coordinate!)
    }
}

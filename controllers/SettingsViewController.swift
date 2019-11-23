//
//  SettingsViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import SDWebImage

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var switchDarkMode: UISwitch!
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var switchAuth: UISwitch!
    
    override func viewDidAppear(_ animated: Bool) {
        //removes the separator/line on the table cell
        tableView.cellForRow(at: IndexPath(row: 0, section: 3))?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        //if the user has dark mode enable in the system the button is set to on, otherwise to off
        switchDarkMode.setOn(traitCollection.userInterfaceStyle == .dark, animated: true)
        
        switchAuth.setOn(UserDefaults.standard.bool(forKey: "usesBiometricAuth"), animated: true)
        
        
        let authLabel = tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.contentView.subviews[0] as! UILabel
        authLabel.text = "Autenticação com "+Utils.getBiometricSensor()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.height / 2
        imageViewAvatar.clipsToBounds = true
        if let avatarEncoded = UserDefaults.standard.value(forKey: "AvatarEncoded") as? String {
            if let decodedData = Data(base64Encoded: avatarEncoded, options: .ignoreUnknownCharacters) {
                let avatar = UIImage(data: decodedData)
                self.imageViewAvatar.image = avatar
            }
        } else {
            var imageCache = SDImageCache.shared
            imageCache.clearMemory()
            imageCache.clearDisk()
            
            let avatarName = UserDefaults.standard.value(forKey: "AvatarURL") as! String
            let strUrl = NetworkHandler.domainUrl + "/storage/profiles/"+avatarName
            self.imageViewAvatar.sd_setImage(with: URL(string: strUrl), placeholderImage: UIImage(named: "NoAvatar"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var sectionColor: UIColor
        
        //if ios 13 is available, the background for the cell will be the system color, otherwise it will be white, since there is no dark mode on ios 13 <
        if #available(iOS 13.0, *) {
            sectionColor = UIColor.systemBackground
        } else {
            sectionColor = UIColor.white
        }
        
        
        self.tableView.backgroundView?.backgroundColor = sectionColor
        self.tableView.backgroundColor = sectionColor
        //Removes the thick separators
        self.tableView.separatorStyle = .none
        let footerView = UIView()
        footerView.backgroundColor =  sectionColor
        self.tableView.tableFooterView = footerView
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           self.tableView.deselectRow(at: indexPath, animated: true)
            //if the selected cell is the "contact" cell at index 2, opens the system mail app
            if indexPath.section == 2 {
               if MFMailComposeViewController.canSendMail() {
                   let mail = MFMailComposeViewController()
                   mail.mailComposeDelegate = self
                   mail.setToRecipients(["team.localh@gmail.com"])
                   mail.setSubject("App Contact")
                   
                   
                   present(mail, animated: true)
               } else {
                   let alert = Utils.triggerAlert(title: "Error", error: "Error opening e-mail app")
                   self.present(alert, animated: true, completion: nil)
               }
               
            }else if indexPath.section == 1{
                if indexPath.row == 1{
                    UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                }
            }
       }
       
       func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
           controller.dismiss(animated: true)
       }
    
    @IBAction func darkModeSwitcher(_ sender: Any) {
        if switchDarkMode.isOn {
            //self.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark;
            
        }
        if !switchDarkMode.isOn {
            //overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func authSwitcher(_ sender: Any) {
        if switchAuth.isOn{
            UserDefaults.standard.set(true, forKey: "usesBiometricAuth")
        }
        if !switchAuth.isOn{
            UserDefaults.standard.set(false, forKey: "usesBiometricAuth")
        }
    }
    
    
}


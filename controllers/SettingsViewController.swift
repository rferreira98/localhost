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

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.cellForRow(at: IndexPath(row: 0, section: 3))?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.tableFooterView = UIView()
        //let sectionColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        let sectionColor = UIColor.systemBackground
        self.tableView.backgroundView?.backgroundColor = sectionColor
        self.tableView.backgroundColor = sectionColor
        self.tableView.separatorStyle = .none
        let footerView = UIView()
        footerView.backgroundColor =  sectionColor
        self.tableView.tableFooterView = footerView
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           self.tableView.deselectRow(at: indexPath, animated: true)

           if indexPath.section == 2 {
               if MFMailComposeViewController.canSendMail() {
                   let mail = MFMailComposeViewController()
                   mail.mailComposeDelegate = self
                   mail.setToRecipients(["xxxxxx@xxxxxx.com"])
                   mail.setSubject("App Contact")
                   
                   
                   present(mail, animated: true)
               } else {
                   let alert = Utils.triggerAlert(title: "Error", error: "Error opening e-mail app")
                   self.present(alert, animated: true, completion: nil)
               }
               
           }
           
       }
       
       func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
           controller.dismiss(animated: true)
       }
}


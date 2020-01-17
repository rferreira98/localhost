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

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var switchAuth: UISwitch!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var perfilLabel: UILabel!
    @IBOutlet weak var currentLanguageText: UITextField!
    let languages = [NSLocalizedString("English", comment: ""), NSLocalizedString("Portuguese", comment: "")]
    var languagePicker = UIPickerView()
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //removes the separator/line on the table cell
        tableView.cellForRow(at: IndexPath(row: 0, section: 3))?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        //if the user has dark mode enable in the system the button is set to on, otherwise to off
        
        
        switchAuth.setOn(UserDefaults.standard.bool(forKey: "usesBiometricAuth"), animated: true)
        
        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "metricUnit")
        
        let authLabel = tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.contentView.subviews[0] as! UILabel
        authLabel.text = NSLocalizedString("Authentication with", comment: "")  + Utils.getBiometricSensor()
        
        let firstname = UserDefaults.standard.value(forKey: "FirstName") as! String
        let lastname = UserDefaults.standard.value(forKey: "LastName") as! String
        
        perfilLabel.text = firstname + " " + lastname
        
        
        
        
        
        
    
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
        
        createPicker()
        
        currentLanguageText.delegate = self
        currentLanguageText.tintColor = .clear
        
        if UserDefaults.standard.string(forKey: "AppLanguage") == "en"{
            currentLanguageText.text = NSLocalizedString("English", comment: "")
            languagePicker.selectRow(0, inComponent: 0, animated: false)
        }else{
            currentLanguageText.text = NSLocalizedString("Portuguese", comment: "")
            languagePicker.selectRow(1, inComponent: 0, animated: false)
        }
        currentLanguageText.borderStyle = UITextField.BorderStyle.none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChangeNotification), name: NSNotification.Name(rawValue: "LANGUAGE_DID_CHANGE"), object: nil)
        languageDidChange()
        
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
    
    @objc func languageDidChangeNotification(notification:NSNotification){
        languageDidChange()
    }

    func languageDidChange(){
        
        if UserDefaults.standard.string(forKey: "AppLanguage") == "en"{
            currentLanguageText.text = NSLocalizedString("English", comment: "")
        }else{
            currentLanguageText.text = NSLocalizedString("Portuguese", comment: "")
        }
        
        tableView.reloadData()
    }
    
    func restartApplication () {
        let viewController = InitialViewController()
        let navCtrl = UINavigationController(rootViewController: viewController)

        guard
                let window = UIApplication.shared.keyWindow,
                let rootViewController = window.rootViewController
                else {
            return
        }

        navCtrl.view.frame = rootViewController.view.frame
        navCtrl.view.layoutIfNeeded()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navCtrl
        })

    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        //if the selected cell is the "contact" cell at index 2, opens the system mail app
        if indexPath.section == 2 {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["team.localh@gmail.com"])
                mail.setSubject(NSLocalizedString("App Contact", comment: ""))
                
                
                present(mail, animated: true)
            } else {
                let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Error opening email app", comment: ""))
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
    
    
    @IBAction func authSwitcher(_ sender: Any) {
        if switchAuth.isOn{
            UserDefaults.standard.set(true, forKey: "usesBiometricAuth")
        }
        if !switchAuth.isOn{
            UserDefaults.standard.set(false, forKey: "usesBiometricAuth")
        }
    }
    
    @IBAction func onValueSegmentedControlMetricUnitChange(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            UserDefaults.standard.set(0, forKey: "metricUnit")
        case 1:
            UserDefaults.standard.set(1, forKey: "metricUnit")
        default:
            break
        }
    }
    
   // picker methods
    
    @IBOutlet weak var languageCell: UITableViewCell!
 
    
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1;
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return languages.count
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return languages[row]
       
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        currentLanguageText.text = languages[row]
    
        
        
   }
    
    
   
   func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

       var label: UILabel

       if let view = view as? UILabel {
           label = view
       } else {
           label = UILabel()
       }

       
       label.textAlignment = .center
       label.text = languages[row]

       return label
   }
   
   func createPicker() {
       
        languagePicker.delegate = self
        currentLanguageText.inputView = languagePicker
        languagePicker.showsSelectionIndicator = true
    
       
       let toolBar = UIToolbar()
       toolBar.barStyle = UIBarStyle.default
       toolBar.isTranslucent = true
       toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
       toolBar.sizeToFit()

       let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector (self.dimissPicker))
       let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
       let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: UIBarButtonItem.Style.plain, target: self, action: #selector (self.dimissPickerReset))

       toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
       toolBar.isUserInteractionEnabled = true
       
       currentLanguageText.inputAccessoryView = toolBar
    
     

   }
   @objc func dimissPicker(){
       self.view.endEditing(true)
    
    if currentLanguageText.text == "English" || currentLanguageText.text == "Inglês" {
            UserDefaults.standard.set("en", forKey: "AppLanguage")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LANGUAGE_WILL_CHANGE"), object: "en")
        restartApplication()
            
        }else{
            UserDefaults.standard.set("pt", forKey: "AppLanguage")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LANGUAGE_WILL_CHANGE"), object: "pt")
            restartApplication()
        }
        
   }
   @objc func dimissPickerReset(){
       self.view.endEditing(true)
       
   }
   
    
}


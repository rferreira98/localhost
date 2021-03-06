//
//  ProfileViewController.swift
//  localhost
//
//  Created by Pedro Alves on 05/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//
import UIKit
import SDWebImage
import RSKImageCropper


class ProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, RSKImageCropViewControllerDelegate,
UIPickerViewDelegate, UIPickerViewDataSource{
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.hasChangedAvatar = true
        
        self.avatarImageView.image = croppedImage
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    var isEditingFields: Bool = false;
    var hasChangedAvatar = false;
    var profile: User?
    var localPicker = UIPickerView()
    var selectedCity = ""
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var localTextField: UITextField!
    @IBOutlet var tableProfile: UITableView!
    @IBOutlet weak var buttonLogout: UIButton!
    @IBOutlet weak var barButtonItemEdit: UIBarButtonItem!
    @IBOutlet weak var buttonLogoutDeleteBiometric: UIButton!
    @IBOutlet weak var ResetPasswordButton: UIButton!
    
    
    override func viewDidAppear(_ animated: Bool) {
        let rows = [0, 1, 2, 3, 4]
        
        for row in rows {
            let indexPath = IndexPath(row: row, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            
            let indexPath2 = IndexPath(row: 4, section: 1)
            let cell2 = tableView.cellForRow(at: indexPath2)
            cell2?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell2?.selectionStyle = UITableViewCell.SelectionStyle.none;
            
        }
        
        
        //self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))?.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        
        //tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.selectionStyle = .none
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))?.selectionStyle = .none
        self.tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
    
        if section == 1 && isEditingFields {
            return 0.0
        }
        return 30
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        if isEditingFields && section == 1{
            return 0
            
        }
        return count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
        avatarImageView.clipsToBounds = true
        
        self.tableView.separatorStyle = .none
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPicker();
        
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.localTextField.delegate = self
        
        
        
        tableProfile.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        if let token = UserDefaults.standard.value(forKey: "Token") as? String {
            self.profile = User(UserDefaults.standard.value(forKey: "Id") as! Int,
                                token,
                                UserDefaults.standard.value(forKey: "FirstName") as! String,
                                UserDefaults.standard.value(forKey: "LastName") as! String,
                                UserDefaults.standard.value(forKey: "Email") as! String,
                                UserDefaults.standard.value(forKey: "Local") as! String,
                                UserDefaults.standard.value(forKey: "AvatarURL") as! String,
                                UserDefaults.standard.value(forKey: "MessagingToken") as! String)
            
            
            self.firstNameTextField.text = self.profile!.firstName
            self.lastNameTextField.text = self.profile!.lastName
            self.emailTextField.text = self.profile!.email
            self.localTextField.text = self.profile!.local
        }
        
        if let avatarEncoded = UserDefaults.standard.value(forKey: "AvatarEncoded") as? String {
            if let decodedData = Data(base64Encoded: avatarEncoded, options: .ignoreUnknownCharacters) {
                let avatar = UIImage(data: decodedData)
                self.avatarImageView.image = avatar
            }
        } else {
            var imageCache = SDImageCache.shared
            imageCache.clearMemory()
            imageCache.clearDisk()
            
            let avatarName = profile!.avatar as! String
            let strUrl = NetworkHandler.domainUrl + "/storage/profiles/"+avatarName
            self.avatarImageView.sd_setImage(with: URL(string: strUrl), placeholderImage: UIImage(named: "NoAvatar"))
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    
    
    @IBAction func editClicked(_ sender: Any) {
        if isEditingFields {
            isEditingFields = false
            barButtonItemEdit.title = "Edit"
        } else {
            isEditingFields = true
            barButtonItemEdit.title = "Done"
            
        }
        
        
        self.firstNameTextField.isUserInteractionEnabled = isEditingFields
        self.lastNameTextField.isUserInteractionEnabled = isEditingFields
        //Profile email can't be changed
        self.localTextField.isUserInteractionEnabled = isEditingFields
        self.avatarImageView.isUserInteractionEnabled = isEditingFields
        
        if isEditingFields {
            
            self.avatarImageView.image = UIImage(named: "AddAvatar")
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.avatarUpload(_:)))
            avatarImageView.isUserInteractionEnabled = isEditingFields
            avatarImageView.addGestureRecognizer(tapImage)
            self.tableView.reloadData()
        }
        
        //User clicked "Done"
        if !isEditingFields {
            //Therefore check if fields have changed
            guard let userProfile = self.profile else {
                return
            }
            
            if let firstName = self.firstNameTextField.text {
                if firstName.isEmpty {
                    self.firstNameTextField.text = userProfile.firstName
                } else {
                    userProfile.firstName = firstName
                }
            }
            if let lastName = self.lastNameTextField.text {
                if lastName.isEmpty {
                    self.lastNameTextField.text = userProfile.lastName
                } else {
                    userProfile.lastName = lastName
                }
            }
            if let local = self.localTextField.text {
                if local.isEmpty || local == NSLocalizedString("Choose Local", comment: ""){
                    self.localTextField.text = userProfile.local
                } else {
                    userProfile.local = local
                }
            }
            
            if !hasChangedAvatar {
                if let avatarEncoded = UserDefaults.standard.value(forKey: "AvatarEncoded") as? String {
                    if let decodedData = Data(base64Encoded: avatarEncoded, options: .ignoreUnknownCharacters) {
                        let avatar = UIImage(data: decodedData)
                        self.avatarImageView.image = avatar
                    }
                } else {
                    var imageCache = SDImageCache.shared
                    imageCache.clearMemory()
                    imageCache.clearDisk()
                    
                    let avatarName = profile!.avatar as! String
                    let strUrl = NetworkHandler.domainUrl + "/storage/profiles/"+avatarName
                    self.avatarImageView.sd_setImage(with: URL(string: strUrl), placeholderImage: UIImage(named: "NoAvatar"))
                }
            }
            
            if self.hasChangedAvatar {
                NetworkHandler.uploadAvatar(avatar: self.avatarImageView.image!.resized(toWidth: 200)!){ (success, error) in
                    OperationQueue.main.addOperation {
                        if error != nil{
                            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                            self.present(alert, animated: true, completion: nil)
                        }else{
                            //success
                        }
                    }
                }
            } else {
                if let avatarEncoded = UserDefaults.standard.value(forKey: "AvatarEncoded") as? String {
                    if let decodedData = Data(base64Encoded: avatarEncoded, options: .ignoreUnknownCharacters) {
                        let avatar = UIImage(data: decodedData)
                        self.avatarImageView.image = avatar
                    }
                }
            }
            
            
            //userProfile filled
            if userProfile.profileChanged {
                let postUserData = NetworkHandler.PostUserData(first_name: userProfile.firstName, last_name: userProfile.lastName, local: userProfile.local)
                NetworkHandler.updateUser(post: postUserData) { (success, error) in
                    OperationQueue.main.addOperation {
                        
                        if error != nil {
                            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.goToMainScreen()
                        }
                    }
                    
                }
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    
    @objc func avatarUpload(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        
        let controller = UIImagePickerController()
        controller.delegate = self
        
        let actionsheet = UIAlertController(title: NSLocalizedString("Select Avatar", comment: ""), message: "Choose an Avatar", preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                controller.sourceType = .camera
                self.present(controller, animated: true, completion: nil)
            }else
            {
                print("Camera is Not Available")
            }
        }))
        
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .default, handler: { (action:UIAlertAction)in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }))
        
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(actionsheet,animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image: UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        
        picker.dismiss(animated: true, completion: { () -> Void in
            
            var imageCropVC: RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            
            imageCropVC.delegate = self
            
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
        })
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        NetworkHandler.logout() { (success, error) in
            OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.removeObject(forKey: "Token")
                    UserDefaults.standard.removeObject(forKey: "FirstName")
                    UserDefaults.standard.removeObject(forKey: "LastName")
                    UserDefaults.standard.removeObject(forKey: "AvatarEncoded")
                    //shouldn't remove email in this case because it will be needed for faceID
                    //UserDefaults.standard.removeObject(forKey: "Email")
                    UserDefaults.standard.removeObject(forKey: "Local")
                    UserDefaults.standard.synchronize()
                    
                    //go to first screen
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let first = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                    first.modalPresentationStyle = .fullScreen
                    //self.dismiss(animated: true, completion: nil)
                    self.present(first, animated: true, completion: nil)
                }
            }
            
        }
        
    }
    
    @IBAction func logoutDeleteBiometricClicked(_ sender: Any) {
        NetworkHandler.logout() { (success, error) in
            OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.removeObject(forKey: "Token")
                    UserDefaults.standard.removeObject(forKey: "FirstName")
                    UserDefaults.standard.removeObject(forKey: "LastName")
                    UserDefaults.standard.removeObject(forKey: "Email")
                    UserDefaults.standard.removeObject(forKey: "Local")
                    UserDefaults.standard.removeObject(forKey: "AvatarEncoded")
                    UserDefaults.standard.set(false, forKey: "usesBiometricAuth")
                    UserDefaults.standard.set(false, forKey: "biometricPrompted")
                    UserDefaults.standard.synchronize()
                    
                    //go to first screen
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let first = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                    first.modalPresentationStyle = .fullScreen
                    //self.dismiss(animated: true, completion: nil)
                    self.present(first, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    
    @IBAction func ResetPasswordButtonClicked(_ sender: Any) {
        // Create the action buttons for the alert.
        let defaultAction = UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default) { (action) in
            // Respond to user selection of the action.
            let email = self.profile?.email as! String
            
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Please wait", comment: ""), preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
            let postResetPass = NetworkHandler.PostResetPassword(email: email)
            
            NetworkHandler.resetPassword(post: postResetPass) { (success, error) in
                OperationQueue.main.addOperation {
                    if error != nil {
                        let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        alert.dismiss(animated: false, completion: nil)
                        let success = UIAlertController(title: NSLocalizedString("Reset Password", comment: ""), message: NSLocalizedString("Check your email for instructions on how to reset your password", comment: ""), preferredStyle: .alert)
                        success.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(success, animated: true, completion: nil)
                    }
                }
            }
        }
        
        // Create and configure the alert controller.
        let alert = UIAlertController(title: NSLocalizedString("Reset Password", comment: ""),
                                      message: NSLocalizedString("Do you really want to reset password?", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(defaultAction)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //Local picker methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Cities.cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Cities.cities[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCity = Cities.cities[row]
        localTextField.text = selectedCity
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        
        label.textAlignment = .center
        label.text = Cities.cities[row]
        
        return label
    }
    
    func createPicker() {
        
        
        localPicker.delegate = self
        localTextField.inputView = localPicker
        localPicker.showsSelectionIndicator = true
        
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
        
        localTextField.inputAccessoryView = toolBar
        
        //localPicker.backgroundColor = UIColor(named: "AppDarkBackground")
        //------------------------------------------------
        
    }
    
    func resetPicker() {
        self.localTextField.text = ""
        self.selectedCity = ""
    }
    
    @objc func dimissPicker(){
        self.view.endEditing(true)
    }
    @objc func dimissPickerReset(){
        self.view.endEditing(true)
        self.localTextField.text = profile?.local
        self.selectedCity = ""
    }
    
    func goToMainScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        //self.dismiss(animated: true, completion: nil)
        self.present(profileViewController, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }
        if (text.isEmpty) {
            return false
        }
        textField.resignFirstResponder()
        if textField == self.firstNameTextField {
            self.lastNameTextField.becomeFirstResponder()
        }
        return true
    }
}



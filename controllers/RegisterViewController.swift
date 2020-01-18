//
//  RegisterController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import RSKImageCropper
import InitialsImageView
import FirebaseMessaging

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, RSKImageCropViewControllerDelegate {
    
    var delegate: LoginHasBeenMade?
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        hasAddedAvatar = true;
        self.imageViewAvatar.image = croppedImage
        _ = self.navigationController?.popViewController(animated: true)
    }
    

    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    @IBOutlet weak var textFieldLocal: UITextField!
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    var hasAddedAvatar: Bool = false
   
    var localPicker = UIPickerView()
    var mvc: MapViewController?
    var selectedCity: String = ""
    
    let usesBiometricAuth = UserDefaults.standard.bool(forKey: "usesBiometricAuth")
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(false, forKey: "usesBiometricAuth")
        UserDefaults.standard.set(false, forKey: "biometricPrompted")
        UserDefaults.standard.synchronize()
        
        createPicker();
        
        textFieldFirstName.delegate = self
        textFieldLastName.delegate = self
        textFieldPassword.delegate = self
        textFieldConfirmPassword.delegate = self
        textFieldEmail.delegate = self
        textFieldLocal.delegate = self
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.avatarUpload(_:)))
        imageViewAvatar.isUserInteractionEnabled = true
        imageViewAvatar.addGestureRecognizer(tapImage)
        
        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        
        /*//Style textFieldFirstName
        //textFieldFirstName.backgroundColor = UIColor(named: "AppDarkBackground")
        //textFieldFirstName.textColor = UIColor.white
        textFieldFirstName.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldFirstName.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldFirstName.layer.borderWidth = 1.0;
        textFieldFirstName.layer.cornerRadius = 5.0;*/
        
        
        textFieldFirstName.backgroundColor = UIColor.white
        textFieldFirstName.textColor = UIColor.black
        textFieldFirstName.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("First Name", comment: ""),
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textFieldLastName.backgroundColor = UIColor.white
        textFieldLastName.textColor = UIColor.black
        textFieldLastName.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Last Name", comment: ""),
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textFieldEmail.backgroundColor = UIColor.white
        textFieldEmail.textColor = UIColor.black
        textFieldEmail.attributedPlaceholder = NSAttributedString(string: "E-mail",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textFieldLocal.backgroundColor = UIColor.white
        textFieldLocal.textColor = UIColor.black
        textFieldLocal.attributedPlaceholder = NSAttributedString(string: "Local",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textFieldPassword.backgroundColor = UIColor.white
        textFieldPassword.textColor = UIColor.black
        textFieldPassword.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textFieldConfirmPassword.backgroundColor = UIColor.white
        textFieldConfirmPassword.textColor = UIColor.black
        textFieldConfirmPassword.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Confirm Password", comment: ""),
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        
    }
    
    
    @objc func avatarUpload(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
        
        
        let controller = UIImagePickerController()
        controller.delegate = self
        
        let actionsheet = UIAlertController(title: NSLocalizedString("Select Avatar", comment: ""), message: NSLocalizedString("Choose an Avatar", comment: ""), preferredStyle: .actionSheet)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //imageViewAvatar.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        var image : UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        
        picker.dismiss(animated: true, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            
            imageCropVC.delegate = self
            
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
        })
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:  true, completion: nil)
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.height / 2
        imageViewAvatar.clipsToBounds = true
        
    }
    
    /// - returns: A Boolean value indicating whether an email is valid.
    func isValid(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print(totalTextFields)
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        

        
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textFieldFirstName.text != "" && textFieldLastName.text != "" {
            
            //Generate Avatar with name inittials
            if (!hasAddedAvatar){
                let name = textFieldFirstName.text! + " " + textFieldLastName.text!
                imageViewAvatar.setImageForName(name, backgroundColor: nil, circular: true, textAttributes: nil)
            }
            
        }
        
        if textFieldPassword.text != "" && textFieldConfirmPassword.text != "" && textFieldConfirmPassword.text != textFieldPassword.text{
            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Passwords don't match", comment: ""))
            self.present(alert, animated: true, completion: nil)
            textFieldConfirmPassword.text=""
        }
        
        if textFieldPassword.text!.count > 0 && textFieldPassword.text!.count < 6 || textFieldConfirmPassword.text!.count > 0 && textFieldConfirmPassword.text!.count < 6 {
            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Password should have at least 6 characters", comment: ""))
            self.present(alert, animated: true, completion: nil)
            textFieldConfirmPassword.text=""
            textFieldPassword.text=""
        }
    }
    
    
    @IBAction func registerClick(_ sender: Any) {
        let firstName = textFieldFirstName.text!
        let lastName = textFieldLastName.text!
        let password = textFieldPassword.text!
        let passwordConfirm = textFieldConfirmPassword.text!
        let email = textFieldEmail.text!
        let local = textFieldLocal.text!
        var image: UIImage!
        
        
        if textFieldFirstName.text!.isEmpty || textFieldLastName.text!.isEmpty || textFieldEmail.text!.isEmpty || textFieldPassword.text!.isEmpty || textFieldConfirmPassword.text!.isEmpty || (textFieldLocal.text!.isEmpty && textFieldLocal.text! == "Choose local"){
            
            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Some fields are empty", comment: ""))
            self.present(alert, animated: true, completion: nil)
        }else{
            if !isValid(email){
                let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Invalid Email", comment: ""))
                self.present(alert, animated: true, completion: nil)
            }else{
                let messagingToken = Messaging.messaging().fcmToken;
                let postRegist = NetworkHandler.PostRegister(first_name: firstName, last_name: lastName, password: password, password_confirmation: passwordConfirm, email: email, local: local, messaging_token: messagingToken!)
                
                
                NetworkHandler.register(post: postRegist) { (success, error) in
                    OperationQueue.main.addOperation {
                        
                        if error != nil {
                            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            
                            //------
                        
                            let postLogin = NetworkHandler.PostLogin(password: password, email: email)
                            NetworkHandler.login(post: postLogin) { (success, error) in
                                OperationQueue.main.addOperation {

                                    if error != nil {
                                        let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                                        self.present(alert, animated: true, completion: nil)
                                    } else {
                                        //Upload Avatar
                
                                        
                                        NetworkHandler.uploadAvatar(avatar: self.imageViewAvatar.image!.resized(toWidth: 200)!){ (success, error) in
                                            OperationQueue.main.addOperation {
                                                if error != nil{
                                                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                                                    self.present(alert, animated: true, completion: nil)
                                                }else{
                                                    //go to first screen
                                                    if UserDefaults.standard.bool(forKey: "biometricPrompted") {
                                                        self.goToMainScreen()
                                                    }else{
                                                        if !self.usesBiometricAuth {
                                                            self.displayActionSheet();
                                                        }else {
                                                            self.goToMainScreen()
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                    }
                                }

                            }

                        }
                    }
                }
            }
        }
    }
    
    func goToMainScreen(){
        UserDefaults.standard.set(0, forKey: "metricUnit")
        /*let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        self.dismiss(animated: true, completion: nil)
        self.present(loginViewController, animated: true, completion: nil)*/
        
        //let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //let first = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        //let mvc = MapViewController()
        //mvc.locals = self.locals
        
        //first.modalPresentationStyle = .fullScreen
        delegate?.sendBool(loginMade: true)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        //self.present(first, animated: true, completion: nil)
    }
    
    
    func displayActionSheet(){
    
        let actionBiometric = UIAlertController(title: NSLocalizedString("Authentication with", comment: "") + Utils.getBiometricSensor(), message: NSLocalizedString("Do you wish that future logins are made with", comment: "") + Utils.getBiometricSensor()+" ?", preferredStyle: .actionSheet)
                
            let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                UserDefaults.standard.set(true, forKey: "biometricPrompted")
                self.goToMainScreen()
            })
            let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                //If user accepts, save his login data on the KeyChain
                do {
                    let email = self.textFieldEmail.text!
                    let passwd : Data? = self.textFieldPassword.text!.data(using: .utf8)
                    let status = KeychainPasswordItem.save(key: email, data: passwd!)
                    UserDefaults.standard.set(true, forKey: "usesBiometricAuth")
                    UserDefaults.standard.set(true, forKey: "biometricPrompted")
                    self.goToMainScreen()
                } catch {
                  fatalError("Error updating keychain - \(error)")
                }
                
            })
            actionBiometric.addAction(noAction)
            actionBiometric.addAction(yesAction)
            self.present(actionBiometric, animated: true, completion: nil)
        
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
        textFieldLocal.text = selectedCity
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
        textFieldLocal.inputView = localPicker
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
        
        textFieldLocal.inputAccessoryView = toolBar
      

    }
    @objc func dimissPicker(){
        self.view.endEditing(true)
    }
    @objc func dimissPickerReset(){
        self.view.endEditing(true)
        resetPicker()
    }
    func resetPicker() {
        self.textFieldLocal.text = ""
        self.selectedCity = ""
    }
    
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}


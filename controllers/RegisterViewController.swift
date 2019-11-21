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

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, RSKImageCropViewControllerDelegate {
    
    
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
    
    var hasAddedAvatar: Bool = false
   
    var localPicker = UIPickerView()
    var mvc: MapViewController?
    var selectedCity: String = ""
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        /*
        //Style textFieldFirstName
        //textFieldFirstName.backgroundColor = UIColor(named: "AppDarkBackground")
        //textFieldFirstName.textColor = UIColor.white
        textFieldFirstName.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldFirstName.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldFirstName.layer.borderWidth = 1.0;
        textFieldFirstName.layer.cornerRadius = 5.0;
        
        //Style textFieldLastName
        //textFieldLastName.backgroundColor = UIColor(named: "AppDarkBackground")
        //textFieldLastName.textColor = UIColor.white
        textFieldLastName.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldLastName.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldLastName.layer.borderWidth = 1.0;
        textFieldLastName.layer.cornerRadius = 5.0;
        
        //Style textFieldPassword
        textFieldPassword.backgroundColor = UIColor(named: "AppDarkBackground")
        textFieldPassword.textColor = UIColor.white
        textFieldPassword.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldPassword.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldPassword.layer.borderWidth = 1.0;
        textFieldPassword.layer.cornerRadius = 5.0;
        
        //Style textFieldEmail
        textFieldEmail.backgroundColor = UIColor(named: "AppDarkBackground")
        textFieldEmail.textColor = UIColor.white
        textFieldEmail.attributedPlaceholder = NSAttributedString(string: "E-Mail",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldEmail.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldEmail.layer.borderWidth = 1.0;
        textFieldEmail.layer.cornerRadius = 5.0;
        
        
        //Style textFieldPassword
        //textFieldLocal.backgroundColor = UIColor(named: "AppDarkBackground")
        //textFieldLocal.textColor = UIColor.white
        textFieldLocal.attributedPlaceholder = NSAttributedString(string: "Local",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldLocal.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldLocal.layer.borderWidth = 1.0;
        textFieldLocal.layer.cornerRadius = 5.0;
 */
    }
    
    @objc func avatarUpload(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
        
        
        let controller = UIImagePickerController()
        controller.delegate = self
        
        let actionsheet = UIAlertController(title: "Select Photo", message: "Choose A Photo", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                controller.sourceType = .camera
                self.present(controller, animated: true, completion: nil)
            }else
            {
                print("Camera is Not Available")
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction)in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionsheet,animated: true, completion: nil)
        
        
        //controller.sourceType = .photoLibrary
        
        //controler.allowsEditing = true
        //self.present(controller, animated: true, completion: nil)
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
        
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
        "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
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
            let alert = Utils.triggerAlert(title: "Erro", error: "Passwords não coincidem")
            self.present(alert, animated: true, completion: nil)
            textFieldConfirmPassword.text=""
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
        
        if textFieldFirstName.text!.isEmpty || textFieldLastName.text!.isEmpty || textFieldEmail.text!.isEmpty || textFieldPassword.text!.isEmpty || textFieldConfirmPassword.text!.isEmpty || textFieldLocal.text!.isEmpty{
            
            let alert = Utils.triggerAlert(title: "Error", error: "Alguns campos estão vazios.")
            self.present(alert, animated: true, completion: nil)
        }else{
            if !isValid(email){
            
                let error = NetworkError(code: NetworkError.ERROR_CODE_USER_EMAIL_INVALID);
                let alert = Utils.triggerAlert(title: "Erro", error: error.message)
                self.present(alert, animated: true, completion: nil)
            }else{
                let postRegist = NetworkHandler.PostRegister(first_name: firstName, last_name: lastName, password: password, password_confirmation: passwordConfirm, email: email, local: local)
                
                NetworkHandler.register(post: postRegist) { (success, error) in
                    OperationQueue.main.addOperation {
                        
                        if error != nil {
                            let alert = Utils.triggerAlert(title: "Erro", error: error!.message)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            
                            //------
                            
                            //Upload Avatar
                            let token = UserDefaults.standard.value(forKey: "Token")
                            /*NetworkHandler.uploadAvatar(avatar: self.imageViewAvatar.image!, userId: userId as! Int){ (success, error) in
                                OperationQueue.main.addOperation {
                                    if error != nil{
                                        let alert = Utils.triggerAlert(title: "Erro", error: error?.message)
                                        self.present(alert, animated: true, completion: nil)
                                    }else{
                                        //go to first screen
                                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                                        self.present(loginViewController, animated: true, completion: nil)
                                    }
                                }
                            }*/
                            let postLogin = NetworkHandler.PostLogin(password: password, email: email)
                            NetworkHandler.login(post: postLogin) { (success, error) in
                                OperationQueue.main.addOperation {

                                    if error != nil {
                                        let alert = Utils.triggerAlert(title: "Erro", error: error!.message)
                                        self.present(alert, animated: true, completion: nil)
                                    } else {
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
    
    func goToMainScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        //self.dismiss(animated: true, completion: nil)
        self.present(loginViewController, animated: true, completion: nil)
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

        label.textColor = .white
        label.textAlignment = .center
        label.text = Cities.cities[row]

        return label
    }
    
    func createPicker() {
        localPicker.delegate = self
        textFieldLocal.inputView = localPicker
        //localPicker.backgroundColor = UIColor(named: "AppDarkBackground")

        //------------------------------------------------

    }
    
    func resetPicker() {
        self.textFieldLocal.text = ""
        self.selectedCity = ""
    }
}


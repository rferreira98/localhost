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

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
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
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var imageViewAvatar: UIImageView!
    
    var hasAddedAvatar: Bool = false
    var areas = [String]()
    var selectedAreas = [String]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldFirstName.delegate = self
        textFieldLastName.delegate = self
        textFieldPassword.delegate = self
        textFieldEmail.delegate = self
        textFieldUsername.delegate = self
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.avatarUpload(_:)))
        imageViewAvatar.isUserInteractionEnabled = true
        imageViewAvatar.addGestureRecognizer(tapImage)
        
        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
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
        //textFieldUsername.backgroundColor = UIColor(named: "AppDarkBackground")
        //textFieldUsername.textColor = UIColor.white
        textFieldUsername.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldUsername.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldUsername.layer.borderWidth = 1.0;
        textFieldUsername.layer.cornerRadius = 5.0;
    }
    
    @objc func avatarUpload(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
        
        let controler = UIImagePickerController()
        controler.sourceType = .photoLibrary
        controler.delegate = self
        //controler.allowsEditing = true
        self.present(controler, animated: true, completion: nil)
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
    }
    
    
    @IBAction func registerClick(_ sender: Any) {
        let firstName = textFieldFirstName.text!
        let lastName = textFieldLastName.text!
        let password = textFieldPassword.text!
        let email = textFieldEmail.text!
        let username = textFieldUsername.text!
        var image: UIImage!
        
        if textFieldFirstName.text!.isEmpty || textFieldLastName.text!.isEmpty || textFieldEmail.text!.isEmpty || textFieldPassword.text!.isEmpty{
            
            let alert = Utils.triggerAlert(title: "Error", error: "Some fields are empty.")
            self.present(alert, animated: true, completion: nil)
        }else{
            if !isValid(email){
            
                let alert = Utils.triggerAlert(title: "Error", error: "Invalid E-Mail")
                self.present(alert, animated: true, completion: nil)
            }else{
                
            }
        }
    }
    
}


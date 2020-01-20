//
//  LoginController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import FirebaseMessaging
import FBSDKCoreKit
import FBSDKLoginKit

protocol LoginHasBeenMade: NSObjectProtocol {
    func sendBool(loginMade: Bool)
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: LoginHasBeenMade?
    
    let facebookLogin = LoginManager()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var passwordItems: [KeychainPasswordItem] = []
    
    let biometric = BiometricAuth()
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var biometricLoginButton: UIButton!
    
    @IBOutlet weak var recoverPasswordBtn: UIButton!
    
    var usesBiometricAuth = UserDefaults.standard.bool(forKey: "usesBiometricAuth")
    var biometricType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
        
        
        //TouchID And Face ID Code --------------------------------------------------------------
        
        //UserDefaults.standard.set(false, forKey: "usesBiometricAuth")
        
        switch biometric.biometricType() {
        case .faceID:
            biometricType = "Face ID"
            biometricLoginButton.setImage(UIImage(named: "FaceIcon"), for: .normal)
        case .touchID:
            biometricType = "Touch ID"
            biometricLoginButton.setImage(UIImage(named: "TouchIcon"), for: .normal)
        default:
            return
        }
        
        
        
        if !usesBiometricAuth {
            biometricLoginButton.translatesAutoresizingMaskIntoConstraints = false
            biometricLoginButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
            biometricLoginButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
            biometricLoginButton.isHidden = true
        }
        
        //----------------------------------------------------------------------------------------
        
        
        
        
        
        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //Style textFieldEmail
        textFieldEmail.backgroundColor = UIColor.white
        textFieldEmail.tintColor = UIColor(named: "AppGreenDark")
        textFieldEmail.textColor = UIColor.black
        textFieldEmail.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("E-Mail", comment: ""),
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textFieldEmail.text = "pedro@alves.pt"
        
        
        textFieldEmail.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldEmail.layer.borderWidth = 1.0;
        textFieldEmail.layer.cornerRadius = 5.0;
        
        //Style textFieldPassword
        textFieldPassword.backgroundColor = UIColor.white
        textFieldPassword.tintColor = UIColor(named: "AppGreenDark")
        textFieldPassword.textColor = UIColor.black
        textFieldPassword.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: ""),
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textFieldPassword.text = "teste1"
        
        
        textFieldPassword.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldPassword.layer.borderWidth = 1.0;
        textFieldPassword.layer.cornerRadius = 5.0;
        
        
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        
        textFieldEmail.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
        
        let password = textFieldPassword.text!
        let email = textFieldEmail.text!
        
        
        
        if  textFieldEmail.hasText {
            if textFieldEmail.text!.isEmpty || textFieldPassword.text!.isEmpty {
                let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Email or Password empty", comment: ""))
                self.present(alert, animated: true, completion: nil)
                return;
            }
            if !isValid(email) {
                let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Email with incorrect format", comment: ""))
                self.present(alert, animated: true, completion: nil)
            } else {
                let myPost = NetworkHandler.PostLogin(password: password, email: email, messaging_token: Messaging.messaging().fcmToken!)
                NetworkHandler.login(post: myPost) { (success, error) in
                    OperationQueue.main.addOperation {
                        if error != nil {
                            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            if UserDefaults.standard.bool(forKey: "biometricPrompted") {
                                self.goToMainScreen()
                                print("ERRO")
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (UserDefaults.standard.value(forKey: "Email") != nil) {
            if textFieldEmail.text! != UserDefaults.standard.value(forKey: "Email") as! String {
                biometricLoginButton.isHidden = true
                self.usesBiometricAuth = false
                UserDefaults.standard.set(false, forKey: "usesBiometricAuth")
                UserDefaults.standard.removeObject(forKey: "biometricPrompted")
            }
        }
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
    
    
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
    @IBAction func inicioClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func goToMainScreen() {
        UserDefaults.standard.set(0, forKey: "metricUnit")
        /*let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let profileViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
         //self.dismiss(animated: true, completion: nil)
         self.present(profileViewController, animated: true, completion: nil)*/
        /*
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let first = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        //let mvc = MapViewController()
        //mvc.locals = self.locals
        
        first.modalPresentationStyle = .fullScreen
        //self.dismiss(animated: true, completion: nil)
        self.present(first, animated: true, completion: nil)*/
        delegate?.sendBool(loginMade: true)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func displayActionSheet(){
        
        let actionBiometric = UIAlertController(title: NSLocalizedString("Authentication with", comment: "")+biometricType, message: NSLocalizedString("Do you wish that future logins are made with", comment: "")+biometricType+" ?", preferredStyle: .actionSheet)
        
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
    
    @IBAction func biometricLoginClicked(_ sender: Any) {
        let email = UserDefaults.standard.value(forKey: "Email") as! String
        
        biometric.authenticateUser() { [weak self] in
            if let receivedData = KeychainPasswordItem.load(key: email) {
                let pwd = String(decoding: receivedData, as: UTF8.self)
                let myPost = NetworkHandler.PostLogin(password: pwd, email: email, messaging_token: Messaging.messaging().fcmToken!)
                
                NetworkHandler.login(post: myPost) { (success, error) in
                    OperationQueue.main.addOperation {
                        
                        if error != nil {
                            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                            self!.present(alert, animated: true, completion: nil)
                        } else {
                            self!.goToMainScreen()
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func onClickRecoverPasswordBtn(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Insert the email connected to your account", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Inser your email here", comment: "")
        })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
            if let email = alert.textFields?.first?.text {
                print("Your name: \(email)")
                alert.dismiss(animated: false, completion: {
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
                })
            }
        }))
        
        self.present(alert, animated: true)
        
        
    }
    
    @IBAction func facebookLoginClicked(_ sender: Any) {
        facebookLogin.logIn(permissions: ["public_profile", "email", "user_location"], from: self, handler: { result, error in
            if error != nil {
                let alert = Utils.triggerAlert(title: "Erro", error: "Ocorreu um erro, tente novamente")
                self.present(alert, animated: true, completion: nil)

                return
            }
            
            print(result)
            

            if (result?.isCancelled)! {
                let alert = Utils.triggerAlert(title: "Login cancelado", error: "Login pelo Facebook cancelado")
                self.present(alert, animated: true, completion: nil)
                print("Facebook login canceled")
                return;
            }
            print("Facebook login success")
            var access_token: String?
            if (result?.token?.tokenString != nil){
                access_token = result?.token?.tokenString
            }
            
            GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, location, picture.type(large)"]).start() {
                (connection, result, graphError) in

                if let error = graphError {
                    print(error.localizedDescription)
                    return
                }
                
                

                if let fields = result as? [String: Any] {
                    
                    var first_name: String?
                    var last_name: String?
                    var local: String?
                    var email: String?
                    var photo_url: String?
                    
                    if let imageURL = ((fields["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        photo_url = imageURL
                    }

                    if let firstName = fields["first_name"] as? String {
                        first_name = firstName
                    }

                    if let lastName = fields["last_name"] as? String {
                        last_name = lastName
                    }
                    
                    if let location = (fields["location"] as? [String: Any])?["name"] as? String {
                        local = location
                    }
                    
                    if let fbemail = fields["email"] as? String {
                        email = fbemail
                    }
                    
                    let myPost = NetworkHandler.PostFacebookLogin(access_token: access_token!, local: local!, messaging_token: Messaging.messaging().fcmToken!, first_name: first_name!, last_name: last_name!, email: email!, photo_url: photo_url!)
                    NetworkHandler.facebookLogin(post: myPost){ (success, error) in
                        OperationQueue.main.addOperation {
                            if error != nil {
                                let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                self.goToMainScreen()
                            }
                        }
                        
                    }
                    
                    
                    
                    //user is returned, save in storage as a normal login and proceds to map screen
                        

                }
            
            }
        }
        )}
            
            

            /*NetworkRequestsHandler.facebookLogin(accessToken: (result?.token.tokenString)!, completion: { (success, newUser, error) in

                guard error == nil else {
                    let alert = Utils.triggerAlert(title: "Erro", error: error!.message)
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large)"]).start() {
                    (connection, result, graphError) in

                    if let error = graphError {
                        print(error.localizedDescription)
                        return
                    }

                    if !success {
                        let alert = Utils.triggerAlert(title: "Erro", error: "Ocorreu um erro, tente novamente")
                        self.present(alert, animated: true, completion: nil)
                        return
                    }

                    if (!newUser) {
                        self.goToHome()
                        return
                    }

                    if let fields = result as? [String: Any] {
                        if let imageURL = ((fields["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                            NetworkRequestsHandler.downloadImage(from: imageURL, completion: { (uiImage, error) in
                                OperationQueue.main.addOperation {
                                    if (error != nil) {
                                        let alert = Utils.triggerAlert(title: "Erro", error: "Ocorreu um erro a obter a imagem de perfil do Facebook")
                                        self.present(alert, animated: true, completion: nil)
                                        return;
                                    }

                                    /*var imageCropVC: RSKImageCropViewController!

                                    imageCropVC = RSKImageCropViewController(image: uiImage!, cropMode: RSKImageCropMode.circle)

                                    imageCropVC.delegate = self

                                    self.navigationController?.pushViewController(imageCropVC, animated: true)*/
                                }

                            })
                        }

                        if let firstName = fields["first_name"] as? String {
                            self.facebookFirstName = firstName
                        }

                        if let lastName = fields["last_name"] as? String {
                            self.facebookLastName = lastName
                        }

                    }
                }

            })
        })
    }*/
}




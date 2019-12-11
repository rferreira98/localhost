//
//  LoginController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var passwordItems: [KeychainPasswordItem] = []
    
    let biometric = BiometricAuth()
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var biometricLoginButton: UIButton!
    
    
    let usesBiometricAuth = UserDefaults.standard.bool(forKey: "usesBiometricAuth")
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
        textFieldEmail.attributedPlaceholder = NSAttributedString(string: "E-Mail",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textFieldEmail.text = "pedro@alves.pt"
        
        
        textFieldEmail.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldEmail.layer.borderWidth = 1.0;
        textFieldEmail.layer.cornerRadius = 5.0;
        
        //Style textFieldPassword
        textFieldPassword.backgroundColor = UIColor.white
        textFieldPassword.tintColor = UIColor(named: "AppGreenDark")
        textFieldPassword.textColor = UIColor.black
        textFieldPassword.attributedPlaceholder = NSAttributedString(string: "Password",
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
                let alert = Utils.triggerAlert(title: "Erro", error: "E-Mail ou Password vazios")
                self.present(alert, animated: true, completion: nil)
                return;
            }
            if !isValid(email) {
                let alert = Utils.triggerAlert(title: "Erro", error: "E-Mail em formato incorreto.")
                self.present(alert, animated: true, completion: nil)
            } else {
                let myPost = NetworkHandler.PostLogin(password: password, email: email)
                
                NetworkHandler.login(post: myPost) { (success, error) in
                    OperationQueue.main.addOperation {
                        
                        if error != nil {
                            let alert = Utils.triggerAlert(title: "Erro", error: error)
                            self.present(alert, animated: true, completion: nil)
                        } else {
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
        self.goToMainScreen()
    }
    
    
    
    func goToMainScreen() {
        UserDefaults.standard.set(0, forKey: "metricUnit")
        /*let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        //self.dismiss(animated: true, completion: nil)
        self.present(profileViewController, animated: true, completion: nil)*/
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let first = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        //let mvc = MapViewController()
        //mvc.locals = self.locals
        
        first.modalPresentationStyle = .fullScreen
        //self.dismiss(animated: true, completion: nil)
        self.present(first, animated: true, completion: nil)
    }
    
    func displayActionSheet(){
    
        let actionBiometric = UIAlertController(title: "Autenticação com "+biometricType, message: "Deseja que futuros logins na sua conta possam ser feitos através de "+biometricType+" ?", preferredStyle: .actionSheet)
                
            let noAction = UIAlertAction(title: "Não", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                UserDefaults.standard.set(true, forKey: "biometricPrompted")
                self.goToMainScreen()
            })
            let yesAction = UIAlertAction(title: "Sim", style: .default, handler: {
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
                    let myPost = NetworkHandler.PostLogin(password: pwd, email: email)
                    
                    NetworkHandler.login(post: myPost) { (success, error) in
                        OperationQueue.main.addOperation {
                            
                            if error != nil {
                                let alert = Utils.triggerAlert(title: "Erro", error: error)
                                self!.present(alert, animated: true, completion: nil)
                            } else {
                                self!.goToMainScreen()
                            }
                        }
                        
                    }
            }
        }
    }
    
}




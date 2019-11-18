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

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self

        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)


        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        //Style textFieldEmail
        textFieldEmail.backgroundColor = UIColor.white
        textFieldEmail.textColor = UIColor.black
        textFieldEmail.attributedPlaceholder = NSAttributedString(string: "E-Mail",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])


        textFieldEmail.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldEmail.layer.borderWidth = 1.0;
        textFieldEmail.layer.cornerRadius = 5.0;

        //Style textFieldPassword
        textFieldPassword.backgroundColor = UIColor.white
        textFieldPassword.textColor = UIColor.black
        textFieldPassword.attributedPlaceholder = NSAttributedString(string: "Password",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])


        textFieldPassword.layer.borderColor = UIColor.lightGray.cgColor;
        textFieldPassword.layer.borderWidth = 1.0;
        textFieldPassword.layer.cornerRadius = 5.0;
    }

    @IBAction func loginClicked(_ sender: Any) {
        let password = textFieldPassword.text!
        let email = textFieldEmail.text!


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
                        let alert = Utils.triggerAlert(title: "Erro", error: error!.message)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.goToMainScreen()
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
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        self.dismiss(animated: true, completion: nil)
        self.present(loginViewController, animated: true, completion: nil)
    }

}




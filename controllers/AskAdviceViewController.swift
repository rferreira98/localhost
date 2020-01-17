//
//  AskAdviceViewController.swift
//  localhost
//
//  Created by Rúben Ricardo Monge Lauro on 28/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AskAdviceViewController: UIViewController, UITextViewDelegate {
    
    var currentUser: User = User(UserDefaults.standard.value(forKey: "Id") as! Int,
    UserDefaults.standard.value(forKey: "Token") as! String,
    UserDefaults.standard.value(forKey: "FirstName") as! String,
    UserDefaults.standard.value(forKey: "LastName") as! String,
    UserDefaults.standard.value(forKey: "Email") as! String,
    UserDefaults.standard.value(forKey: "Local") as! String,
    UserDefaults.standard.value(forKey: "AvatarURL") as? String,
    UserDefaults.standard.value(forKey: "MessagingToken") as! String)

    var local:Local!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var textViewQuestion: UITextView!
    @IBOutlet weak var restaurantLbl: UILabel!
    @IBOutlet weak var askAdviceBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.textViewQuestion.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewQuestion.layer.borderWidth = 1
        
        self.restaurantLbl.text = local.name
        
        self.textViewQuestion.delegate = self
    }
    

    @IBAction func onClickCancelBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"
        {
            textViewQuestion.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    @IBAction func onClickAskAdviceBtn(_ sender: Any) {
        if textViewQuestion.text.isEmpty || textViewQuestion.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: NSLocalizedString("Please fill the question field", comment: ""))
            self.present(alert, animated: true, completion: nil)
        } else {
            let postStoreQuestion = NetworkHandler.PostStoreQuestion(question: textViewQuestion.text)
            
            
            NetworkHandler.storeQuestion(post: postStoreQuestion, local_id: local.id) { (question, error) in
                OperationQueue.main.addOperation {
                    if error != nil {
                        let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.createNewChat(question!.id, self.textViewQuestion.text)
                        //self.performSegue(withIdentifier: "goToLocalDetail", sender: nil)
                        //self.questionToSend = question
                        //self.performSegue(withIdentifier: "goToChat", sender: nil)
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true){
                          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalIsDimissed"), object: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    func createNewChat(_ question_id: Int, _ message:String) {
        let data: [String: Any] = [
            "content": message,
            "created": Timestamp(),
            "id": UUID().uuidString,
            "senderID": "\(currentUser.id)",
            "senderName": "\(currentUser.firstName) \(currentUser.lastName)",
            "senderPhoto": "\(currentUser.avatar ?? "")"
        ]
        let db = Firestore.firestore().collection("Chats")
        // Add a new document in collection "cities"
        db.document("\(question_id)").collection("thread").addDocument(data: data){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let smld=segue.destination as? LocalDetailedViewController {
            smld.hasQuestion = self.questionCreated
        }
    }
 */
 
    

}

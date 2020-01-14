//
//  ChatViewController.swift
//  localhost
//
//  Created by Rúben Ricardo Monge Lauro on 27/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import InputBarAccessoryView
import Firebase
import MessageKit
import FirebaseFirestore
import SDWebImage

class ChatViewController: MessagesViewController {
    
    
    

    
    var currentUser: User = User(UserDefaults.standard.value(forKey: "Id") as! Int,
                                 UserDefaults.standard.value(forKey: "Token") as! String,
                                 UserDefaults.standard.value(forKey: "FirstName") as! String,
                                 UserDefaults.standard.value(forKey: "LastName") as! String,
                                 UserDefaults.standard.value(forKey: "Email") as! String,
                                 UserDefaults.standard.value(forKey: "Local") as! String,
                                 UserDefaults.standard.value(forKey: "AvatarURL") as? String,
                                 UserDefaults.standard.value(forKey: "MessagingToken") as! String)
    
    private var docReference: DocumentReference?
    var messages: [Message] = []
    //I've fetched the profile of user 2 in previous class from which
    //I'm navigating to chat view. So make sure you have the following
    //three variables information when you are on this class.
 
    var question: Question!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "\(question.place_name)"
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = UIColor(named: "AppGreenPrimary")
        if traitCollection.userInterfaceStyle == .dark {
            messageInputBar.inputTextView.backgroundColor = UIColor.black
            messagesCollectionView.backgroundColor = UIColor.black
            messageInputBar.contentView.backgroundColor = UIColor.black
            messageInputBar.backgroundView.backgroundColor = UIColor.black
        }
        messageInputBar.sendButton.setTitleColor(UIColor(named: "AppGreenPrimary"), for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        loadChat()
    }
    
    
    func loadChat() {
        //Fetch all the chats which has current user in it
        // let db = Firestore.firestore().collection("Chats").whereField("users", arrayContains: "\(currentUser.id)"/*Auth.auth().currentUser?.uid*/ ?? "Not Found User 1")
        let doc = Firestore.firestore().collection("Chats").document("\(question.id)")
        /*db.getDocuments { (chatQuerySnap, error) in
         if let error = error {
         print("Error: \(error)")
         return
         } else {
         //print(chatQuerySnap?.documents)
         //Count the no. of documents returned
         guard let queryCount = chatQuerySnap?.documents.count else {
         return
         }
         //Chat(s) found for currentUser
         for doc in chatQuerySnap!.documents {
         print(doc.data())
         //let chat = Chat(dictionary: doc.data())
         //Get the chat which has user2 id
         //if (chat?.users.contains("2"/*self.user2UID!*/))! {
         
         //fetch it's thread collection*/
        self.docReference = doc
        doc.collection("thread")
            .order(by: "created", descending: false)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                } else {
                    self.messages.removeAll()
                    for message in threadQuery!.documents {
                        let msg = Message(dictionary: message.data())
                        //print(message.data())
                        //print("Data: \(msg?.content ?? "No message found")")
                        self.messages.append(msg!)
                        //print("Data: \(msg?.content ?? "No message found")")
                    }
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
            })
        return
        //} //end of if
        //} //end of for
        //self.createNewChat() //not needed
        //}
        //}
    }
    
    private func insertNewMessage(_ message: Message) {
        //add the message to the messages array and reload it
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    private func save(_ message: Message) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName,
            "senderPhoto": message.senderPhoto
        ]
        //Writing it to the thread using the saved document reference we saved in load chat function
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            self.messagesCollectionView.scrollToBottom()
        })
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: "\(currentUser.id)",
            senderName: "\(currentUser.firstName) \(currentUser.lastName)", senderPhoto: currentUser.avatar!)
        //calling function to insert and save message
        insertNewMessage(message)
        save(message)
        //clearing input field
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        
    }
}


extension ChatViewController: MessagesDataSource {
    //This method return the current sender ID and name
    func currentSender() -> SenderType {
        //return Sender(id: "1234"/*Auth.auth().currentUser!.uid*/, displayName: "batatinha"/*Auth.auth().currentUser?.displayName*/ ?? "Name not found")
        return Sender(id: "\(currentUser.id)", displayName: "\(currentUser.firstName) \(currentUser.lastName)")
    }
    //This return the MessageType which we have defined to be text in Messages.swift
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    //Return the total number of messages
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
}



extension ChatViewController: MessagesLayoutDelegate {
    
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}


extension ChatViewController: MessagesDisplayDelegate {
    
    //Background colors of the bubbles
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue: .lightGray
    }
    //THis function shows the avatar
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //If it's current user show current user photo.
        if Int(message.sender.senderId) == currentUser.id {
            //print("passei aqui no meu")
            let strUrl = NetworkHandler.domainUrl + "/storage/profiles/"+currentUser.avatar!
            //print(strUrl)
            SDWebImageManager.shared.loadImage(with: URL(string: strUrl), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                avatarView.image = image
            }
        } else {
            var messagesAux = messages.filter{
                $0.senderID == message.sender.senderId
            }
            //print("passei aqui no dele index: \(indexPath.row)")
            let strUrl = NetworkHandler.domainUrl + "/storage/profiles/"+messagesAux[indexPath.row].senderPhoto
            //print(strUrl)
            SDWebImageManager.shared.loadImage(with: URL(string: strUrl), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                avatarView.image = image
            }
        }
    }
    
    //Styling the bubble to have a tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}


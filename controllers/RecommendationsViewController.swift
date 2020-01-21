//
//  RecommendationsViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class RecommendationsViewController: UITableViewController, UISearchBarDelegate{
    
    var questions = [Question]()
    
    var questionsAux = [Question]()
    
    var resultSearchController: UISearchController!
    
    var questionToSend:Question!
    
    var searchController = UISearchController(searchResultsController: nil)
    var filteredQuestions: [Question] = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    
    override func viewDidLoad(){
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Questions"
        // 4
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("My Questions", comment: ""), NSLocalizedString("Other Questions", comment: "")]
        searchController.searchBar.showsScopeBar = true
        
        searchController.searchBar.delegate = self
        /*
         //Sets the location of the search bar to the navigation bar (on the top of the screen)
         let searchBar = resultSearchController!.searchBar
         //navigationItem.searchController = resultSearchController
         self.navigationItem.titleView = searchBar
         searchBar.tintColor = UIColor(named: "AppGreenPrimary")
         searchBar.showsCancelButton = false
         searchBar.scopeButtonTitles = [NSLocalizedString("My Questions", comment: ""), NSLocalizedString("Other Questions", comment: "")]
         searchBar.showsScopeBar = true
         searchBar.delegate = self
         */
        
        
        /*
         
         for subView in searchBar.subviews {
         
         if let scopeBar = subView as? UISegmentedControl {
         scopeBar.backgroundColor = UIColor.blue
         
         scopeBar.addTarget(self, action: #selector(changeColor), for: .valueChanged)
         }
         
         }
         */
        
        getQuestions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let searchBar = searchController.searchBar.selectedScopeButtonIndex
        if searchBar == 0{
            self.questionsAux = self.questions.filter{$0.isMine == 1}
            tableView.reloadData()
        } else {
            self.questionsAux = self.questions.filter{$0.isMine == 0}
            tableView.reloadData()
        }
        
        //self.navigationItem.title = ""
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController.searchBar.endEditing(true)
        if(self.isSearchBarEmpty){
            self.searchController.isActive = false
        }
        self.navigationItem.hidesSearchBarWhenScrolling = false
        //navigationController?.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Checks is iOS 13 is available and if it is it sets the selected tab to green color, because the previous tint color method is not suported on ios 13+
        
        
        //if #available(iOS 13.0, *) {
        //    segmentedControl.selectedSegmentTintColor = UIColor(named: "AppGreenPrimary")
        //}
        //------------------------------------
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! QuestionTableViewCell
        let question:Question
        
        
        if isFiltering {
            question = filteredQuestions[indexPath.row]
        } else {
            question = questionsAux[indexPath.row]
        }
        cell.restaurantNameLbl.text = question.place_name
        cell.restaurantCityLbl.text = question.place_city.capitalizingFirstLetter()
        cell.restaurantImage.sd_setImage(with: URL(string: question.place_image_url), placeholderImage: UIImage(named: "NoPhotoRestaurant"))
        //cell.localPhoto.image = cropToBounds(image: cell.localPhoto.image!, width: 80, height: 80)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredQuestions.count
        }
        return questionsAux.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question:Question
        
        
        if isFiltering {
            question = filteredQuestions[indexPath.row]
        } else {
            question = questionsAux[indexPath.row]
        }
        
        questionToSend = question
        
        performSegue(withIdentifier: "segueQuestionChat", sender: nil)
    }
    
    /*
     @objc func changeColor(sender: UISegmentedControl) {
     print("Changing Color to ")
     switch sender.selectedSegmentIndex {
     case 1:
     print("Green")
     case 2:
     print("Blue")
     default:
     print("NONE")
     }
     }
     */
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            self.questionsAux = self.questions.filter{$0.isMine == 1}
            tableView.reloadData()
        case 1:
            self.questionsAux = self.questions.filter{$0.isMine == 0}
            tableView.reloadData()
        default:
            return
        }
        
        print("New scope index is now \(selectedScope)")
    }
    
    private func getQuestions() {
        NetworkHandler.getQuestions(completion: {
            (questions, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    self.questions = questions ?? []
                    self.questionsAux = questions?.filter{$0.isMine == 1} ?? []
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let smld=segue.destination as? ChatViewController {
            smld.question = self.questionToSend
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            let closeAction = UIContextualAction(style: .normal, title:  "Close", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("OK, marked as Closed")
                let alert = UIAlertController(title: "Did you want to delete the question ?", message: "Deleting is a permanent action cannot be undone", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    let question: Question = self.questionsAux[indexPath.row]
                    DispatchQueue.global(qos: .background).async {
                        self.deleteFirebase(chat_id: question.id)
                    }
                    
                    NetworkHandler.deleteChat(question_id: question.id, completion: { (success, error) in
                        OperationQueue.main.addOperation {
                            if error != nil {
                                let alert = Utils.triggerAlert(title: "Erro", error: error)
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                //dizer que removeu
                                let alert = UIAlertController(title: "Chat deleted successfully",
                                                              message: nil, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                                    
                                    for (index, questionAux) in self.questions.enumerated() {
                                        if question.id == questionAux.id {
                                            self.questions.remove(at: index)
                                            break
                                        }
                                    }
                                    self.tableView.reloadData()
                                }))
                                
                                self.present(alert, animated: true)
                            }
                        }
                    })
                    
                    self.questionsAux.remove(at: indexPath.row)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
                success(true)
            })
            if #available(iOS 13.0, *) {
                closeAction.image = UIImage(systemName: "trash")
            } else {
                // Fallback on earlier versions
                closeAction.image = UIImage(named: "trash")
            }
            closeAction.backgroundColor = .red
            
            return UISwipeActionsConfiguration(actions: [closeAction])
        }
        return nil
    }
    
    func deleteFirebase(chat_id:Int) -> Void {
        let db = Firestore.firestore().collection("Chats")
        self.delete(collection: db.document("\(chat_id)").collection("thread"))
    }
    
    func delete(collection: CollectionReference, batchSize: Int = 100) {
        // Limit query to avoid out-of-memory errors on large collections.
        // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
        collection.limit(to: batchSize).getDocuments { (docset, error) in
            // An error occurred.
            let docset = docset
            
            let batch = collection.firestore.batch()
            docset?.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit {_ in
                self.delete(collection: collection, batchSize: batchSize)
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredQuestions = questionsAux.filter { (question: Question) -> Bool in
            return question.place_name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension RecommendationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

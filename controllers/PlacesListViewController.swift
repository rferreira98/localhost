//
//  PlacesListViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import SDWebImage

class PlacesListViewController: UITableViewController, UISearchBarDelegate {
    //var resultSearchController: UISearchController!
    var locals = [Local]()
    //var searchBar: UISearchBar!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var localToSend: Local!
    
    var tapGesture: UITapGestureRecognizer?
    
    var filteredLocals: [Local] = []
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        self.locals = Items.sharedInstance.locals
        
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        
        // 3
        searchController.searchBar.placeholder = "Search Places"
        // 4
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
        
        
        if User.hasUserLoggedIn(){
            searchController.searchBar.scopeButtonTitles = ["Places", "Favorites"]
            searchController.searchBar.showsScopeBar = true
        } else {
            searchController.searchBar.showsScopeBar = false
        }
            
        searchController.searchBar.delegate = self
        /*
         let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableController
         resultSearchController = UISearchController(searchResultsController: locationSearchTable)
         resultSearchController.searchResultsUpdater = locationSearchTable
         searchBar = resultSearchController!.searchBar
         //navigationItem.searchController = resultSearchController
         self.navigationItem.titleView = searchBar
         resultSearchController.hidesNavigationBarDuringPresentation = false
         definesPresentationContext = true
         searchBar.showsCancelButton = false
         searchBar.scopeButtonTitles = ["Perguntas", "Questões"]
         searchBar.showsScopeBar = true
         */
        /*DispatchQueue.main.async { [unowned self] in
         self.searchBar.becomeFirstResponder()
         }*/
        
        /*
         let buttonFilter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(segueFilters))
         self.navigationItem.rightBarButtonItem  = buttonFilter
         */
        
        
        //pull to refresh
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Puxe para atualizar")
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        
        //----------------
        getFavorites(reset_data: false)
    }
    /*
    override func viewDidAppear(_ animated: Bool) {
        getFavorites()
        tableView.reloadData()
    }*/
    
    func filterContentForSearchText(_ searchText: String) {
        filteredLocals = locals.filter { (local: Local) -> Bool in
            return local.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        getLocals()
    }
    
    @objc func segueFilters(){
        performSegue(withIdentifier: "listFiltersButton", sender: nil)
    }
    
    private func getLocals(){
        /*NetworkHandler.getLocals() {
         (locals, error) in OperationQueue.main.addOperation {
         if error != nil {
         let alert = Utils.triggerAlert(title: "Erro", error: error)
         self.present(alert, animated: true, completion: nil)
         }
         else{
         
         for local in locals!{
         self.locals.append(local)
         }
         
         //DispatchQueue.main.async { self.tableView.reloadData() }
         self.tableView.reloadData()
         print("GOT LOCALS")
         
         //self.drawLocalPins()
         }
         }
         }*/
    }
    
    /*
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     print("touch")
     self.searchBar.endEditing(true)
     view.endEditing(true)
     }
     */
    
    /*override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 1
     }*/
    
    private func getFavorites(reset_data: Bool) {
        NetworkHandler.getFavorites(completion: {
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    Items.sharedInstance.favorites.removeAll()
                    for local in locals!{
                        Items.sharedInstance.favorites.append(local)
                    }
                    if(reset_data){
                        self.locals = Items.sharedInstance.favorites
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            self.locals = Items.sharedInstance.locals
            tableView.reloadData()
        case 1:
            getFavorites(reset_data: true)
        default:
            return
        }
        
        print("New scope index is now \(selectedScope)")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredLocals.count
        }
        return locals.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let local:Local
        
        if isFiltering {
            local = filteredLocals[indexPath.row]
        } else {
            local = locals[indexPath.row]
        }
        
        localToSend = local
        
        performSegue(withIdentifier: "segueLocalDetail", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localCell", for: indexPath) as! LocalTableViewCell
        
        let local:Local
        
        if isFiltering {
            local = filteredLocals[indexPath.row]
        } else {
            local = locals[indexPath.row]
        }
        cell.localName.text = local.name
        var typesStr: String = ""
        for type in local.types {
            typesStr += type+" "
        }
        cell.localType.text = typesStr
        cell.localAddress.text = local.address
        cell.ratingView.isHidden = false
        cell.ratingView.isUserInteractionEnabled = false
        cell.ratingView.rating = local.avgRating
        cell.localPhoto.contentMode = .scaleAspectFill
        cell.localPhoto.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "NoAvatar"))
        //cell.localPhoto.image = cropToBounds(image: cell.localPhoto.image!, width: 80, height: 80)
        
        return cell
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PlacesListViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture!)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapGesture!)
    }
    
    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let smld=segue.destination as? LocalDetailedViewController {
            smld.local = self.localToSend
        }
    }
    
    
}

extension PlacesListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}





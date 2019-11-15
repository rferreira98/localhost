//
//  PlacesListViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit

class PlacesListViewController: UITableViewController {
    
    var resultSearchController: UISearchController!
    
    override func viewDidLoad() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        //navigationItem.searchController = resultSearchController
        self.navigationItem.titleView = searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchBar.tintColor = UIColor(named: "AppGreenPrimary")
        searchBar.showsCancelButton = false
        
        
        let buttonFilter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(segueFilters))
        self.navigationItem.rightBarButtonItem  = buttonFilter
    }
    
    @objc func segueFilters(){
        performSegue(withIdentifier: "listFiltersButton", sender: nil)
    }
}

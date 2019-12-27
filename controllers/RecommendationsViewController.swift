//
//  RecommendationsViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import UIKit

class RecommendationsViewController: UITableViewController, UISearchBarDelegate{

    var resultSearchController: UISearchController!
    
    
    override func viewWillAppear(_ animated: Bool) {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        resultSearchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        //-------------------------------------------------------------------------
        
        //Sets the location of the search bar to the navigation bar (on the top of the screen)
        let searchBar = resultSearchController!.searchBar
        //navigationItem.searchController = resultSearchController
        self.navigationItem.titleView = searchBar
        searchBar.tintColor = UIColor(named: "AppGreenPrimary")
        searchBar.showsCancelButton = false
        searchBar.scopeButtonTitles = ["Perguntas", "Questões"]
        searchBar.showsScopeBar = true
        
        
        for subView in searchBar.subviews {
            
            if let scopeBar = subView as? UISegmentedControl {
                scopeBar.backgroundColor = UIColor.blue
                
                scopeBar.addTarget(self, action: #selector(changeColor), for: .valueChanged)
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        //Checks is iOS 13 is available and if it is it sets the selected tab to green color, because the previous tint color method is not suported on ios 13+
        
    
        //if #available(iOS 13.0, *) {
        //    segmentedControl.selectedSegmentTintColor = UIColor(named: "AppGreenPrimary")
        //}
        //------------------------------------
        
        
    }
    
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

    
}

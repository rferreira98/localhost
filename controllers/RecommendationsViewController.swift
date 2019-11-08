//
//  RecommendationsViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import UIKit

class RecommendationsViewController: UITableViewController{
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidAppear(_ animated: Bool) {
        //Checks is iOS 13 is available and if it is it sets the selected tab to green color, because the previous tint color method is not suported on ios 13+
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = UIColor(named: "AppGreenPrimary")
        } 
        //------------------------------------
    }
}

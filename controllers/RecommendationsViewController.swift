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
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = UIColor(named: "AppGreenPrimary")
        } else {
            
        }
    }
}

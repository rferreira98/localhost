//
//  InfoViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import UIKit



class InfoViewController: UITableViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.cellForRow(at: IndexPath(row: 0, section: 3))?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var sectionColor:UIColor
        if #available(iOS 13.0, *) {
            sectionColor = UIColor.systemBackground
        }else{
            sectionColor = UIColor.white
        }
        
        self.tableView.backgroundView?.backgroundColor = sectionColor
        self.tableView.backgroundColor = sectionColor
        self.tableView.separatorStyle = .none
        let footerView = UIView()
        footerView.backgroundColor =  sectionColor
        self.tableView.tableFooterView = footerView
        
    }
    
    
   
}


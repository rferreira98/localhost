//
//  LocalTableViewCell.swift
//  localhost
//
//  Created by Pedro Alves on 02/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import Cosmos

class LocalTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var ratingView: CosmosView!

    
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


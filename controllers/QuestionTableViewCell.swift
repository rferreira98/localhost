//
//  QuestionTableViewCell.swift
//  localhost
//
//  Created by Rúben Ricardo Monge Lauro on 30/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantNameLbl: UILabel!
    @IBOutlet weak var restaurantCityLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ReviewTableViewCell.swift
//  localhost
//
//  Created by Pedro Alves on 06/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//


import UIKit
import Cosmos
class ReviewTableViewCell: UITableViewCell{
    
    /*@IBOutlet weak var labelReviewUser: UILabel!
    @IBOutlet weak var imageViewUserReviewer: UIImageView!
    @IBOutlet weak var ratingReview: CosmosView!
    @IBOutlet weak var labelReview: UILabel!*/
    @IBOutlet weak var labelReviewUser: UILabel!
    @IBOutlet weak var labelReview: UILabel!
    @IBOutlet weak var imageViewUserReviewer: UIImageView!
    @IBOutlet weak var ratingReview: CosmosView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}


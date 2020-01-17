//
//  ListReviewsViewController.swift
//  localhost
//
//  Created by Pedro Alves on 17/01/2020.
//  Copyright © 2020 Pedro Miguel Prates Alves. All rights reserved.
//

import UIKit

class ListReviewsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var reviews:[Review?] = []
        
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var NoReviewsLabel: UILabel!
    
    override func viewDidLoad() {
        self.reviewsTableView.delegate = self
        self.reviewsTableView.dataSource = self
        if reviews.isEmpty {
            reviewsTableView.removeFromSuperview()
        }else{
            NoReviewsLabel.removeFromSuperview()
            self.reviewsTableView.reloadData()
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        let review = reviews[indexPath.row]
        
        cell.isUserInteractionEnabled = false
        cell.ratingReview.rating = review?.rating ?? 0
        cell.labelReview.text = review?.text
        cell.labelReview.numberOfLines = 0
        cell.labelReviewUser.text = review?.user_name
        cell.imageViewUserReviewer.contentMode = .scaleAspectFill
        
        cell.imageViewUserReviewer.layer.cornerRadius = cell.imageViewUserReviewer.frame.size.height / 2
        cell.imageViewUserReviewer.clipsToBounds = true
        
        if review?.user_image != nil {
            cell.imageViewUserReviewer.sd_setImage(with: URL(string: (review?.user_image)!), placeholderImage: UIImage(named: "NoAvatar"))
        }
        else{
            cell.imageViewUserReviewer.image = UIImage(named: "NoAvatar")
        }
        
        
        return cell
    }
    
}

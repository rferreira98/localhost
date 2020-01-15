//
//  ReviewsViewController.swift
//  localhost
//
//  Created by Ricardo Filipe Ribeiro Ferreira on 14/01/2020.
//  Copyright © 2020 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var reviews:[Review?] = []
    @IBOutlet weak var dragDownButton: UIButton!
    @IBOutlet weak var reviewsTableView: UITableView!
    
    
    @IBAction func buttonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.reviewsTableView.delegate = self
        self.reviewsTableView.dataSource = self
        self.reviewsTableView.reloadData()
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

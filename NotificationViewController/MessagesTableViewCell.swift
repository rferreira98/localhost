//
//  MessagesTableViewCell.swift
//  NotificationViewController
//
//  Created by Miguel Sousa on 20/01/2020.
//  Copyright © 2020 Pedro Miguel Prates Alves. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var message: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

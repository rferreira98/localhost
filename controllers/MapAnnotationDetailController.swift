//
//  MapAnnotationDetailController.swift
//  localhost
//
//  Created by Pedro Alves on 26/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import SDWebImage


class MapAnnotationDetailController: UIView {
    
    class func instanceFromNib() -> MapAnnotationDetailController {
        return UINib(nibName: "MapAnnotationDetail", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MapAnnotationDetailController
    }
    
}

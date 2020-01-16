//
//  ArtworkView.swift
//  localhost
//
//  Created by Pedro Alves on 05/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import MapKit
import Cosmos

class ArtworkView: MKAnnotationView {
    
    static let preferredClusteringIdentifier = Bundle.main.bundleIdentifier! + ".UserAnnotationView"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = UserAnnotationView.preferredClusteringIdentifier
        collisionMode = .circle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? Artwork else {return}
            canShowCallout = false
            calloutOffset = CGPoint(x: 0, y: 5)
            /*
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
               size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Info"), for: UIControl.State())
            rightCalloutAccessoryView = mapsButton*/
            image = UIImage(named: "NewMarker")
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            label.textColor = .black
            label.shadowColor = .white
            label.numberOfLines = 3
            label.font = label.font.withSize(12)
            label.text = artwork.title // set text here
            label.textAlignment = .center
            label.preferredMaxLayoutWidth = 100
            self.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            let verticalSpace = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 1)
            let centerAlignment = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal,toItem: self,attribute: .centerX, multiplier: 1, constant: 0)
            // activate the constraints
            NSLayoutConstraint.activate([verticalSpace, centerAlignment])
            
            


            /*
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = artwork.subtitle
            detailLabel.textColor = UIColor.lightGray
            //detailCalloutAccessoryView = detailLabel
            
            
            let classification = CosmosView(frame: CGRect(origin: CGPoint.zero,
            size: CGSize(width: 30, height: 30)))
            classification.isUserInteractionEnabled = false
            classification.rating = artwork.localRating
            
        
            
            
            
            detailCalloutAccessoryView = classification
*/
            
            
            /*detailCalloutAccessoryView!.addConstraint(NSLayoutConstraint(item: classification, attribute: .trailing, relatedBy: .equal, toItem: detailLabel, attribute: .trailing, multiplier: 1, constant: 0))
            
            detailCalloutAccessoryView!.addConstraint(NSLayoutConstraint(item: classification, attribute: .top, relatedBy: .equal, toItem: detailCalloutAccessoryView, attribute: .bottom, multiplier: 1, constant: 0))*/
            
            //detailCalloutAccessoryView?.addSubview(classification)
            /*
            detailCalloutAccessoryView!.addConstraint(NSLayoutConstraint(item: classification, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 131))
            /*view.addConstraint(NSLayoutConstraint(item: gamePreview, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))

            view.addConstraint(NSLayoutConstraint(item: gamePreview, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: gamePreview, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,multiplier: 1, constant: 131))*/
            */
            
        }
    }
    
    
    
    
}

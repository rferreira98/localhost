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
    var label: UILabel!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //clusteringIdentifier = UserAnnotationView.preferredClusteringIdentifier
        clusteringIdentifier = ArtworkView.preferredClusteringIdentifier
        collisionMode = .circle
        label.text = annotation?.title!
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.textColor = UIColor(named: "AppGreenPrimary")
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .center
        label.preferredMaxLayoutWidth = 100
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalSpace = NSLayoutConstraint(item: self.label!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 1)
        let centerAlignment = NSLayoutConstraint(item: self.label!, attribute: .centerX, relatedBy: .equal,toItem: self,attribute: .centerX, multiplier: 1, constant: 0)
        // activate the constraints
        NSLayoutConstraint.activate([verticalSpace, centerAlignment])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        label.shadowColor = traitCollection.userInterfaceStyle == .dark ? .darkGray : .white
    }
    
    override var annotation: MKAnnotation? {
        
        willSet{
            guard let artwork = newValue as? Artwork else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 5)
            clusteringIdentifier = ArtworkView.preferredClusteringIdentifier
            image = UIImage(named: "NewMarker")
            if self.label.text == nil {
                self.label.text = artwork.title!
                label.translatesAutoresizingMaskIntoConstraints = false
                
                self.label.removeFromSuperview()
                self.addSubview(label)
                let verticalSpace = NSLayoutConstraint(item: self.label!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 1)
                let centerAlignment = NSLayoutConstraint(item: self.label!, attribute: .centerX, relatedBy: .equal,toItem: self,attribute: .centerX, multiplier: 1, constant: 0)
                // activate the constraints
                NSLayoutConstraint.activate([verticalSpace, centerAlignment])
            }
            
            
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
               size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Info"), for: UIControl.State())
            
            rightCalloutAccessoryView = mapsButton
            image = UIImage(named: "NewMarker")
            
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

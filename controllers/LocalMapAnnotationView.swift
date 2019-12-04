//
//  LocalMapAnnotationView.swift
//  localhost
//
//  Created by Pedro Alves on 30/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocalMapAnnotationView: MKAnnotationView {
  
    
        /*var mapLocalDetailDelegate: LocalMapDetailViewControllerDelegate?
        var customCalloutView: LocalMapDetailViewController?
        override var annotation: MKAnnotation? {
            willSet { customCalloutView?.removeFromSuperview() }
        }*/
        
        // MARK: - life cycle
        
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            self.canShowCallout = false // 1
            self.image = UIImage(named: "GeneralMarker")
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.canShowCallout = false // 1
            self.image = UIImage(named: "GeneralMarker")
        }
        
    // MARK: - callout showing and hiding
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected { // 2
            self.customCalloutView?.removeFromSuperview() // remove old custom callout (if any)
            
            
            
            if let newCustomCalloutView = loadListingDetailMapView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: 1, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else { // 3
            if customCalloutView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: 1, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { (success) in
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else { self.customCalloutView!.removeFromSuperview() } // just remove it.
            }
        }
    }
        
        func loadListingDetailMapView() -> ListingMapDetailViewController? { // 4
            /*let views = Bundle.main.loadNibNamed("ListingMapDetailView", owner: nil, options: nil)
            let calloutView = views?[0] as! ListingMapDetailViewController
            return calloutView*/
            if let views = Bundle.main.loadNibNamed("ListingMapDetailView", owner: self, options: nil) as? [ListingMapDetailViewController], views.count > 0 {
                let listingMapDetailViewController = views.first!
                listingMapDetailViewController.delegate = self.mapListingDetailDelegate
                if let selectedAnnotation = annotation as? CustomAnnotation {
                    listingMapDetailViewController.configureListing(listing: selectedAnnotation.listing!)
                    /*if selectedAnnotation.offer == nil{
                        listingMapDetailViewController.configureSearch(listing: selectedAnnotation.search!)
                    }else{
                        listingMapDetailViewController.configureOffer(listing: selectedAnnotation.offer!)
                    }*/
                    
                    
                    
                    
                }
                return listingMapDetailViewController
            }
            return nil
        }
        
        override func prepareForReuse() { // 5
            super.prepareForReuse()
            self.customCalloutView?.removeFromSuperview()
        }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else { return nil }
        }
    }
    
    /*func loadListingMapDetailViewController() -> ListingMapDetailViewController? {
       
    }*/

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

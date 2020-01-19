//
//  Artwork.swift
//  localhost
//
//  Created by Pedro Alves on 04/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let localRating: Double
    let local: Local
    let titleView: UIView?
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D, localRating: Double, local: Local, titleView: UIView?) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.localRating = localRating
        self.local = local
        self.titleView = titleView
        
        
        
       
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
      let addressDict = [CNPostalAddressStreetKey: subtitle!]
      let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = title
      return mapItem
    }

}

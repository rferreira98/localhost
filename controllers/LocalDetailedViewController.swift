//
//  LocalDetailedViewController.swift
//  localhost
//
//  Created by Pedro Alves on 05/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import Cosmos

class LocalDetailedViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var reviews = [Review?]()
    
    var coordinate: CLLocationCoordinate2D!
    var local:Local!
    @IBOutlet weak var labelLocalName: UILabel!
    @IBOutlet weak var labelLocalType: UILabel!
    @IBOutlet weak var labelLocalAddress: UILabel!
    @IBOutlet weak var buttonMapDirections: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var labelQtReviews: UILabel!
    
    override func viewDidLoad() {
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = false
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = true
        mapView.isUserInteractionEnabled = false
        
        reviews = local.reviews
        print(local.reviews.count)
        print(reviews.count)
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: CLLocationDegrees(local.latitude))!,
                                                 longitude: CLLocationDegrees(exactly: CLLocationDegrees(local.longitude))!)
        self.drawMapWithLocation(selectedCoordinate: self.coordinate!)
        
        self.labelLocalName.text = local.name
        var typesStr: String = ""
        for type in local.types {
            typesStr += type+" "
        }
        self.labelLocalType.text = typesStr
        self.labelLocalAddress.numberOfLines = 0
        self.labelLocalAddress.text = local.address
        self.ratingView.isUserInteractionEnabled = false
        self.ratingView.rating = self.local.avgRating
        self.labelQtReviews.text = String(local.qtReviews)
        
    }
    
    public func drawMapWithLocation(selectedCoordinate: CLLocationCoordinate2D) {
        coordinate = selectedCoordinate
        
        /*if let pinAnnotationView = self.pinAnnotationView {
            if let annotation = pinAnnotationView.annotation {
                map.removeAnnotation(annotation)
            }
        }*/

        let region = MKCoordinateRegion(center: selectedCoordinate, latitudinalMeters: 700, longitudinalMeters: 700)
        mapView.setRegion(region, animated: true)
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isMultipleTouchEnabled = false
        mapView.isScrollEnabled = false
        
        /*pointAnnotation = CustomAnnotation()
        pointAnnotation.pinCustomImageName = "GeneralMarker"
        pointAnnotation.coordinate = selectedCoordinate
        pointAnnotation.title = "Localização Selecionada"
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        map.addAnnotation(pinAnnotationView!.annotation!)*/
        
        let artwork = Artwork(
            title: local.name,
         locationName: local.address,
         coordinate: CLLocationCoordinate2D(latitude: local.latitude, longitude: local.longitude),
         localRating: local.avgRating,
         local: local
        )
         
        mapView.addAnnotation(artwork)
        mapView.register(ArtworkView.self,
        forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        reviewsTableView.delegate=self
        reviewsTableView.dataSource=self
        reviewsTableView.tableFooterView = UIView()
        
    }
    
    @IBAction func buttonMapClicked(_ sender: Any) {
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

        self.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: local.address]
      let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
      let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = local.name
      return mapItem
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        
        let review = reviews[indexPath.row]
        
        cell.labelReview.text = review?.text
        cell.labelReview.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        if section == 0 {
            return "Reviews"
        }
        
        return ""
    }
    
    
}

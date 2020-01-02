//
//  MapAnnotationModalViewController.swift
//  localhost
//
//  Created by Ricardo Filipe Ribeiro Ferreira on 02/01/2020.
//  Copyright © 2020 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import Cosmos
import SDWebImage

class MapAnnotationModalViewController: UIViewController, MKMapViewDelegate {
    var local: Local!
    var coordinate: CLLocationCoordinate2D!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dragDownButton: UIButton!
    @IBOutlet weak var imageViewLocal: UIImageView!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var gMapsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = local.name
        self.imageViewLocal.contentMode = .scaleAspectFill
        self.imageViewLocal.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "No image available"))
        
        var typesStr: String = ""
        if (local.types.count > 0){
            for type in local.types {
                typesStr += type + " "
            }
        }
        self.typesLabel.text = typesStr
        self.addressLabel.text = local.address
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: CLLocationDegrees(local.latitude))!,
        longitude: CLLocationDegrees(exactly: CLLocationDegrees(local.longitude))!)
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = false
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = true
        mapView.isUserInteractionEnabled = false
        
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: local.address]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = local.name
        return mapItem
    }
    
    // MARK: Actions
    @IBAction func buttonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gMapsButtonTouched(_ sender: Any) {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        self.mapItem().openInMaps(launchOptions: launchOptions)
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
        
        //reviewsTableView.delegate=self
        //reviewsTableView.dataSource=self
        //reviewsTableView.tableFooterView = UIView()
        
    }
        
}

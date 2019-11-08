//
//  MapViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch: class {
    func zoomLocation(_ placemark:MKPlacemark)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate{

    @IBOutlet weak var map: MKMapView!
    
    var resultSearchController: UISearchController!

    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D?
    
    var lastLocationObj: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        map.showsUserLocation = true
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //Sets the location of the search bar to the navigation bar (on the top of the screen)
        let searchBar = resultSearchController!.searchBar
        //navigationItem.searchController = resultSearchController
        self.navigationItem.titleView = searchBar
        searchBar.tintColor = UIColor(named: "AppGreenPrimary")
        //------------------------------------------------------------
        
        //This code is used to render the table that will show the locations results when searched
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        resultSearchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self
        //-------------------------------------------------------------------------
        
        map.userTrackingMode = .follow
        map.showsUserLocation = true
        map.showsScale = true
        map.showsCompass = true
        
        
        //Adds the button for current location to the map
        let buttonCurrentLocation = MKUserTrackingButton(mapView: map)
        buttonCurrentLocation.frame = CGRect(origin: CGPoint(x:view.frame.maxX - (view.frame.maxX * 0.15), y: view.frame.maxY -  (view.frame.maxY * 0.30) ), size: CGSize(width: 35, height: 35))
        map.addSubview(buttonCurrentLocation)
        //----------------------------------------------
        
        //Since we wanted the searchbar on the navbar and we added it programmaticaly, we need to also add the filter button programmaticaly and place it to the right
        let buttonFilter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(segueFilters))
        self.navigationItem.rightBarButtonItem  = buttonFilter
        //-----------------------------------------------------------------
    }
    
    @objc func segueFilters(){
        //Used to perform the segue for the screen with the filters when filters button is pressed
        performSegue(withIdentifier: "mapFiltersButton", sender: nil)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let region=MKCoordinateRegion(center: (view.annotation?.coordinate)!, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //if status == CLAuthorizationStatus.authorizedWhenInUse{
            locationManager.startUpdatingLocation()
        //}
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocationObj = locations.last
    }
    
    func clearAnnotations(){
        self.map.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.map.removeAnnotation($0)
            }
        }
    }
    
        //TODO displays pins on the map
    
    
        //MARK: - Custom Annotation
    /*private func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }else{
            let reuseIdentifier = "pin"
            var annotationView = map.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            let customPointAnnotation = annotation as! CustomAnnotation
            annotationView?.image = UIImage(named: customPointAnnotation.pinCustomImageName)
            
            return annotationView
        }
        
    }*/
    
    
    
    
    /*func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        
        let annotation = view.annotation as! CustomAnnotation
        
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }else {
            
        }
        let views = Bundle.main.loadNibNamed("ListingMapDetailView", owner: nil, options: nil)
        let calloutView = views?[0] as! ListingMapDetailViewController
        calloutView.labelName.text = annotation.listing.curricularUnit["name"] as! String
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }*/
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        if annotationView == nil {
            /*annotationView = ListingMapAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            (annotationView as! ListingMapAnnotationView).mapListingDetailDelegate = self*/
        }
        else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }

}
extension MapViewController: HandleMapSearch {

    //When a searched location is clicked the map will zomm on it
    func zoomLocation(_ placemark: MKPlacemark){
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        map.setRegion(region, animated: true)
    
    }

}

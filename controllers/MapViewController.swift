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
    
    var locals = [Local]()
    
    var resultSearchController: UISearchController!
    
    
    //Custom map pins
    var pointAnnotation:CustomAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    //Location
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D?
    
    var lastLocationObj: CLLocation?
    
    var localToSend:Local!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locals = Items.sharedInstance.locals
        
        map.delegate = self
        map.showsUserLocation = true
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
        //This code is used to render the table that will show the locations results when searched
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        resultSearchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self
        //-------------------------------------------------------------------------
        
        //Sets the location of the search bar to the navigation bar (on the top of the screen)
        let searchBar = resultSearchController!.searchBar
        //navigationItem.searchController = resultSearchController
        self.navigationItem.titleView = searchBar
        searchBar.tintColor = UIColor(named: "AppGreenPrimary")
        searchBar.showsCancelButton = false
        //------------------------------------------------------------
        
        map.userTrackingMode = .follow
        map.showsUserLocation = true
        map.showsScale = true
        map.showsCompass = true
        map.showsPointsOfInterest = false
        
        
        //Adds the button for current location to the map
        let buttonCurrentLocation = MKUserTrackingButton(mapView: map)
        buttonCurrentLocation.frame = CGRect(origin: CGPoint(x:view.frame.maxX - (view.frame.maxX * 0.15), y: view.frame.maxY -  (view.frame.maxY * 0.30) ), size: CGSize(width: 35, height: 35))
        map.addSubview(buttonCurrentLocation)
        //----------------------------------------------
        
        //Since we wanted the searchbar on the navbar and we added it programmaticaly, we need to also add the filter button programmaticaly and place it to the right
        let buttonFilter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(segueFilters))
        self.navigationItem.rightBarButtonItem  = buttonFilter
        //-----------------------------------------------------------------
        
        
        self.drawLocalPins()
        
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
        
        //getLocals()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    private func getLocals(){
        /*NetworkHandler.getLocals() {
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    
                    for local in locals!{
                        self.locals.append(local)
                    }
                    self.drawLocalPins()
                }
            }
        }*/
    }
    
    private func drawLocalPins(){
        
        for local in locals{
            
            let latitude = local.latitude
            let longitude = local.longitude
            
            
            /*pointAnnotation = CustomAnnotation()
            pointAnnotation.pinCustomImageName = "MapMarker"
            pointAnnotation.local = local
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude ,
                                                                longitude: longitude)
            pointAnnotation.title = local.name as! String
            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")*/
            //map.addAnnotation(pinAnnotationView.annotation!)
            
            
            
            let artwork = Artwork(
                title: local.name,
             locationName: local.address,
             coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
             localRating: local.avgRating,
             local: local
            )
             
             map.addAnnotation(artwork)
            
            map.register(ArtworkView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            
            
            
            
        }
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
      /*let location = view.annotation as! Artwork
      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

      location.mapItem().openInMaps(launchOptions: launchOptions)*/
        let artwork = view.annotation as! Artwork
        localToSend = artwork.local
        
        performSegue(withIdentifier: "segueMapLocalDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let smld=segue.destination as? LocalDetailedViewController {
            smld.local = self.localToSend
        }
    }
    
    
    //MARK: - Custom Annotation
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    
    
}
extension MapViewController: HandleMapSearch {
    
    //When a searched location is clicked the map will zomm on it
    func zoomLocation(_ placemark: MKPlacemark){
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        map.setRegion(region, animated: true)
        
    }
    
}

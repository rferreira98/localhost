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
import MaterialComponents.MaterialBottomSheet

protocol HandleMapSearch: class {
    func zoomLocation(_ placemark:MKPlacemark)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate{
    
    @IBOutlet weak var map: MKMapView!
    
    var annotationLabel: UILabel!
    var locals = [Local]()
    var firstLaunch = true
    
    var resultSearchController: UISearchController!
    
    
    //Custom map pins
    var pointAnnotation:CustomAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    //Location
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D?
    
    var lastLocationObj: CLLocation?
    
    var localToSend:Local!
    var regionToGo:MKCoordinateRegion!
    
    var goingForwards:Bool = false
    
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
        self.regionToGo = map.region
        
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
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        //------------------------------------------------------------
        
        map.userTrackingMode = .follow
        map.showsUserLocation = true
        map.showsScale = true
        map.showsCompass = true
        map.showsPointsOfInterest = true
        if #available(iOS 13.0, *) {
            map.pointOfInterestFilter = .some(MKPointOfInterestFilter(excluding: [MKPointOfInterestCategory.restaurant, MKPointOfInterestCategory.cafe, MKPointOfInterestCategory.nightlife]))
        }
        
        //Adds the button for current location to the map
        let buttonCurrentLocation = MKUserTrackingButton(mapView: map)
        buttonCurrentLocation.frame = CGRect(origin: CGPoint(x:view.frame.maxX - (view.frame.maxX * 0.15), y: view.frame.maxY -  (view.frame.maxY * 0.30) ), size: CGSize(width: 35, height: 35))
        map.addSubview(buttonCurrentLocation)
        
        
        //----------------------------------------------
        
        //Since we wanted the searchbar on the navbar and we added it programmaticaly, we need to also add the filter button programmaticaly and place it to the right
        
        if #available(iOS 13.0, *) {
            let buttonFilter = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(segueFilters))
            self.navigationItem.rightBarButtonItem  = buttonFilter
        } else {
            // Fallback on earlier versions
            let buttonFilter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(segueFilters))
            self.navigationItem.rightBarButtonItem  = buttonFilter
        }

        //-----------------------------------------------------------------
        
        
        self.drawLocalPins()
    }
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        if !firstLaunch {
            if mode == .follow{
                getCurrentLocals()
            }
        }else {
            firstLaunch = false
        }
        
        
    }
    
    @objc func segueFilters(){
        //Used to perform the segue for the screen with the filters when filters button is pressed
        goingForwards = true
        performSegue(withIdentifier: "mapFiltersButton", sender: self)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Map", comment: ""), style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        
    }
    
    @objc func getCurrentLocals (){
        
        NetworkHandler.getLocals(latitude: Double((locationManager.location?.coordinate.latitude)!), longitude: Double((locationManager.location?.coordinate.longitude)!)) {
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    
                    Items.sharedInstance.locals = [Local]()
                    
                    if Items.sharedInstance.locals.count == 0{
                        for local in locals!{
                            Items.sharedInstance.locals.append(local)
                        }
                    }
                    self.locals = Items.sharedInstance.locals
                    self.drawLocalPins()
                    
                }
            }
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: span)
        var isSameRegion:Bool = false
        
        if(self.regionToGo.center.latitude != region.center.latitude ||
            self.regionToGo.center.longitude != region.center.longitude){mapView.setRegion(region, animated: true)
            self.regionToGo = region
        }else{
            isSameRegion = true
        }
        
/*
        if((view.annotation?.isKind(of: Artwork.self))!){
            mapView.deselectAnnotation(view.annotation, animated: false)
            if(isSameRegion == true){
                //print("not async")
                let artwork = view.annotation as! Artwork
                self.localToSend = artwork.local
                //self.performSegue(withIdentifier: "mapAnnotationView", sender: nil)
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750), execute: {
                    //print("async")
                    // Put your code which should be executed with a delay here
                    let artwork = view.annotation as! Artwork
                    self.localToSend = artwork.local
                    //self.performSegue(withIdentifier: "mapAnnotationView", sender: nil)
                })
            }
        }*/
        
    }
    
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> Void ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
        if goingForwards == true {
            goingForwards = false
            getCoordinateFrom(address: Items.sharedInstance.locals[0].city, completion: {coordinates, error in
                let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                let region = MKCoordinateRegion(center: coordinates!, span: span)
                self.map.setRegion(region, animated: true)
                self.locals = Items.sharedInstance.locals
                self.drawLocalPins()
            })
        }
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
        
        if !map.annotations.isEmpty{
            map.removeAnnotations(map.annotations)
        }
        
        for local in locals{
            
            let latitude = local.latitude
            let longitude = local.longitude
            
            
            /*pointAnnotation = CustomAnnotation()
            pointAnnotation.pinCustomImageName = "NewMarker"
            pointAnnotation.local = local
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude ,
                                                                longitude: longitude)
            pointAnnotation.title = local.name as! String
            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
            //map.addAnnotation(pinAnnotationView.annotation!)*/
            
            
            
            annotationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            annotationLabel.text = local.name
            annotationLabel.textColor = UIColor(named: "AppGreenPrimary")
            annotationLabel.numberOfLines = 3
            annotationLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            annotationLabel.textAlignment = .center
            annotationLabel.preferredMaxLayoutWidth = 100
            //self.addSubview(label)
            annotationLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            
            
            let artwork = Artwork(
                title: local.name,
                locationName: local.address,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                localRating: local.avgRating,
                local: local,
                titleView: annotationLabel
            )
             
            map.addAnnotation(artwork)
            map.register(ArtworkView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            map.register(UserClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
          
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
        
        /*if User.hasUserLoggedIn(){
            let artwork = view.annotation as! Artwork
            localToSend = artwork.local
            //performSegue(withIdentifier: "segueMapLocalDetail", sender: nil)
        }else {
            let alert = UIAlertController(title: NSLocalizedString("Not Logged In", comment: ""), message: NSLocalizedString("To perform more actions you need to be logged in", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: {
                action in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController")
                self.present(loginViewController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Register", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let registerViewController = storyBoard.instantiateViewController(withIdentifier: "registerViewController")
                self.present(registerViewController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
            
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }*/
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let smld=segue.destination as? LocalDetailedViewController {
            smld.local = self.localToSend
        }/*else if let smld=segue.destination as? ModalDetailPageViewController {
            smld.local = self.localToSend
        }*/
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
        self.resultSearchController.searchBar.text = Items.sharedInstance.locals[0].city.capitalizingFirstLetter()
        self.locals = Items.sharedInstance.locals
        self.drawLocalPins()
        
        let span = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        map.setRegion(region, animated: true)
    }
    
}


class UserClusterAnnotationView: MKAnnotationView {
    static let preferredClusteringIdentifier = Bundle.main.bundleIdentifier! + ".UserClusterAnnotationView"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //clusteringIdentifier = String(describing: annotation.self)
        collisionMode = .circle
        updateImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        didSet { updateImage() }
        willSet {
            clusteringIdentifier = ArtworkView.preferredClusteringIdentifier
            
        }
    }

    private func updateImage() {
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            self.image = image(count: clusterAnnotation.memberAnnotations.count)
        } else {
            self.image = image(count: 1)
        }
    }

    func image(count: Int) -> UIImage {
        let bounds = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))

        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
            // Fill full circle with tricycle
            let color = UIColor(named: "AppGreenPrimary")
            color?.setFill()
            UIBezierPath(ovalIn: bounds).fill()

            // Fill inner circle with white color
            UIColor.white.setFill()
            UIBezierPath(ovalIn: bounds.insetBy(dx: 8, dy: 8)).fill()

            // Finally draw count text vertically and horizontally centered
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.boldSystemFont(ofSize: 20)
            ]

            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let origin = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
            let rect = CGRect(origin: origin, size: size)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
}












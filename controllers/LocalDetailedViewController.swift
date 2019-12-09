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
import SDWebImage

class LocalDetailedViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var reviews = [Review?]()
    
    var favorite = 1
    
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
    @IBOutlet weak var btnFavorite: UIImageView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = false
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = true
        mapView.isUserInteractionEnabled = false
        
        //reviews = local.reviews
        //print(local.reviews.count)
        //print(reviews.count)
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
        
        if User.hasUserLoggedIn(){
            self.btnFavorite.isHidden = false
        } else {
            self.btnFavorite.isHidden = true
        }
        
        if (favorite == 1){
            if let myImage = UIImage(named: "Favorite_full") {
                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                self.btnFavorite.image = tintableImage
                self.btnFavorite.tintColor = UIColor.red
            }
        } else {
            self.btnFavorite.image = UIImage(named: "Favorite_empty")
        }
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
        
        cell.isUserInteractionEnabled = false
        cell.labelReview.text = review?.text
        cell.labelReview.numberOfLines = 0
        cell.labelReviewUser.text = review?.user.name
        cell.imageViewUserReviewer.contentMode = .scaleAspectFill
        if review?.user.image_url != nil {
            cell.imageViewUserReviewer.sd_setImage(with: URL(string: (review?.user.image_url)!), placeholderImage: UIImage(named: "NoAvatar"))
        }
        else{
            cell.imageViewUserReviewer.image = UIImage(named: "NoAvatar")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        if section == 0 {
            return "Reviews"
        }
        
        return ""
    }
    
    
    @IBAction func onClickFavoriteImageView(_ sender: UITapGestureRecognizer) {
        if self.btnFavorite.image == UIImage(named: "Favorite_empty") {
             let alert = UIAlertController(title: "Deseja adicionar \(local.name) aos favoritos?", message: "O \(local.name) vai ser adicionado a sua lista de favoritos para consultar mais tarde", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { action in
                if let myImage = UIImage(named: "Favorite_full") {
                    let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                    self.btnFavorite.image = tintableImage
                    self.btnFavorite.tintColor = UIColor.red
                }
            }))
            alert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Deseja remover \(local.name) dos favoritos?", message: "O \(local.name) vai ser removido da sua lista de favoritos, esta operação é definitiva", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { action in
                if let myImage = UIImage(named: "Favorite_empty") {
                    let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                    self.btnFavorite.image = tintableImage
                    self.btnFavorite.tintColor = UIColor.black
                }
            }))
            alert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
		

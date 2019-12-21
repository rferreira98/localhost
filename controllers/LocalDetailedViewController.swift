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
    
    var favorite = 0
    
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
    @IBOutlet var btnFavoriteBarItem: UIBarButtonItem!
    @IBOutlet weak var imageViewLocal: UIImageView!
    
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
        self.imageViewLocal.contentMode = .scaleAspectFill
        self.imageViewLocal.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "NoAvatar"))
        
        getReviews(local.id)
        
        if !User.hasUserLoggedIn(){
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = self.btnFavoriteBarItem
            if Items.sharedInstance.favorites.isEmpty {
                self.btnFavoriteBarItem.image = UIImage(named: "Favorite_empty")
            } else {
                for favorite in Items.sharedInstance.favorites {
                    if(favorite.id == local.id){
                        if let myImage = UIImage(named: "Favorite_full") {
                            let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                            self.btnFavoriteBarItem.image = tintableImage
                            self.btnFavoriteBarItem.tintColor = UIColor.red
                        }
                        break
                    }else{
                        self.btnFavoriteBarItem.image = UIImage(named: "Favorite_empty")
                    }
                }
            }
        }
    }
    
    public func getReviews(_ local_id:Int) {
        NetworkHandler.getReviews(local_id: self.local.id, completion: { (reviews, error) in
            OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.reviews = reviews!
                    print(reviews!)
                    self.reviewsTableView.reloadData()
                }
            }
        })
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
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        
        let review = reviews[indexPath.row]
        
        cell.isUserInteractionEnabled = false
        cell.ratingReview.rating = review?.rating ?? 0
        cell.labelReview.text = review?.text
        cell.labelReview.numberOfLines = 0
        cell.labelReviewUser.text = review?.user_name
        cell.imageViewUserReviewer.contentMode = .scaleAspectFill
        if review?.user_image != nil {
            cell.imageViewUserReviewer.sd_setImage(with: URL(string: (review?.user_image)!), placeholderImage: UIImage(named: "NoAvatar"))
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
    
    
    @IBAction func onClickFavoriteButtonBarItem(_ sender: Any) {
        if self.btnFavoriteBarItem.image == UIImage(named: "Favorite_empty") {
            let alert = UIAlertController(title: "Deseja adicionar \(local.name) aos favoritos?", message: "O \(local.name) vai ser adicionado a sua lista de favoritos para consultar mais tarde", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { action in
                NetworkHandler.storeFavorite(local_id: self.local.id, completion: { (success, error) in
                    OperationQueue.main.addOperation {
                        if error != nil {
                            let alert = Utils.triggerAlert(title: "Erro", error: error)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            if let myImage = UIImage(named: "Favorite_full") {
                                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                                self.btnFavoriteBarItem.image = tintableImage
                                self.btnFavoriteBarItem.tintColor = UIColor.red
                            }
                        }
                    }
                }
                )}))
            alert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Deseja remover \(local.name) dos favoritos?", message: "O \(local.name) vai ser removido da sua lista de favoritos, esta operação é definitiva", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { action in
                NetworkHandler.deleteFavorite(local_id: self.local.id, completion: { (success, error) in
                    OperationQueue.main.addOperation {
                        if error != nil {
                            let alert = Utils.triggerAlert(title: "Erro", error: error)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            for (index, favorite) in Items.sharedInstance.favorites.enumerated() {
                                if(favorite.id == self.local.id){
                                    Items.sharedInstance.favorites.remove(at: index)
                                    break
                                }
                            }
                            if let myImage = UIImage(named: "Favorite_empty") {
                                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                                self.btnFavoriteBarItem.image = tintableImage
                                self.btnFavoriteBarItem.tintColor = UIColor(named: "AppGreenDark")
                            }
                        }
                    }
                }
                )}))
            alert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
}


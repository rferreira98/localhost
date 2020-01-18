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
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var labelQtReviews: UILabel!
    @IBOutlet var btnFavoriteBarItem: UIBarButtonItem!
    @IBOutlet weak var imageViewLocal: UIImageView!
    @IBOutlet weak var btnAskOrGoToQuestion: UIButton!
    @IBOutlet weak var buttonPlaceReviews: UIButton!
    
    var questionToSend:Question?
    
    var goingForwards:Bool = false
    
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
            typesStr += type + " "
        }
        self.labelLocalType.text = typesStr
        self.labelLocalAddress.numberOfLines = 0
        self.labelLocalAddress.text = local.address
        self.ratingView.isUserInteractionEnabled = false
        self.ratingView.rating = self.local.avgRating
        self.labelQtReviews.text = String(local.qtReviews)
        self.imageViewLocal.contentMode = .scaleAspectFill
        self.imageViewLocal.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "NoPhotoRestaurant"))
        
        getReviews(local.id)
        
        hasQuestion(local.id)
        
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
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(LocalDetailedViewController.handleModalDismissed),
        name: NSNotification.Name(rawValue: "modalIsDimissed"),
        object: nil) 
    }
    
    @objc func handleModalDismissed() {
      // Do something
        hasQuestion(local.id)
    }
    
    public func hasQuestion(_ local_id:Int){
        NetworkHandler.hasQuestion(local_id: local_id, completion: { (hasQuestion, error) in
            OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if hasQuestion != nil && hasQuestion?.id != -1{
                        self.questionToSend = hasQuestion
                        UIView.transition(with: self.btnAskOrGoToQuestion.titleLabel!,
                             duration: 0.25,
                              options: .transitionCrossDissolve,
                           animations: { [weak self] in
                            self?.btnAskOrGoToQuestion.titleLabel!.text = "Go to Chat"
                        }, completion: nil)
                    } else{
                        UIView.transition(with: self.btnAskOrGoToQuestion.titleLabel!,
                             duration: 0.25,
                              options: .transitionCrossDissolve,
                           animations: { [weak self] in
                            self?.btnAskOrGoToQuestion.titleLabel!.text = "Ask advice"
                        }, completion: nil)
                    }
                    //let height = self.reviewsTableView.content
                    //self.view.intrinsicContentSize.height
                    //self.scrollview.contentSize.height = height + 758
                    //print(height)
                }
            }

        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if goingForwards {
           //self.goingForwards = false
           hasQuestion(self.local.id)
       }
    }
    
    public func getReviews(_ local_id:Int) {
        NetworkHandler.getReviews(local_id: self.local.id, completion: { (reviews, error) in
            OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.reviews = reviews!
                    //print(reviews!)
                    //let height = self.reviewsTableView.content
                    //self.view.intrinsicContentSize.height
                    //self.scrollview.contentSize.height = height + 758
                    //print(height)
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
        
        let region = MKCoordinateRegion(center: selectedCoordinate, latitudinalMeters: 400, longitudinalMeters: 400)
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
        
    }
    
    @IBAction func buttonPlaceReviewsClicked(_ sender: Any) {
        performSegue(withIdentifier: "segueReviewsDetail", sender: nil)
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
            return NSLocalizedString("Reviews", comment: "")
        }
        
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let smld=segue.destination as? AskAdviceViewController {
            smld.local = self.local
        } else if let smld=segue.destination as? ChatViewController {
            smld.question = self.questionToSend
        }
        if let rvd = segue.destination as? ListReviewsViewController {
            rvd.reviews = self.reviews
        }
    }
    
    @IBAction func onClickAskOrGoToQuestionBtn(_ sender: Any) {
        //if text equals go to question perform chat segue
        if self.btnAskOrGoToQuestion.titleLabel?.text == "Go to Chat" {
            self.goingForwards = true
            performSegue(withIdentifier: "goToChat", sender: nil)
        } else{
            performSegue(withIdentifier: "goToAskModal", sender: nil)
        }
    }
    
    
    @IBAction func onClickFavoriteButtonBarItem(_ sender: Any) {
        if self.btnFavoriteBarItem.image == UIImage(named: "Favorite_empty") {
            let alert = UIAlertController(title: NSLocalizedString("Do you wish to add", comment: "")+(local.name)+" "+NSLocalizedString("to favorites", comment: ""), message: NSLocalizedString("O", comment: "") + (local.name) + NSLocalizedString("will be added to your favorites list for you to check back later", comment: ""), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { action in
                NetworkHandler.storeFavorite(local_id: self.local.id, completion: { (success, error) in
                    OperationQueue.main.addOperation {
                        if error != nil {
                            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
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
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Do you wish to remove", comment: "") + (local.name) + NSLocalizedString("from favorites?", comment: ""), message: NSLocalizedString("O", comment: "") + (local.name) + NSLocalizedString("will be removed from your favorites list. This operation is definitive", comment: ""), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { action in
                NetworkHandler.deleteFavorite(local_id: self.local.id, completion: { (success, error) in
                    OperationQueue.main.addOperation {
                        if error != nil {
                            let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
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
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
}


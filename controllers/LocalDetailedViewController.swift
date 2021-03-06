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

class LocalDetailedViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, LoginHasBeenMade {
    func sendBool(loginMade: Bool) {
        if loginMade {
            print("OK")
            hasQuestion(local.id, perfSegue: true)
        }
    }
    
    
    
    
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
        
        
        
        if traitCollection.userInterfaceStyle == .dark{
            buttonPlaceReviews.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            buttonMapDirections.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            btnAskOrGoToQuestion.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }else {
            buttonPlaceReviews.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            buttonMapDirections.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            btnAskOrGoToQuestion.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        }
        labelQtReviews.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToRecommendations))
        labelQtReviews.addGestureRecognizer(tap)
        
        buttonPlaceReviews.centerVertically(padding: 0, leftImageInsetDivider: 1.8)
        buttonPlaceReviews.layer.cornerRadius = 6
        //buttonPlaceReviews.layer.borderWidth = 0
        //buttonPlaceReviews.layer.borderColor = UIColor(named: "AppGreenButton")?.cgColor
        
        buttonMapDirections.centerVertically(padding: 0, leftImageInsetDivider: 1.8)
        buttonMapDirections.layer.cornerRadius = 6
        
        UserDefaults.standard.string(forKey: "AppLanguage") == NSLocalizedString("English", comment: "") ? btnAskOrGoToQuestion.centerVertically(padding: 0, leftImageInsetDivider: 1.6) : btnAskOrGoToQuestion.centerVertically(padding: 0, leftImageInsetDivider: 1.8)
        
        
        btnAskOrGoToQuestion.layer.cornerRadius = 6
        
        
        
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
        self.labelQtReviews.text = String(local.qtReviews) + " " + NSLocalizedString("Reviews", comment: "")
        self.imageViewLocal.contentMode = .scaleAspectFill
        
        if(traitCollection.userInterfaceStyle == .dark){
            if local.imageUrl == ""{
                self.imageViewLocal.contentMode = .scaleAspectFit
            }
             self.imageViewLocal.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "LocalhostPlaceGray"))
        }else{
            if local.imageUrl == ""{
                self.imageViewLocal.contentMode = .scaleAspectFit
            }
            self.imageViewLocal.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "LocalhostPlaceWhite"))
        }
        
       
        
        getReviews(local.id)
        
        hasQuestion(local.id, perfSegue: false)
        
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
        selector: #selector(handleModalDismissed),
        name: NSNotification.Name(rawValue: "modalIsDimissed"),
        object: nil) 
    }
    
    @objc func goToRecommendations(){
        performSegue(withIdentifier: "segueReviewsDetail", sender: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle == .dark{
            buttonPlaceReviews.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            buttonMapDirections.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            btnAskOrGoToQuestion.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            if local.imageUrl == nil{
                self.imageViewLocal.contentMode = .scaleAspectFit
            }
            self.imageViewLocal.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "LocalhostPlaceWhite"))
        }else{
            buttonPlaceReviews.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            buttonMapDirections.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            btnAskOrGoToQuestion.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            if local.imageUrl == nil{
                self.imageViewLocal.contentMode = .scaleAspectFit
            }
            self.imageViewLocal.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "LocalhostPlaceGray"))
        }
    }
    
    @objc func handleModalDismissed() {
      // Do something
        hasQuestion(local.id, perfSegue: false)
    }
    
    public func hasQuestion(_ local_id:Int, perfSegue:Bool){
        
        if User.hasUserLoggedIn(){
            NetworkHandler.hasQuestion(local_id: local_id, completion: { (hasQuestion, error) in
                OperationQueue.main.addOperation {
                    if error != nil {
                        let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        if hasQuestion != nil && hasQuestion?.id != -1{
                            self.questionToSend = hasQuestion
                            self.btnAskOrGoToQuestion.setTitle(NSLocalizedString("Go to Chat", comment: ""), for: UIControl.State.normal)
                            //self.btnAskOrGoToQuestion.titleLabel?.text = "Go to Chat"
                            //self.btnAskOrGoToQuestion.setNeedsDisplay()
                        } else{
                            self.btnAskOrGoToQuestion.setTitle(NSLocalizedString("Ask Advice", comment: ""), for: UIControl.State.normal)
                            //self.btnAskOrGoToQuestion.titleLabel?.text = NSLocalizedString("Ask Advice", comment: "")
                        }
                        
                        if perfSegue {
                            if self.btnAskOrGoToQuestion.titleLabel?.text == NSLocalizedString("Go to Chat", comment: ""){
                                self.goingForwards = true
                                self.performSegue(withIdentifier: "goToChat", sender: nil)
                            } else{
                                self.performSegue(withIdentifier: "goToAskModal", sender: self)
                            }
                        }
                        
                        //let height = self.reviewsTableView.content
                        //self.view.intrinsicContentSize.height
                        //self.scrollview.contentSize.height = height + 758
                        //print(height)
                    }
                }

            })
        }
        
        /*let alert = UIAlertController(title: NSLocalizedString("Not Logged In", comment: ""), message: NSLocalizedString("To perform more actions you need to be logged in", comment: ""), preferredStyle: UIAlertController.Style.alert)
        
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
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: {
        action in
             tableView.cellForRow(at: indexPath)?.isSelected = false
        }))
        
        
        // show the alert
        self.present(alert, animated: true, completion: nil)*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if goingForwards {
           //self.goingForwards = false
           hasQuestion(self.local.id, perfSegue: false)
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
            local: local,
            titleView: nil
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
        
        cell.imageViewReviewProvider.image = UIImage(named: (review!.provider.lowercased()))
        
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
        
        
        if User.hasUserLoggedIn(){
            //if text equals go to question perform chat segue
            print(self.btnAskOrGoToQuestion.titleLabel?.text)
            print(NSLocalizedString("Go to Chat", comment: ""))
            if self.btnAskOrGoToQuestion.titleLabel?.text == NSLocalizedString("Go to Chat", comment: "") {
                self.goingForwards = true
                performSegue(withIdentifier: "goToChat", sender: nil)
            } else{
                print("Tou")
                performSegue(withIdentifier: "goToAskModal", sender: nil)
            }
        }else{
            
            let alert = UIAlertController(title: NSLocalizedString("Not Logged In", comment: ""), message: NSLocalizedString("To perform this action you need to be logged in", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: {
                action in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController_1") as! LoginViewController
                loginViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: loginViewController)

                self.present(navigationController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Register", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let registerViewController = storyBoard.instantiateViewController(withIdentifier: "registerViewController_1") as! RegisterViewController
                registerViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: registerViewController)
                
                self.present(navigationController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler:nil))
            
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
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

extension UIButton {

    func centerVertically(padding: CGFloat = 0.0, leftImageInsetDivider: CGFloat) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }

        let totalHeight = imageViewSize.height + titleLabelSize.height + padding

        self.imageEdgeInsets = UIEdgeInsets(
            //top: -(totalHeight - imageViewSize.height),
            top: -24,
            //left: 0.0,
            //left: titleLabelSize.width/1.8,
            left: titleLabelSize.width/leftImageInsetDivider,
            bottom: 0.0,
            //right: -titleLabelSize.width
            right: -0.0
        )

        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )

        self.contentEdgeInsets = UIEdgeInsets(
            //top: titleLabelSize.height/1.6,
            top:34/1.6,
            left: 0.0,
            //bottom: titleLabelSize.height/2,
            bottom: 34/2,
            right: 0.0
        )
    
    }

}


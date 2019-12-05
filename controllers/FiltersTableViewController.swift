//
//  FiltersTableViewController.swift
//  localhost
//
//  Created by Ruben Lauro on 04/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class FiltersTableViewController: UITableViewController, CLLocationManagerDelegate {
    @IBOutlet weak var sliderDistance: UISlider!
    @IBOutlet weak var lblDistance: UILabel!
    
    let locationManager = CLLocationManager()
    
    var currentRadiusValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        verifyMetricUnit()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        verifyMetricUnit()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.currentRadiusValue = Int(sender.value)
        
        if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
            lblDistance.text = "\(currentRadiusValue) km"
        }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
            lblDistance.text = "\(currentRadiusValue) miles"
        }
    }
    
    @IBAction func onClickApplyFilterButtonClick(_ sender: Any) {
        //goToMainScreen()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
        //get current location
        //send the request with the radius
        
        /*
        let firstName = textFieldFirstName.text!
        let lastName = textFieldLastName.text!
        let password = textFieldPassword.text!
        let passwordConfirm = textFieldConfirmPassword.text!
        let email = textFieldEmail.text!
        let local = textFieldLocal.text!
        var image: UIImage!
        
        if textFieldFirstName.text!.isEmpty || textFieldLastName.text!.isEmpty || textFieldEmail.text!.isEmpty || textFieldPassword.text!.isEmpty || textFieldConfirmPassword.text!.isEmpty || textFieldLocal.text!.isEmpty{
            
            let alert = Utils.triggerAlert(title: "Error", error: "Alguns campos estão vazios.")
            self.present(alert, animated: true, completion: nil)
        }else{
            if !isValid(email){
                let alert = Utils.triggerAlert(title: "Erro", error: "E-mail Inválido")
                self.present(alert, animated: true, completion: nil)
            }else{
                let postRegist = NetworkHandler.PostRegister(first_name: firstName, last_name: lastName, password: password, password_confirmation: passwordConfirm, email: email, local: local)
                
                NetworkHandler.register(post: postRegist) { (success, error) in
                    OperationQueue.main.addOperation {
                        
                        if error != nil {
                            let alert = Utils.triggerAlert(title: "Erro", error: error)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            
                            //------
                            
                            let postLogin = NetworkHandler.PostLogin(password: password, email: email)
                            NetworkHandler.login(post: postLogin) { (success, error) in
                                OperationQueue.main.addOperation {
                                    
                                    if error != nil {
                                        let alert = Utils.triggerAlert(title: "Erro", error: error)
                                        self.present(alert, animated: true, completion: nil)
                                    } else {
                                        //Upload Avatar
                                        
                                        
                                        NetworkHandler.uploadAvatar(avatar: self.imageViewAvatar.image!.resized(toWidth: 200)!){ (success, error) in
                                            OperationQueue.main.addOperation {
                                                if error != nil{
                                                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                                                    self.present(alert, animated: true, completion: nil)
                                                }else{
                                                    //go to first screen
                                                    if UserDefaults.standard.bool(forKey: "biometricPrompted") {
                                                        self.goToMainScreen()
                                                    }else{
                                                        if !self.usesBiometricAuth {
                                                            self.displayActionSheet();
                                                        }else {
                                                            self.goToMainScreen()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }*/
    }
    
    func goToMainScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let placesListController = storyBoard.instantiateViewController(withIdentifier: "placesListController")
        self.dismiss(animated: true, completion: nil)
        self.present(placesListController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        getLocals(currentLocationLatitude: locValue.latitude, currentLocationLongitude: locValue.longitude, radius: currentRadiusValue)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    private func getLocals(currentLocationLatitude: Double, currentLocationLongitude: Double, radius: Int){
        NetworkHandler.getLocalsFilteredByDistance(currentLocationLatitude: currentLocationLatitude, currentLocationLongitude: currentLocationLongitude, radius: radius){
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    print(locals!)
                    /*
                    for local in locals!{
                        Items.sharedInstance.locals.append(local)
                    }
                    
                    self.goToMainScreen()
 */
                }
            }
        }
    }
    
    private func verifyMetricUnit() {
        if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
            lblDistance.text = "0 km"
        }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
            lblDistance.text = "0 miles"
        }
    }
}

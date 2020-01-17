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
import Cosmos

class FiltersTableViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var sliderDistance: UISlider!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var textFieldPickerLocal: UITextField!
    @IBOutlet var resetFiltersBtn: UIButton!
    
    var localPicker = UIPickerView()
    var selectedCity: String = ""
    var lastSelectedCity: String = ""
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var ratingView: CosmosView!
    
    var lastLocationObj: CLLocationCoordinate2D?
    var currentRadiusValue: Int = 0
    
    var selectedRating:Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
        ratingView.settings.fillMode = .half
        
        
        createPicker();
        
        textFieldPickerLocal.delegate = self
        textFieldPickerLocal.tintColor = .clear
        
        verifyMetricUnit()
        
        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        verifyMetricUnit()
        
        ratingView.didFinishTouchingCosmos = {
            rating in
            self.selectedRating = rating
            print(rating)
            if (rating > 0 && rating <= 5){
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }else{
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    fileprivate func checkCurrentRadiusValue() {
        if self.currentRadiusValue == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.currentRadiusValue = Int(sender.value)
        
        if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
            checkCurrentRadiusValue()
            lblDistance.text = "\(currentRadiusValue) km"
        }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
            checkCurrentRadiusValue()
            if currentRadiusValue == 1{
                lblDistance.text = "\(currentRadiusValue) "+NSLocalizedString("Mile", comment: "")
            }else{
                lblDistance.text = "\(currentRadiusValue) "+NSLocalizedString("Miles", comment: "")
            }
        }
    }
    
    @IBAction func onClickApplyFilterButtonClick(_ sender: Any) {
        print("locations = \(lastLocationObj!.latitude) \(lastLocationObj!.longitude)")
        if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
            //print("current miles radius: \(currentRadiusValue * 1000)")
            getLocals(currentLocationLatitude: lastLocationObj!.latitude, currentLocationLongitude: lastLocationObj!.longitude, radius: currentRadiusValue * 1000)
        }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
            var currentRadius = 0.0
            if currentRadiusValue >= 24 {
                currentRadius = 24.0 * 1609.34
            } else {
                currentRadius = Double(currentRadiusValue) * 1609.34
            }
            getLocals(currentLocationLatitude: lastLocationObj!.latitude, currentLocationLongitude: lastLocationObj!.longitude, radius: Int(currentRadius.rounded()))
        }
        
        if selectedRating != nil {
            getLocalsByRating(selectedRating!, lastLocationObj!.latitude, lastLocationObj!.longitude)
        }
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        lastLocationObj = locValue
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        lastLocationObj = locValue
    }
    
    private func getLocals(currentLocationLatitude: Double, currentLocationLongitude: Double, radius: Int){
        
        self.showSpinner(onView: self.view)
        
        NetworkHandler.getLocalsFilteredByDistance(currentLocationLatitude: currentLocationLatitude, currentLocationLongitude: currentLocationLongitude, radius: radius){
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    Items.sharedInstance.locals.removeAll()
                    for local in locals!{
                        Items.sharedInstance.locals.append(local)
                    }
                    self.removeSpinner()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func getLocalsByRating(_ rating: Double, _ latitude: Double, _ longitude: Double){
        //        searchByRating
        
        NetworkHandler.getLocalsFilteredByRating(rating: rating, latitude: latitude, longitude: longitude){
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    Items.sharedInstance.locals.removeAll()
                    for local in locals!{
                        print(local)
                        Items.sharedInstance.locals.append(local)
                    }
                    self.removeSpinner()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func getLocalsByCity(city: String){
        //        searchByCity
        self.showSpinner(onView: self.view)
        NetworkHandler.getLocalsFilteredByCity(city: city){
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    Items.sharedInstance.locals.removeAll()
                    for local in locals!{
                        print(local)
                        Items.sharedInstance.locals.append(local)
                    }
                    self.removeSpinner()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    
    @IBAction func onClickResetFiltersBtn(_ sender: Any) {
        self.currentRadiusValue = 0	
        verifyMetricUnit()
    }
    
    private func verifyMetricUnit() {
        if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            sliderDistance.value = 0
            sliderDistance.maximumValue = 40
            lblDistance.text = "0 km"
        }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            sliderDistance.value = 0
            sliderDistance.maximumValue = 25
            lblDistance.text = "0 "+NSLocalizedString("Miles", comment: "")
        }
    }
    
    //Local picker methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Cities.cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Cities.cities[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCity = Cities.cities[row]
        textFieldPickerLocal.text = selectedCity
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        lastSelectedCity = selectedCity
        
        label.textAlignment = .center
        label.text = Cities.cities[row]
        
        return label
    }
    
    func createPicker() {
        localPicker.delegate = self
        textFieldPickerLocal.inputView = localPicker
        localPicker.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector (self.dimissPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: UIBarButtonItem.Style.plain, target: self, action: #selector (self.dimissPickerReset))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textFieldPickerLocal.inputAccessoryView = toolBar
    }
    
    @objc func dimissPicker(){
        self.view.endEditing(true)
        if self.selectedCity != "" && self.selectedCity != NSLocalizedString("Choose Local", comment: ""){
            getLocalsByCity(city: self.selectedCity)
        }
    }
    
    @objc func dimissPickerReset(){
        self.view.endEditing(true)
        resetPicker()
    }
    
    func resetPicker() {
        if self.lastSelectedCity == ""
        {
            self.textFieldPickerLocal.text = NSLocalizedString("Choose Local", comment: "")
            self.selectedCity = ""
        } else {
            self.textFieldPickerLocal.text = self.lastSelectedCity
        }
    }
    
    
    
}





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

class FiltersTableViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var sliderDistance: UISlider!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var textFieldPickerLocal: UITextField!
    
    var localPicker = UIPickerView()
    var selectedCity: String = ""
    
    let locationManager = CLLocationManager()
    
    var lastLocationObj: CLLocationCoordinate2D?
    var currentRadiusValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }

        createPicker();
        
        textFieldPickerLocal.delegate = self
        
        verifyMetricUnit()
        
        //Dismiss keyboard with a tap.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
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
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.currentRadiusValue = Int(sender.value)
        
        if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
            lblDistance.text = "\(currentRadiusValue) km"
        }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
            if currentRadiusValue == 1{
                lblDistance.text = "\(currentRadiusValue) mile"
            }else{
                lblDistance.text = "\(currentRadiusValue) miles"
            }
        }
    }
    
    @IBAction func onClickApplyFilterButtonClick(_ sender: Any) {
        print("locations = \(lastLocationObj!.latitude) \(lastLocationObj!.longitude)")
        
        if currentRadiusValue != 1 {
            if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
                //print("current miles radius: \(currentRadiusValue * 1000)")
                getLocals(currentLocationLatitude: lastLocationObj!.latitude, currentLocationLongitude: lastLocationObj!.longitude, radius: Double(currentRadiusValue) * 1000)
            }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
                var currentRadius = 0.0
                if currentRadiusValue >= 24 {
                    currentRadius = 24.0 * 1609.34
                } else {
                    currentRadius = Double(currentRadiusValue) * 1609.34
                }
                getLocals(currentLocationLatitude: lastLocationObj!.latitude, currentLocationLongitude: lastLocationObj!.longitude, radius: currentRadius)
            }
         } else if selectedCity != "" {
             
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
    
    private func getLocals(currentLocationLatitude: Double, currentLocationLongitude: Double, radius: Double){
        
        self.showSpinner(onView: self.view)
        
        NetworkHandler.getLocalsFilteredByDistance(currentLocationLatitude: currentLocationLatitude, currentLocationLongitude: currentLocationLongitude, radius: radius){
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
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
    
    private func getLocalsByCity(city: String){
        
        //FALTA FAZER CHAMADA A API ETC
    }
    
    
    private func verifyMetricUnit() {
        if UserDefaults.standard.integer(forKey: "metricUnit") == 0 {
            sliderDistance.value = 1
            sliderDistance.maximumValue = 40
            lblDistance.text = "1 km"
        }else if UserDefaults.standard.integer(forKey: "metricUnit") == 1 {
            sliderDistance.value = 1
            sliderDistance.maximumValue = 25
            lblDistance.text = "1 mile"
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

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector (self.dimissPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector (self.dimissPickerReset))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textFieldPickerLocal.inputAccessoryView = toolBar
      

    }
    @objc func dimissPicker(){
        self.view.endEditing(true)
    }
    @objc func dimissPickerReset(){
        self.view.endEditing(true)
        resetPicker()
    }
    func resetPicker() {
        self.textFieldPickerLocal.text = ""
        self.selectedCity = ""
        
    }
}





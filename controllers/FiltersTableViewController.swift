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
    @IBOutlet var resetFiltersBtn: UIButton!
    
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
        
        
        verifyMetricUnit()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        verifyMetricUnit()
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
                lblDistance.text = "\(currentRadiusValue) mile"
            }else{
                lblDistance.text = "\(currentRadiusValue) miles"
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
            lblDistance.text = "0 miles"
        }
    }
}





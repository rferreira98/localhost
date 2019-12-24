//
//  InitialViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/12/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import MapKit

class InitialViewController: UIViewController, CLLocationManagerDelegate{
    var locals = [Local]()
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways{
            locationManager.startUpdatingLocation()
        }else {
            if(UserDefaults.standard.bool(forKey: "hasBeenLaunched")){
                let alertController = UIAlertController(title: "Erro", message: "Por favor autorize a utilização da localização para o correto funcionamento da aplicação nas Definições.", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Definições", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: "App-Prefs:root=Privacy&path=LOCATION_SERVICES")  else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                     }
                }
                let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getLocals()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    
    private func getLocals(){
        self.showSpinner(onView: self.view)
        //todo wrong location is not available yet
        locationManager.stopUpdatingLocation()
        NetworkHandler.getLocals(latitude: Double((locationManager.location?.coordinate.latitude)!), longitude: Double((locationManager.location?.coordinate.longitude)!)) {
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                    self.present(alert, animated: true, completion: nil)
                    self.removeSpinner()
                    self.goToMainScreen()
                }
                else{
                    
                    for local in locals!{
                        Items.sharedInstance.locals.append(local)
                    }
                    
                    self.goToMainScreen()
                    
                }
            }
        }
    }
    
    func goToMainScreen() {
        //go to first screen
        UserDefaults.standard.set(true, forKey: "hasBeenLaunched")
        UserDefaults.standard.synchronize()
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let first = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        //let mvc = MapViewController()
        //mvc.locals = self.locals
        
        first.modalPresentationStyle = .fullScreen
        //self.dismiss(animated: true, completion: nil)
        self.present(first, animated: true, completion: nil)
    }
    
    
    
}



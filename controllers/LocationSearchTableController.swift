//
//  LocationSearchTableController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//


import UIKit
import MapKit


class LocationSearchTableController: UITableViewController {

    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [String] = []
    var mapView: MKMapView?
}

extension LocationSearchTableController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        /*
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }*/
        
        var citiesArr: [String] = []
        citiesArr = Cities.cities
        citiesArr.remove(at: 0)
        self.matchingItems = citiesArr.filter { (item: String) -> Bool in
            return item.lowercased().contains(searchController.searchBar.text!.lowercased())
        }
        
        self.tableView.reloadData()
    }

    
    
}

extension LocationSearchTableController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell")!
        let selectedItem = matchingItems[indexPath.row]
        cell.textLabel?.text = selectedItem
        //cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        getCoordinateFrom(address: matchingItems[indexPath.row]) {coordinates, error in
            self.getLocalsByCity(city: self.matchingItems[indexPath.row]){completion,error in
                if error != nil{
                    let alert = Utils.triggerAlert(title: NSLocalizedString("Error", comment: ""), error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let coords = CLLocationCoordinate2DMake(coordinates!.latitude, coordinates!.longitude)
                    let place = MKPlacemark(coordinate: coords)
                    self.handleMapSearchDelegate?.zoomLocation(place)
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> Void ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    
    func getLocalsByCity(city: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void){
        //        searchByCity
        NetworkHandler.getLocalsFilteredByCity(city: city){
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    completion(false, error)
                }
                else{
                    Items.sharedInstance.locals.removeAll()
                    for local in locals!{
                        print(local)
                        Items.sharedInstance.locals.append(local)
                    }
                    completion(true, nil)
                }
            }
        }
    }
    
}




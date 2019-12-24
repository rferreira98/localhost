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
    var matchingItems: [Local] = []
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
        
        self.matchingItems = Items.sharedInstance.locals.filter { (local: Local) -> Bool in
            return local.name.lowercased().contains(searchController.searchBar.text!.lowercased())
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
        cell.textLabel?.text = selectedItem.name
        //cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
}

extension LocationSearchTableController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        let coords = CLLocationCoordinate2DMake(selectedItem.latitude, selectedItem.longitude)
        let place = MKPlacemark(coordinate: coords)
        handleMapSearchDelegate?.zoomLocation(place)
        dismiss(animated: true, completion: nil)
    }
}



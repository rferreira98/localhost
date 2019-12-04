//
//  PlacesListViewController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit
import SDWebImage

class PlacesListViewController: UITableViewController {
    
    var resultSearchController: UISearchController!
    var locals = [Local]()
    var searchBar: UISearchBar!
    
    var tapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        searchBar = resultSearchController!.searchBar
        //navigationItem.searchController = resultSearchController
        self.navigationItem.titleView = searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchBar.tintColor = UIColor(named: "AppGreenPrimary")
        searchBar.showsCancelButton = false
        
        
        let buttonFilter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(segueFilters))
        self.navigationItem.rightBarButtonItem  = buttonFilter
        
        
        //pull to refresh
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Puxe para atualizar")
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        
        //----------------
        getLocals()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getLocals()
    }
        
    @objc func segueFilters(){
        performSegue(withIdentifier: "listFiltersButton", sender: nil)
    }
    
    private func getLocals(){
        NetworkHandler.getLocals() {
            (locals, error) in OperationQueue.main.addOperation {
                if error != nil {
                    let alert = Utils.triggerAlert(title: "Erro", error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    
                    for local in locals!{
                        self.locals.append(local)
                    }
                    
                    //DispatchQueue.main.async { self.tableView.reloadData() }
                    self.tableView.reloadData()
                    print("GOT LOCALS")
                    
                    //self.drawLocalPins()
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        self.searchBar.endEditing(true)
        view.endEditing(true)
    }
    
    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }*/
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(locals.count)
        return locals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localCell", for: indexPath) as! LocalTableViewCell

        let local = locals[indexPath.row]
        print(local)
        cell.localName.text = local.name
        var typesStr: String = ""
        for type in local.types {
            typesStr += type+" "
        }
        cell.localType.text = typesStr
        cell.localAddress.text = local.address
        cell.ratingView.isHidden = false
        cell.ratingView.isUserInteractionEnabled = false
        cell.ratingView.rating = local.avgRating
        cell.localPhoto.contentMode = .scaleAspectFill
        cell.localPhoto.sd_setImage(with: URL(string: local.imageUrl), placeholderImage: UIImage(named: "NoAvatar"))
        //cell.localPhoto.image = cropToBounds(image: cell.localPhoto.image!, width: 80, height: 80)
        
        
        return cell
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PlacesListViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture!)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapGesture!)
    }
    
    @objc func viewTapped(gestureRecognizer: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
}





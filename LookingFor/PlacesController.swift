//
//  PlacesController.swift
//  LookingFor
//
//  Created by Archie Tiu on 19/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlacesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellId = "cellId"
    var nearbyController: NearbyController?
    var likelyPlaces = [GMSPlace]()
    var location: Location?
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = BackgroundColorProvider().colors["orange"]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlacesCell.self, forCellReuseIdentifier: cellId)
    }
    
    func setupLayout() {
        view.addSubview(tableView)
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func showMap(selectedPlace: GMSPlace) {
        nearbyController?.mapView.clear()
        // Add a marker to the map.
        if nearbyController?.selectedPlace != nil {
            let marker = GMSMarker(position: (nearbyController?.selectedPlace?.coordinate)!)
            marker.title = selectedPlace.name
            marker.snippet = selectedPlace.formattedAddress
            marker.map = nearbyController?.mapView
        }
        nearbyController?.selectedPlace = selectedPlace
        nearbyController?.listLikelyPlaces()
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(likelyPlaces.count)
        return likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlacesCell
        let collectionItem = likelyPlaces[indexPath.row]
        
        cell.textLabel?.text = collectionItem.name
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.tableView.frame.size.height/5
//    }
    
    // Make table rows display at proper height if there are less than 5 items.
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == tableView.numberOfSections - 1) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = likelyPlaces[indexPath.row]
        showMap(selectedPlace: selectedPlace)
    }
}


























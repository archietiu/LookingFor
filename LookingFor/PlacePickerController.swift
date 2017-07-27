//
//  PlacePickerController.swift
//  LookingFor
//
//  Created by Archie Tiu on 20/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class PlacePickerController: GMSPlacePickerViewController {
    
    var createPartyController: CreatePartyController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        guard let address = place.formattedAddress, let attributions = place.attributions else { return }
        
        print("Place name \(place.name)")
        print("Place address \(address)")
        print("Place attributions \(attributions)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}

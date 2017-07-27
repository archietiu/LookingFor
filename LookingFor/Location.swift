//
//  Location.swift
//  LookingFor
//
//  Created by Archie Tiu on 19/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

struct Coordinate {
    var latitude: Double
    var longitude: Double
}

// Tags: CustomStringConvertible, extension, interpolated string
// note: the extension allows us to organize a type around functionality.
extension Coordinate: CustomStringConvertible {
    var description: String {
        return "\(latitude),\(longitude)"
    }
}

// ref: https://teamtreehouse.com/library/finishing-up-the-networking-stack

class Location: NSObject {
    var place: String?
    var address: String?
    var coordinate: Coordinate?
//    let distance: Double?
//    let countryCode: String?
//    let country: String?
//    let state: String?
//    let city: String?
//    let streetAddress: String?
//    let crossStreet: String?
//    let postalCode: String?
    
    init(place: String, address: String, long: Double, lat: Double) {
        let coordinate =  Coordinate.init(latitude: lat, longitude: long)
        self.place = place
        self.address = address
        self.coordinate = coordinate
    }
}

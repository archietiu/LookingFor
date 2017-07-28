//
//  Party.swift
//  LookingFor
//
//  Created by Archie Tiu on 16/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class Party: NSObject {
    var id: String?
    var createdBy: String?
    var name: String?
    var desc: String?
    var startDate: NSNumber?
    var endDate: NSNumber?
    var place: String?
    var address: String?
//    var location: Location?
    var long: Double?
    var lat: Double?
    var isActive: Int?
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.desc = dictionary["description"] as? String
        self.createdBy = dictionary["createdBy"] as? String
        self.startDate = dictionary["startDate"] as? NSNumber
        self.endDate = dictionary["endDate"] as? NSNumber
        self.place = dictionary["place"] as? String
        self.address = dictionary["address"] as? String
        self.long = dictionary["long"] as? Double
        self.lat = dictionary["lat"] as? Double
        self.isActive = dictionary["isActive"] as? Int
    }
    
    func printModel() {
        print(name ?? "no name")
        print(desc ?? "no desc")
        print(createdBy ?? "no createdBy")
        print(startDate ?? "no startDate")
        print(endDate ?? "no endDate")
        print(place ?? "no place")
        print(address ?? "no address")
        print(long ?? "no long")
        print(lat ?? "no lat")
        print(isActive ?? "no isActive")
    }
}

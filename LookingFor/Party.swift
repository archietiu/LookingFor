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
    var location: Location?
    var isActive: Int?
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.desc = dictionary["description"] as? String
        self.createdBy = dictionary["createdBy"] as? String
        self.startDate = dictionary["startDate"] as? NSNumber
        self.endDate = dictionary["endDate"] as? NSNumber
        self.place = dictionary["place"] as? String
        self.address = dictionary["address"] as? String
        self.isActive = dictionary["isActive"] as? Int
    }
}

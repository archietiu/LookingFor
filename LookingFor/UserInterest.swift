//
//  UserInterests.swift
//  LookingFor
//
//  Created by Archie Tiu on 10/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class UserInterest: NSObject {
    var id: String?
    var userId: String?
    var interestId: String?
    var isActive: Int?
    
    init(dictionary: [String: Any]) {
        self.userId = dictionary["isActive"] as? String
        self.interestId = dictionary["isActive"] as? String
        self.isActive = dictionary["isActive"] as? Int
    }
    
}

//
//  Interests.swift
//  LookingFor
//
//  Created by Archie Tiu on 10/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class Interest: NSObject {
    var id: String?
    var name: String?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
    }
    
}


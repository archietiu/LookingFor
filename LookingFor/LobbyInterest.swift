//
//  LobbyInterest.swift
//  LookingFor
//
//  Created by Archie Tiu on 14/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class LobbyInterest: NSObject {
    var id: String?
    var interest: String?
    var lobby: String?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.interest = dictionary["interest"] as? String
        self.lobby = dictionary["lobby"] as? String
    }
    
}

//
//  Lobby.swift
//  LookingFor
//
//  Created by Archie Tiu on 13/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class Lobby: NSObject {
    var id: String?
    var name: String?
    var createdBy: String?
    var dateCreated: NSNumber?
    var partyCount: Int?
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.createdBy = dictionary["createdBy"] as? String
        self.dateCreated = dictionary["dateCreated"] as? NSNumber
    }
    
    func printModel() {
        print(id ?? "no id")
        print(name ?? "no name")
        print(createdBy ?? "no creator")
        print(dateCreated ?? "no date")
        print(partyCount ?? "no partyCount")
    }
}

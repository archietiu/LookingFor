//
//  PartyUsers.swift
//  LookingFor
//
//  Created by Archie Tiu on 27/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class PartyUsers: NSObject {
    var partyId: String?
    var userId: String?
    
    init(partyId: String, userId: String) {
        self.partyId = partyId
        self.userId = userId
    }
    
    func printModel() {
        print("PRINTING: PARTY USERS")
        print(partyId ?? "no partyId")
        print(userId ?? "no userId")
    }
}

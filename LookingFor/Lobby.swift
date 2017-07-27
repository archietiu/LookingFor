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
//        if let dateCreated = dictionary["dateCreated"] as? TimeInterval {
//            let date = Date(timeIntervalSinceNow: dateCreated / 10000.0)
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
//            dateFormatter.locale = Locale.init(identifier: "en_GB")
//            let dateFormatted = dateFormatter.string(from: date as Date)
//            self.dateCreated = dateFormatted
//        }
    }
}

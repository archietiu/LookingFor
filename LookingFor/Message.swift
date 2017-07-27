//
//  Message.swift
//  LookingFor
//
//  Created by Archie Tiu on 20/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var id: String?
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    var videoUrl: String?

    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["message"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        
        self.videoUrl = dictionary["videoUrl"] as? String
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    func printModel() {
        print(self.fromId ?? "no fromId")
        print(self.text ?? "no text")
        print(self.toId ?? "no toId")
        print(self.timestamp ?? "no timestamp")
        print(self.imageUrl ?? "no image")
        print(self.imageWidth ?? "no imageWidth")
        print(self.imageHeight ?? "no imageHeight")
    }
    
}

//
//  PartyController.swift
//  LookingFor
//
//  Created by Archie Tiu on 20/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase

class PartyController: UIViewController {
    
    var party: Party?
    var user: User?
    
    let timeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "When Is The Party?"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(handleJoinLeaveParty))
    }
    
    func handleJoinLeaveParty() {
        guard let partyId = party?.id, let userId = user?.id, let userName = user?.name, let userEmail = user?.email, let userProfileImageUrl = user?.profileImageUrl else { return }
        let partyMemberChildRef = Database.database().reference().child("party-users").child(partyId).child(userId)
        let partyMemberValues = ["name": userName, "email": userEmail, "profileImageUrl": userProfileImageUrl] as [String: Any]
        partyMemberChildRef.updateChildValues(partyMemberValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("Successfully joined the party!")
        }
        
        guard
            let partyName = party?.name,
            let createdBy = party?.createdBy,
            let startDate = party?.startDate,
            let endDate = party?.endDate,
            let place = party?.place,
            let isActive = party?.isActive else { return }
        let userPartyChildRef = Database.database().reference().child("user-parties").child(userId).child(partyId)
        let userPartyValues = [
            "name": partyName,
            "createdBy": createdBy,
            "startDate": startDate,
            "endDate": endDate,
            "place": place,
            "address": party?.address ?? "no address",
            "isActive": isActive
        ] as [String: Any]
        userPartyChildRef.updateChildValues(userPartyValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("Successfully created user-parties")
        }
        
    }
    
    
    
}

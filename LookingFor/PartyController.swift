//
//  PartyController.swift
//  LookingFor
//
//  Created by Archie Tiu on 20/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class PartyController: UIViewController {
    
    var party: Party?
    var user: User?
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timeLabelSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let partyDescLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let partyDescSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let placeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let placeLabelSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let partyMembersSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(handleJoinLeaveParty))
    }
    
    func setupLayout() {
        
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

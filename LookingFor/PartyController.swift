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

class PartyController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var joinLeaveButtonTitle: String?
    var party: Party?
    var user: User?
    var users = [User]()
    var partyListController: PartyListController?
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
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
        label.font = UIFont.systemFont(ofSize: 15)
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
        label.font = UIFont.systemFont(ofSize: 15)
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
    
    let partyMembersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
    var mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let partyMembersSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let joinLeaveButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.backgroundColor = BackgroundColorProvider().colors["green"]
        button.setTitle("Join", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleJoinLeaveParty), for: .touchUpInside)
        return button
    }()
    
    var mapView: GMSMapView!
    
    var navigationBarTitle: String? {
        didSet {
            if navigationBarTitle == "Join" {
                joinLeaveButton.backgroundColor = BackgroundColorProvider().colors["green"]
                joinLeaveButton.setTitle(navigationBarTitle, for: UIControlState())
            } else {
                joinLeaveButton.backgroundColor = BackgroundColorProvider().colors["red"]
                joinLeaveButton.setTitle(navigationBarTitle, for: UIControlState())
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        fetchParty()
    }
    
    func setupMapView () {
        guard let long = party?.long, let lat = party?.lat, let partyName = party?.name, let partyDesc = party?.desc else { return }
        let coordinate = Coordinate(latitude: lat, longitude: long)
        let zoomLevel: Float = 15
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapContainerView.addSubview(mapView)
        mapView.settings.myLocationButton = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.title = partyName
        marker.snippet = partyDesc
        marker.map = mapView
    }
    
    func setupLayout() {
        
        view.backgroundColor = .white
        
        view.addSubview(timeLabel)
        view.addSubview(timeLabelSeparatorView)
        view.addSubview(partyDescLabel)
        view.addSubview(partyDescSeparatorView)
        view.addSubview(placeLabel)
        view.addSubview(placeLabelSeparatorView)
        view.addSubview(mapContainerView)
        view.addSubview(partyMembersCollectionView)
        view.addSubview(partyMembersSeparatorView)
        view.addSubview(joinLeaveButton)
        
        navigationController?.navigationBar.backgroundColor = BackgroundColorProvider().colors["teal"]
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.tintColor = UIColor.white
        
        timeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        timeLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        timeLabelSeparatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        timeLabelSeparatorView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
        timeLabelSeparatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        timeLabelSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        partyDescLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        partyDescLabel.topAnchor.constraint(equalTo: timeLabelSeparatorView.bottomAnchor, constant: 8).isActive = true
        partyDescLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        partyDescLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        partyDescSeparatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        partyDescSeparatorView.topAnchor.constraint(equalTo: partyDescLabel.bottomAnchor).isActive = true
        partyDescSeparatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        partyDescSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        placeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        placeLabel.topAnchor.constraint(equalTo: partyDescSeparatorView.bottomAnchor, constant: 8).isActive = true
        placeLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        placeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        placeLabelSeparatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        placeLabelSeparatorView.topAnchor.constraint(equalTo: placeLabel.bottomAnchor).isActive = true
        placeLabelSeparatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        placeLabelSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        mapContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapContainerView.topAnchor.constraint(equalTo: placeLabelSeparatorView.bottomAnchor, constant: 8).isActive = true
        mapContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        setupMapView()
        
        partyMembersCollectionView.delegate = self
        partyMembersCollectionView.dataSource = self
        partyMembersCollectionView.register(PartyMembersCell.self, forCellWithReuseIdentifier: cellId)
        
        partyMembersCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        partyMembersCollectionView.topAnchor.constraint(equalTo: mapContainerView.bottomAnchor, constant: 8).isActive = true
        partyMembersCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        partyMembersCollectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        partyMembersSeparatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        partyMembersSeparatorView.topAnchor.constraint(equalTo: partyMembersCollectionView.bottomAnchor).isActive = true
        partyMembersSeparatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        partyMembersSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        joinLeaveButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        joinLeaveButton.topAnchor.constraint(equalTo: partyMembersSeparatorView.bottomAnchor, constant: 8).isActive = true
        joinLeaveButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        joinLeaveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Apply numberOfItemsInSection")
        return users.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PartyMembersCell
        if let profileImage = users[indexPath.row].profileImageUrl, let userName = users[indexPath.row].name {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImage)
            cell.partyMemberNameLabel.text = userName
        }
        print("Apply cellForItemAt")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("Apply sizeForItemAt")
        return CGSize(width: 70, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("Apply insetForSectionAt")
        return UIEdgeInsetsMake(0, 12, 0, 12)
    }
    
    func handleJoinLeaveParty() {
        if navigationBarTitle == "Join" {
            joinParty()
        } else {
            leaveParty()
        }
    }
    
    func leaveParty() {
        let dbRef = Database.database().reference()
        
        let alert = UIAlertController(title: "Leave Party", message: "Are you sure you want to leave the party?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            guard let userId = self.user?.id, let partyId = self.party?.id else { return }
            dbRef.child("party-users").child(partyId).child(userId).removeValue()
            dbRef.child("user-parties").child(userId).child(partyId).removeValue()
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func joinParty() {
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
        
        navigationController?.popViewController(animated: true)
        print("Dismiss completed")
        self.partyListController?.showChatLogController(forParty: self.party!, withUserId: userId)
//        dismiss(animated: true) {
//            print("Dismiss completed")
//            self.partyListController?.showChatLogController(forParty: self.party!, withUserId: userId)
//        }
        
    }
    
    func fetchParty() {
        guard let partyId = party?.id, let name = party?.name, let desc = party?.desc, let time = party?.startDate, let place = party?.place
//            , let address = party?.address
            else { return }
        
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm a"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let dateFormatted = dateFormatter.string(from: date as Date)
        
        timeLabel.text = dateFormatted
        placeLabel.text = place
        partyDescLabel.text = desc
        navigationController?.navigationItem.title = name
        
        let dbRef = Database.database().reference()
        dbRef.child("party-users").child(partyId).observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: dictionary)
            user.id = snapshot.key
            self.users.append(user)
            
            DispatchQueue.main.async(execute: {
                self.partyMembersCollectionView.reloadData()
            })
            
        }, withCancel: nil)
    }
}

class PartyMembersCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    let partyMemberNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
//        label.backgroundColor = .white
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
//        backgroundColor = .green
        addSubview(profileImageView)
        addSubview(partyMemberNameLabel)
//        profileImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 70)

        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        partyMemberNameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        partyMemberNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2).isActive = true
        partyMemberNameLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        partyMemberNameLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        partyMemberNameLabel.sizeToFit()
        partyMemberNameLabel.numberOfLines = 2
        
    }
}























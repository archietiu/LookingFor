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

class PartyController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let cellId = "cellId"
    
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
        collectionView.backgroundColor = .lightGray
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
    
    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(handleJoinLeaveParty))
        setupLayout()
        fetchParty()
        partyMembersCollectionView.delegate = self
        partyMembersCollectionView.dataSource = self
        partyMembersCollectionView.register(PartyMembersCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupMapView () {
        guard let long = party?.long, let lat = party?.lat, let partyName = party?.name, let partyDesc = party?.desc else { return }
        let coordinate = Coordinate(latitude: lat, longitude: long)
        let zoomLevel: Float = 15
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoomLevel)
//        let camera = GMSCameraPosition.camera(withLatitude: 40.2066757, longitude: -74.0437097, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        view = mapView
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
        
        partyMembersCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        partyMembersCollectionView.topAnchor.constraint(equalTo: mapContainerView.bottomAnchor, constant: 8).isActive = true
        partyMembersCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        partyMembersCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
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
        timeLabel.text = String(describing: time)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PartyMembersCell
        if let profileImage = users[indexPath.row].profileImageUrl, let userName = users[indexPath.row].name {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImage)
            cell.partyMemberNameLabel.text = userName
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

class PartyMembersCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let partyMemberNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
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
        backgroundColor = .green
        frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        print(frame.width, frame.height)
        addSubview(profileImageView)
        addSubview(partyMemberNameLabel)
//        profileImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 60)
        
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        partyMemberNameLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: 16).isActive = true
        partyMemberNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        partyMemberNameLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        partyMemberNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}























//
//  CreatePartyController.swift
//  LookingFor
//
//  Created by Archie Tiu on 16/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase
import GooglePlacePicker

class CreatePartyController: UIViewController {
    
    var user: User?
    var lobby: Lobby?
    var partyListController: PartyListController?
    var location: Location?
    
    let titleView: UIView = {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Party"
        label.tintColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let userProfileContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userProfileSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Party Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Describe Your Party"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let descSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let timeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "When Is The Party?"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let startDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    let endDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    
    let startDateSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let endDateSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let locationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add Location"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let locationSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let addLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Add Location", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handlePlacePicker), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelCreateParty))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(handleCreateParty))
        navigationController?.navigationBar.barTintColor = BackgroundColorProvider().colors["purple"]
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.tintColor = UIColor.white
        view.backgroundColor = BackgroundColorProvider().colors["orange"]
        view.addSubview(inputsContainerView)
        setupNavTitleBar()
        setupInputsContainerView()
    }

    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var userProfileContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var descTextFieldHeightAnchor: NSLayoutConstraint?
    var startDatePickerHeightAnchor: NSLayoutConstraint?
    var endDatePickerHeightAnchor: NSLayoutConstraint?
    var locationTextFieldHeightAnchor: NSLayoutConstraint?
    var addLocationButtonHeightAnchor: NSLayoutConstraint?
    
    func setupNavTitleBar() {
        titleView.addSubview(titleLabel)
        titleView.tintColor = UIColor.white
        titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: titleView.widthAnchor).isActive = true
        self.navigationItem.titleView = titleView
    }
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 550)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(userProfileContainerView)
        inputsContainerView.addSubview(userProfileSeparatorView)
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(descriptionTextField)
        inputsContainerView.addSubview(descSeparatorView)
        inputsContainerView.addSubview(startDatePicker)
        inputsContainerView.addSubview(startDateSeparatorView)
        inputsContainerView.addSubview(endDatePicker)
        inputsContainerView.addSubview(endDateSeparatorView)
        inputsContainerView.addSubview(locationTextField)
        inputsContainerView.addSubview(locationSeparatorView)
        inputsContainerView.addSubview(addLocationButton)
        
        //need x, y, width, height constraints
        userProfileContainerView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        userProfileContainerView.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        userProfileContainerView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userProfileContainerViewHeightAnchor = userProfileContainerView.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/11)
        userProfileContainerViewHeightAnchor?.isActive = true
        
        userProfileContainerView.addSubview(profileImageView)
        userProfileContainerView.addSubview(nameLabel)
            
            //need x,y,width,height anchors
            profileImageView.leftAnchor.constraint(equalTo: userProfileContainerView.leftAnchor).isActive = true
            profileImageView.centerYAnchor.constraint(equalTo: userProfileContainerView.centerYAnchor).isActive = true
            profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            if let profileImageUrl = user?.profileImageUrl {
                profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
            
            //need x,y,width,height anchors
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
            nameLabel.rightAnchor.constraint(equalTo: userProfileContainerView.rightAnchor).isActive = true
            nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
            nameLabel.text = user?.name
        
        //need x, y, width, height constraints
        userProfileSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        userProfileSeparatorView.topAnchor.constraint(equalTo: userProfileContainerView.bottomAnchor).isActive = true
        userProfileSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userProfileSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: userProfileContainerView.bottomAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/12)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        descriptionTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        descriptionTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        descriptionTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        descTextFieldHeightAnchor = descriptionTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 2/12)
        descTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        descSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        descSeparatorView.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor).isActive = true
        descSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        descSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        startDatePicker.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        startDatePicker.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor).isActive = true
        startDatePicker.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        startDatePickerHeightAnchor = startDatePicker.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 2/12)
        startDatePickerHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        startDateSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        startDateSeparatorView.topAnchor.constraint(equalTo: startDatePicker.bottomAnchor).isActive = true
        startDateSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        startDateSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        endDatePicker.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        endDatePicker.topAnchor.constraint(equalTo: startDatePicker.bottomAnchor).isActive = true
        endDatePicker.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        endDatePickerHeightAnchor = endDatePicker.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 2/12)
        endDatePickerHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        endDateSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        endDateSeparatorView.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor).isActive = true
        endDateSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        endDateSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        locationTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        locationTextField.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor).isActive = true
        locationTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        locationTextFieldHeightAnchor = locationTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/12)
        locationTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        locationSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        locationSeparatorView.topAnchor.constraint(equalTo: locationTextField.bottomAnchor).isActive = true
        locationSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        locationSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        //need x, y, width, height constraints
        addLocationButton.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        addLocationButton.topAnchor.constraint(equalTo: locationTextField.bottomAnchor).isActive = true
        addLocationButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        addLocationButtonHeightAnchor = addLocationButton.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/12)
        addLocationButtonHeightAnchor?.isActive = true
    }
    
    func handlePlacePicker() {
//        let placePickerController = PlacePickerController()
//        navigationController?.pushViewController(placePickerController, animated: true)
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    func handleCancelCreateParty() {
        dismiss(animated: true, completion: nil)
    }
    
    func handleCreateParty() {
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        if let name = nameTextField.text,
            let description = descriptionTextField.text,
            let place = locationTextField.text,
            let address = location?.address,
            let lat = location?.coordinate?.latitude,
            let long = location?.coordinate?.longitude,
            let userId = user?.id,
            let lobbyId = lobby?.id,
            let lobbyName = lobby?.name,
            let lobbyCreatedBy = lobby?.createdBy,
            let lobbyDateCreated = lobby?.dateCreated {
            let partyRef = Database.database().reference().child("parties")
            let partyChildRef = partyRef.childByAutoId()
            let partyValues = [
                "createdBy": userId,
                "name": name,
                "description": description,
                "startDate": startDate.timeIntervalSince1970,
                "endDate": endDate.timeIntervalSince1970,
                "place": place,
                "address": address,
                "long": long,
                "lat": lat,
                "isActive": 1
            ] as [String: Any]
            partyChildRef.updateChildValues(partyValues) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Successfully added new party")
            }
            
            let partyLobbiesRef = Database.database().reference().child("party-lobbies").child(partyChildRef.key).child(lobbyId)
            let partyLobbiesValues = ["name": lobbyName, "createdBy": lobbyCreatedBy, "dateCreated": lobbyDateCreated] as [String: Any]
            partyLobbiesRef.updateChildValues(partyLobbiesValues) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Successfully added new party-lobbies")
            }
            
            let lobbyPartiesRef = Database.database().reference().child("lobby-parties").child(lobbyId).child(partyChildRef.key)
            let lobbyPartiesValues = partyValues
            lobbyPartiesRef.updateChildValues(lobbyPartiesValues) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Successfully added new lobby-parties")
            }
            
            let partyLocationChildRef = Database.database().reference().child("party-location").child(partyChildRef.key).childByAutoId()
            let partyLocationValues = ["place": place, "address": address, "latitude": lat, "longitude": long] as [String: Any]
            partyLocationChildRef.updateChildValues(partyLocationValues) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Successfully added new party-locations")
            }
            
            guard let userId = user?.id, let userName = user?.name, let userEmail = user?.email, let userProfileImageUrl = user?.profileImageUrl else { return }
            let partyMemberChildRef = Database.database().reference().child("party-users").child(partyChildRef.key).child(userId)
            let partyMemberValues = ["name": userName, "email": userEmail, "profileImageUrl": userProfileImageUrl] as [String: Any]
            partyMemberChildRef.updateChildValues(partyMemberValues) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Successfully joined the party!")
            }
            
            let userPartyChildRef = Database.database().reference().child("user-parties").child(userId).child(partyChildRef.key)
            let userPartyValues = [
                "createdBy": userId,
                "name": name,
                "description": description,
                "startDate": startDate.timeIntervalSince1970,
                "endDate": endDate.timeIntervalSince1970,
                "place": place,
                "address": address,
                "long": long,
                "lat": lat,
                "isActive": 1
                ] as [String: Any]
            userPartyChildRef.updateChildValues(userPartyValues) { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Successfully created user-parties")
            }
            
            
            
            dismiss(animated: true, completion: nil)
        }
    }

}

extension CreatePartyController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        
        viewController.dismiss(animated: true, completion: nil)
        
//        guard let address = place.formattedAddress, let attributions = place.attributions else { return }
        
        location = Location.init(place: place.name,
                                     address: place.formattedAddress ?? "no address",
                                     long: place.coordinate.longitude,
                                     lat: place.coordinate.latitude)
        
        self.locationTextField.text = location?.place ?? "no location"
        
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}






























//
//  LobbyController.swift
//  LookingFor
//
//  Created by Archie Tiu on 09/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class LobbyController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var user: User?
    var userInterests = [UserInterest]()
    var lobbies = [Lobby]()
    let colorProvider = BackgroundColorProvider()
    let cellId = "cellId"
    
    
    let tableView: UITableView = {
        let tableView = UITableView()
//        tableView.backgroundColor = BackgroundColorProvider().colors["white"]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var interestNearbySegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Interest", "Nearby"])
        sc.translatesAutoresizingMaskIntoConstraints = false
//        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleInterestNearbySegmentSelect), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lobby", style: .plain, target: self, action: #selector(handleReset))
        navigationController?.navigationBar.barTintColor = BackgroundColorProvider().colors["teal"]
//        navigationController?.navigationBar.backgroundColor = BackgroundColorProvider().colors["teal"]
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.tintColor = UIColor.white
        view.addSubview(interestNearbySegmentedControl)
        view.addSubview(tableView)
        setupSearchController()
        checkIfUserIsLoggedIn()
        tableView.addSubview(refreshController)
        tableView.addSubview(interestNearbySegmentedControl)
//        tableView.tableHeaderView = searchController.searchBar
        tableView.tableHeaderView = interestNearbySegmentedControl
        tableView.register(LobbyCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        
        
        GMSServices.provideAPIKey(ServiceKeys.GMSKey)
        GMSPlacesClient.provideAPIKey(ServiceKeys.GooglePlacesKey)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .left
        self.tableView.addGestureRecognizer(leftSwipe)
    }
    
    func swipeLeft() {
        interestNearbySegmentedControl.selectedSegmentIndex = 1
//        let controller = NearbyController()
//        navigationController?.pushViewController(controller, animated: true)
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    func handleInterestNearbySegmentSelect() {
        if interestNearbySegmentedControl.selectedSegmentIndex == 1 {
            let controller = NearbyController()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func refreshTableView() {
        lobbies.removeAll()
        if let userId = self.user?.id {
            fetchLobbies(userId: userId)
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        })
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Lobby"
        definesPresentationContext = true
//        searchController.searchBar.scopeButtonTitles = ["Interest", "Nearby"]
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            fetchUserAndSetupNavBarTitle()
        } else {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    func handleLogout() {
//        do {
//            try Auth.auth().signOut()
//        } catch let logoutError {
//            print(logoutError)
//        }
//        user = nil
//        userInterests.removeAll()
//        lobbies.removeAll()
//        let loginController = LoginController()
//        loginController.lobbyController = self
//        present(loginController, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.user = User(dictionary: dictionary)
                self.user?.setValuesForKeys(dictionary)
                self.user?.id = snapshot.key
//                print(self.user?.name ?? "no name")
//                print(self.user?.email ?? "no email")
                if let user = self.user, let userId = self.user?.id {
                    self.setupNavBarWithUser(user)
                    self.fetchUserActivatedInterests(userId: userId)
                    self.fetchLobbies(userId: userId)
                }
            }
            
        }, withCancel: nil)
    }
    
    func fetchUserActivatedInterests(userId: String) {
        let ref = Database.database().reference().child("user-interests").child(userId).queryOrdered(byChild: "isActive").queryEqual(toValue: 1)
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let userInterest = UserInterest(dictionary: dictionary)
                userInterest.id = userId
                userInterest.userId = userId
                userInterest.interestId = snapshot.key
                self.userInterests.append(userInterest)

                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
    }
    
    func fetchLobbies(userId: String) {
        Database.database().reference().child("user-interests").child(userId).observe(.childAdded, with: { (interestSnaphot) in
            Database.database().reference().child("interest-lobbies").child(interestSnaphot.key).observe(.childAdded, with: {
                (lobbySnapshot) in
                if let dictionary = lobbySnapshot.value as? [String: Any] {
                    let lobby = Lobby(dictionary: dictionary)
                    lobby.id = lobbySnapshot.key
                    self.lobbies.append(lobby)
                    
                    if let lobbyId = lobby.id {
                        Database.database().reference().child("lobby-parties").child(lobbyId).observe(.value, with: { (snapshot) in
                            let partyCount = snapshot.childrenCount
                            lobby.partyCount = Int(partyCount)
//                            for lobby in self.lobbies {
//                                print(lobby.id ?? "no id")
//                                print(lobby.name ?? "no name")
//                                print(lobby.createdBy ?? "no creator")
//                                print(lobby.dateCreated ?? "no date")
//                                print(lobby.partyCount ?? "no partyCount")
//                            }
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                            })
                        }, withCancel: nil)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User) {
//        messages.removeAll()
//        messagesDictionary.removeAll()
        tableView.reloadData()
        
//        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapProfileImageView)))
        titleView.isUserInteractionEnabled = true
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        interestNearbySegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        interestNearbySegmentedControl.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        interestNearbySegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        interestNearbySegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        tableView.centerXAnchor.constraint(equalTo: interestNearbySegmentedControl.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: interestNearbySegmentedControl.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func handleTapProfileImageView() {
        guard let user = self.user else { return }
        let controller = InterestController()
        controller.user = user
        controller.userInterests = userInterests
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lobbies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LobbyCell
        let lobby = lobbies[indexPath.row]
        cell.lobbyLabel.text = lobby.name
        cell.partyCountLabel.text = lobby.partyCount?.description
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lobby = self.lobbies[indexPath.row]
        guard let user = self.user else { return }
        showPartyListController(user: user, lobby: lobby)
    }
    
    func showPartyListController(user: User, lobby: Lobby) {
        let controller = PartyListController()
        controller.user = user
        controller.lobby = lobby
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReset() {
        /*
        let db = Database.database().reference()
        
        let alert = UIAlertController(title: "Are you sure?", message: "This will erase all data.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            for childRef in ChildReferences {
                db.child(childRef).removeValue()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        */
        
        let lobby = LobbyController1()
        navigationController?.pushViewController(lobby, animated: true)
    }
}

extension LobbyController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        guard let address = place.formattedAddress, let attributions = place.attributions else { return }
        
        print("Place name \(place.name)")
        print("Place address \(address)")
        print("Place attributions \(attributions)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
}

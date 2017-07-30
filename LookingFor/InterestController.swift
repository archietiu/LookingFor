//
//  ViewController.swift
//  LookingFor
//
//  Created by Archie Tiu on 13/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase

class InterestController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UISearchBarDelegate {
    
    let cellId = "cellId"
    var user: User?
    
    var currentUserId: String = {
        var userId = ""
        if let user = Auth.auth().currentUser?.uid {
            userId = user
        }
        return userId
    }()
    
    var interests = [Interest]()
    var userInterests = [UserInterest]()
    
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        return sc
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = BackgroundColorProvider().colors["orange"]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAddNewInterest))
        navigationController?.navigationBar.backgroundColor = BackgroundColorProvider().colors["teal"]
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.tintColor = UIColor.white
        
        view.addSubview(tableView)
        setupSearchController()
        setupLayoutConstraints()
        tableView.addSubview(refreshController)
        tableView.tableHeaderView = searchController.searchBar
        tableView.register(InterestCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        fetchInterests()
//        fetchUserActivatedInterests(userId: self.currentUserId)
    }
    
    func refreshTableView() {
        if let userId = user?.id {
            interests.removeAll()
            userInterests.removeAll()
            fetchInterests()
            fetchUserActivatedInterests(userId: userId)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.refreshController.endRefreshing()
            })
        }
    }
    
    func setupLayoutConstraints() {
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Interest"
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            interests.removeAll()
            tableView.reloadData()
            let ref = Database.database().reference().child("interests")
            let query = ref.queryOrdered(byChild: "name").queryStarting(atValue: searchText).queryEnding(atValue: "\(searchText)\u{f8ff}")
            query.observe(.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    let interest = Interest(dictionary: dictionary)
                    interest.id = snapshot.key
                    self.interests.append(interest)
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                
            }, withCancel: nil)
        }
    }
    
    func handleAddNewInterest() {
        let alert = UIAlertController(title: "What are your interests?", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Interest here"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            guard let text = textField?.text else { return }
            self.handleSaveInterest(interestText: text)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleSaveInterest(interestText: String) {
        let interestRef = Database.database().reference().child("interests")
        let interestChildRef = interestRef.childByAutoId()
        let interestText = interestText
        let interestValues = ["name": interestText] as [String: Any]
        interestChildRef.updateChildValues(interestValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            print("Successfully added new interest")
        }
        
        let lobbyRef = Database.database().reference().child("lobbies")
        let lobbyChildRef = lobbyRef.childByAutoId()
        let lobbyName = interestText
        let lobbyValues = ["name": lobbyName, "createdBy": currentUserId, "dateCreated": Int(Date().timeIntervalSince1970)] as [String: Any]
        lobbyChildRef.updateChildValues(lobbyValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            print("Successfully added new lobby")
        }
        
        let lobbyInterestsRef = Database.database().reference().child("lobby-interests")
        let lobbyInterestsChildRef = lobbyInterestsRef.child(lobbyChildRef.key).child(interestChildRef.key)
        let lobbyInterestsValues = interestValues
        lobbyInterestsChildRef.updateChildValues(lobbyInterestsValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            print("Successfully added new lobby-interests")
        }
        
        let interestLobbiesRef = Database.database().reference().child("interest-lobbies")
        let interestLobbiesChildRef = interestLobbiesRef.child(interestChildRef.key).child(lobbyChildRef.key)
        let interestLobbiesValues = lobbyValues
        interestLobbiesChildRef.updateChildValues(interestLobbiesValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            print("Successfully added new interest-lobbies")
        }
    }
    
    func fetchInterests() {
        let ref = Database.database().reference().child("interests").queryOrdered(byChild: "name")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let interest = Interest(dictionary: dictionary)
                interest.id = snapshot.key
                self.interests.append(interest)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! InterestCell
        let interest = interests[indexPath.row]
        
        cell.interestLabel.text = interest.name
        
        if let interestId = interest.id {
            let interestIsActive = userInterests.filter { $0.interestId! == interestId}
            
            if interestIsActive.count > 0 {
                cell.activateInterestSwitch.isOn = true
            } else {
                cell.activateInterestSwitch.isOn = false
            }
            
        }
        
        cell.didTapSwitchHandler = {
            guard
                let interestId = interest.id,
                let interestName = interest.name,
                let userId = Auth.auth().currentUser?.uid,
                let userEmail = self.user?.email,
                let userName = self.user?.name,
                let userProfileImageUrl = self.user?.profileImageUrl
                else { return }
            
            if cell.activateInterestSwitch.isOn {
                // user-interests
                let userInterestsRef = Database.database().reference().child("user-interests")
                let userInterestsChildRef = userInterestsRef.child(userId).child(interestId)
                let userInterestsValues = ["name": interestName, "isActive": 1] as [String: Any]
                
                userInterestsChildRef.updateChildValues(userInterestsValues) { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    print("user-interests \(interest.name!) activated")
                }
                // interest-users
                let interestUsersRef = Database.database().reference().child("interest-users")
                let interestUsersChildRef = interestUsersRef.child(interestId).child(userId)
                let interestUsersValues = ["email": userEmail, "name": userName, "profileImageUrl": userProfileImageUrl, "isActive": 1] as [String: Any]
                
                interestUsersChildRef.updateChildValues(interestUsersValues) { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    print("interest-users \(interest.name!) activated")
                }
                
            } else {
                let userInterestsRef = Database.database().reference().child("user-interests")
                let userInterestsChildRef = userInterestsRef.child(userId).child(interestId)
//                let userInterestsValues = ["isActive": 0] as [String: Any]
                userInterestsChildRef.removeValue()
//                userInterestsChildRef.updateChildValues(userInterestsValues) { (error, ref) in
//                    if error != nil {
//                        print(error!)
//                        return
//                    }
//                    
//                    print("user-interests \(interest.name!) activated")
//                }
                
                let interestUsersRef = Database.database().reference().child("interest-users")
                let interestUsersChildRef = interestUsersRef.child(interestId).child(userId)
//                let interestUsersValues = ["isActive": 0] as [String: Any]
                interestUsersChildRef.removeValue()
//                interestUsersChildRef.updateChildValues(interestUsersValues) { (error, ref) in
//                    if error != nil {
//                        print(error!)
//                        return
//                    }
//                    
//                    print("interest-users \(interest.name!) activated")
//                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let interest = interests[indexPath.row]
        guard let interestId = interest.id ,let interestName = interest.name else { return }
        Database.database().reference().child("interests").child(interestId).removeValue()
        interests.removeAll()
        fetchInterests()
        print("Interest \(interestName) deleted!")
    }
}











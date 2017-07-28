//
//  PartyListController.swift
//  LookingFor
//
//  Created by Archie Tiu on 16/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase

class PartyListController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let cellId = "cellId"
    var user: User?
    var lobby: Lobby?
    var parties = [Party]()
    
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
    
//    let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.backgroundColor = BackgroundColorProvider().colors["orange"]
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        return tableView
//    }()
    
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAddNewParty))
        navigationController?.navigationBar.backgroundColor = UIColor.white
//        view.addSubview(tableView)
        setupSearchController()
//        setupLayoutConstraints()
        fetchParty()
        tableView.addSubview(refreshController)
        tableView.tableHeaderView = searchController.searchBar
        tableView.register(PartyCell.self, forCellReuseIdentifier: cellId)
//        tableView.dataSource = self
    }
    
//    func setupLayoutConstraints() {
//        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
//    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Party"
        definesPresentationContext = true
    }
    
    func refreshTableView() {
        parties.removeAll()
        fetchParty()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        })
        
    }
    
    func handleAddNewParty() {
        let controller = CreatePartyController()
        controller.partyListController = self
        controller.user = user
        controller.lobby = lobby
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true, completion: nil)
    }
    
    func fetchParty() {
        guard let lobbyId = lobby?.id else { return }
        let partyRef = Database.database().reference().child("lobby-parties").child(lobbyId)
        partyRef.observe(.childAdded, with: { (partiesSnapshot) in
            guard let dictionary = partiesSnapshot.value as? [String: Any] else { return }
            let party = Party(dictionary: dictionary)
            party.id = partiesSnapshot.key
            self.parties.append(party)
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
        }, withCancel: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PartyCell
        let party = parties[indexPath.row]
        cell.partyLabel.text = party.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userId = user?.id else { return }
        let party = parties[indexPath.row]
        showChatLogController(forParty: party, withUserId: userId)
    }
    
    func showChatLogController(forParty party: Party, withUserId userId: String) {
        guard let partyId = party.id, let userId = user?.id else { return }
        let dbChildRef = Database.database().reference().child("party-users").child(partyId)
        let queryChildRef = dbChildRef.queryOrderedByKey().queryEqual(toValue: userId)
        queryChildRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print("User is in the party!")
                let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
                chatLogController.user = self.user
                chatLogController.party = party
                self.navigationController?.pushViewController(chatLogController, animated: true)
            } else {
                print("User is not in the party!")
                let partyController = PartyController()
                partyController.party = party
                partyController.user = self.user
                self.navigationController?.pushViewController(partyController, animated: true)
            }
        }, withCancel: nil)
        
//        if userId == snapshot.key {
//            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//            chatLogController.user = self.user
//            chatLogController.party = party
//            self.navigationController?.pushViewController(chatLogController, animated: true)
//        }
//        else {
//            let partyController = PartyController()
//            partyController.party = party
//            partyController.user = self.user
//            self.navigationController?.pushViewController(partyController, animated: true)
//        }
    }
}































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
//            for pt in self.parties {
//                print(pt.id ?? "no id")
//                print(pt.name ?? "no name")
//                print(pt.desc ?? "no desc")
//                print(pt.location ?? "no location")
//                print(pt.startDate ?? "no startDate")
//                print(pt.endDate ?? "no endDate")
//                print(pt.longitude ?? "no longitude")
//                print(pt.latitude ?? "no latitude")
//            }
            
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
        guard let userId = user?.id, let partyId = parties[indexPath.row].id else { return }
        Database.database().reference().child("party-users").child(partyId).child(userId).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if userId == snapshot.key {
                let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
                chatLogController.user = self.user
                chatLogController.party = self.parties[indexPath.row]
                self.navigationController?.pushViewController(chatLogController, animated: true)
            }
            else {
                let controller = PartyController()
                controller.party = self.parties[indexPath.row]
                controller.user = self.user
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
        
        
    }
}































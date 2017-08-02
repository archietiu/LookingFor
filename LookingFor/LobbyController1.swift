//
//  LobbyController1.swift
//  LookingFor
//
//  Created by Archie Tiu on 30/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class LobbyController1: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /*
     blue -> UIViewController
     yellow -> trendingCollectionView
     green -> TrendingCell
     purple -> CategoryCell
     white -> trending/category labels
     */
    
    let searchController = UISearchController(searchResultsController: nil)
    var user: User?
    var userInterests = [UserInterest]()
    var lobbies = [Lobby]()
    let colorProvider = BackgroundColorProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        checkIfUserIsLoggedIn()
        initializeGMSAPI()
    }
    
    var trendingCellId = "trendingCellId"
    var categoryCellId = "categoryCellId"
    
    let trendingLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let trendingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceHorizontal = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            fetchUserAndSetupNavBarTitle()
        } else {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        user = nil
        userInterests.removeAll()
        lobbies.removeAll()
        let loginController = LoginController()
        loginController.lobbyController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(uid)
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.user = User(dictionary: dictionary)
                self.user?.setValuesForKeys(dictionary)
                self.user?.id = snapshot.key
                if let user = self.user, let userId = self.user?.id {
                    self.setupNavBarWithUser(user)
                    self.fetchUserActivatedInterests(userId: userId)
                    self.fetchLobbies(userId: userId)
                }
            } else {
                self.handleLogout()
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
                    self.categoryCollectionView.reloadData()
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
                            DispatchQueue.main.async(execute: {
                                self.categoryCollectionView.reloadData()
                            })
                        }, withCancel: nil)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
//        navigationController?.navigationBar.barTintColor = BackgroundColorProvider().colors["teal"]
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isOpaque = false
//        navigationController?.navigationBar.tintColor = UIColor.white
        
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
        
        view.backgroundColor = BackgroundColorProvider().colors["gray"]
        
        view.addSubview(trendingLabel)
        view.addSubview(trendingCollectionView)
        view.addSubview(categoryLabel)
        view.addSubview(categoryCollectionView)
        trendingCollectionView.register(TrendingCell.self, forCellWithReuseIdentifier: trendingCellId)
        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: categoryCellId)
        
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        trendingLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        trendingLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8).isActive = true
        trendingLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        trendingLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        trendingCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        trendingCollectionView.topAnchor.constraint(equalTo: trendingLabel.bottomAnchor).isActive = true
        trendingCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        trendingCollectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        trendingCollectionView.backgroundColor = .white
        
        categoryLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        categoryLabel.topAnchor.constraint(equalTo: trendingCollectionView.bottomAnchor, constant: 8).isActive = true
        categoryLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        categoryCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        categoryCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor).isActive = true
        categoryCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        categoryCollectionView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        categoryCollectionView.backgroundColor = .white
    }
    
    func handleTapProfileImageView() {
        guard let user = self.user else { return }
        let controller = InterestController()
        controller.user = user
        controller.userInterests = userInterests
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func showPartyListController(user: User, lobby: Lobby) {
        let controller = PartyListController()
        controller.user = user
        controller.lobby = lobby
        navigationController?.pushViewController(controller, animated: true)
    }

    func initializeGMSAPI() {
        GMSServices.provideAPIKey(ServiceKeys.GMSKey)
        GMSPlacesClient.provideAPIKey(ServiceKeys.GooglePlacesKey)
    }
    
    func handleReset() {
        
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
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.trendingCollectionView {
            return 3
        } else if collectionView == self.categoryCollectionView {
            return lobbies.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.trendingCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: trendingCellId, for: indexPath) as! TrendingCell
            cell.trendingLabel.text = "#Trending"
            return cell
        } else if collectionView == self.categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellId, for: indexPath) as! CategoryCell
            let lobby = lobbies[indexPath.item]
            cell.categoryLabel.text = lobby.name
            cell.categoryCountLabel.text = lobby.partyCount?.description
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.trendingCollectionView {
            return CGSize(width: (view.frame.width - 10) * 1/2, height: 100)
        }
        else if collectionView == self.categoryCollectionView {
//            return CGSize(width: (view.frame.width * 1/2) - 17, height: 170.5)
            return CGSize(width: view.frame.width - 20, height: 120)
        }
        
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.trendingCollectionView {
            return UIEdgeInsetsMake(0, 12, 0, 12)
        } else if collectionView == self.categoryCollectionView {
            return UIEdgeInsetsMake(0, 12, 0, 12)
        }
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lobby = self.lobbies[indexPath.item]
        guard let user = self.user else { return }
        showPartyListController(user: user, lobby: lobby)
    }
}

class TrendingCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let trendingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
//        self.backgroundColor = BackgroundColorProvider().colors["orange"]
        self.backgroundColor = BackgroundColorProvider().randomColor()
        self.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        self.layer.borderWidth = 0.5
//        self.layer.shadowOpacity = 1
//        self.layer.shadowOffset = CGSize.zero
//        self.layer.shadowRadius = 10
//        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.shouldRasterize = true
    
        addSubview(trendingLabel)
        
//        trendingLabel.backgroundColor = .white
        trendingLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        trendingLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        trendingLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        trendingLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}


class CategoryCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = BackgroundColorProvider().randomColor()
        return label
    }()
    
    let categoryCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        label.backgroundColor = .white
        label.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
//        label.layer.shadowOpacity = 1
//        label.layer.shadowOffset = CGSize.zero
//        label.layer.shadowRadius = 10
//        label.layer.shadowPath = UIBezierPath(rect: label.bounds).cgPath
//        label.layer.shouldRasterize = true
        label.textColor = BackgroundColorProvider().colors["green"]
        return label
    }()
    
    func setupViews() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
//        self.backgroundColor = BackgroundColorProvider().colors["teal"]
        self.backgroundColor = BackgroundColorProvider().randomColor()
        self.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        self.layer.borderWidth = 0.5
        addSubview(categoryLabel)
        addSubview(categoryCountLabel)
        
//        categoryLabel.backgroundColor = .white
        categoryLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        categoryLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        categoryCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        categoryCountLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        categoryCountLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        categoryCountLabel.heightAnchor.constraint(equalToConstant: self.frame.height * 1/4).isActive = true
//        categoryCountLabel.layer.cornerRadius = 10
//        categoryCountLabel.layer.masksToBounds = true
    }
}































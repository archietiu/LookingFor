//
//  LobbyCell.swift
//  LookingFor
//
//  Created by Archie Tiu on 13/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase

class LobbyCell: UITableViewCell {
    let lobbyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let partyCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = BackgroundColorProvider().colors["green"]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(lobbyLabel)
        addSubview(partyCountLabel)
        
        setupLobbyCellLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLobbyCellLayout() {
        lobbyLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        lobbyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lobbyLabel.widthAnchor.constraint(equalToConstant: 96).isActive = true
        lobbyLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        partyCountLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        partyCountLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        partyCountLabel.widthAnchor.constraint(equalToConstant: 50)
        partyCountLabel.heightAnchor.constraint(equalToConstant: 50)
    }
}

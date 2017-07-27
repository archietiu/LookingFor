//
//  PartyCell.swift
//  LookingFor
//
//  Created by Archie Tiu on 16/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class PartyCell: UITableViewCell {
    let partyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //    let activateInterestSwitch: UISwitch = {
    //        let switcher = UISwitch()
    //        switcher.translatesAutoresizingMaskIntoConstraints = false
    //        return switcher
    //    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(partyLabel)
        //        addSubview(activateInterestSwitch)
        
        setupPartyCellLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPartyCellLayout() {
        partyLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        partyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        partyLabel.widthAnchor.constraint(equalToConstant: 96).isActive = true
        partyLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}

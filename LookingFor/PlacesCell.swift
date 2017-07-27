//
//  PlacesCell.swift
//  LookingFor
//
//  Created by Archie Tiu on 19/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

class PlacesCell: UITableViewCell {
    let placesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
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
        
        addSubview(placesLabel)
        //        addSubview(activateInterestSwitch)
        
        setupCellLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellLayout() {
        placesLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        placesLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        placesLabel.widthAnchor.constraint(equalToConstant: 96).isActive = true
        placesLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}

//
//  InterestCell.swift
//  LookingFor
//
//  Created by Archie Tiu on 09/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

typealias InterestCellDidTapSwitchHandler = () -> ()

class InterestCell: UITableViewCell {
    
    let interestLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let activateInterestSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(interestLabel)
        addSubview(activateInterestSwitch)
        
        setupInterestLabelAndSwitch()
        activateInterestSwitch.addTarget(self, action: #selector(didTapSwitch(sender:)), for: .touchUpInside)
    }
    
    func setupInterestLabelAndSwitch() {
        interestLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        interestLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        interestLabel.widthAnchor.constraint(equalToConstant: 96).isActive = true
        interestLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        activateInterestSwitch.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        activateInterestSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activateInterestSwitch.widthAnchor.constraint(equalToConstant: 51)
        activateInterestSwitch.heightAnchor.constraint(equalToConstant: 31)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didTapSwitchHandler: InterestCellDidTapSwitchHandler?
    
    func didTapSwitch(sender: AnyObject) {
        if let handler = didTapSwitchHandler {
            handler()
            if activateInterestSwitch.isOn == true {
                print("UserInterest Switch On!")
            } else {
                print("UserInterest Switch Off!")
            }
        }
    }
    
}

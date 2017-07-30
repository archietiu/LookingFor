//
//  File.swift
//  LookingFor
//
//  Created by Archie Tiu on 13/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import GameKit

struct BackgroundColorProvider {
    let colours = [
        UIColor(red: 90/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0), //teal color
        UIColor(red: 53/255.0, green: 197/255.0, blue: 223/255.0, alpha: 1.0), //teal color
        UIColor(red: 222/255.0, green: 171/255.0, blue: 66/255.0, alpha: 1.0), //yellow color
        UIColor(red: 223/255.0, green: 86/255.0, blue: 94/255.0, alpha: 1.0), //red color
        UIColor(red: 239/255.0, green: 130/255.0, blue: 100/255.0, alpha: 1.0), //orange color
        UIColor(red: 226/255.0, green: 190/255.0, blue: 76/255.0, alpha: 1.0), //gold color
        UIColor(red: 77/255.0, green: 75/255.0, blue: 82/255.0, alpha: 1.0), //dark color
        UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0), //purple color
        UIColor(red: 85/255.0, green: 176/255.0, blue: 112/255.0, alpha: 1.0), //green color
        UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0), //gray color
    ]
    
    let colors = [
        "teal1": UIColor(red: 90/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0), //teal_orig color
        "yellow": UIColor(red: 222/255.0, green: 171/255.0, blue: 66/255.0, alpha: 1.0), //yellow color
        "red": UIColor(red: 223/255.0, green: 86/255.0, blue: 94/255.0, alpha: 1.0), //red color
        "orange": UIColor(red: 239/255.0, green: 130/255.0, blue: 100/255.0, alpha: 1.0), //orange color
        "gold": UIColor(red: 226/255.0, green: 190/255.0, blue: 76/255.0, alpha: 1.0), //gold color
        "dark": UIColor(red: 77/255.0, green: 75/255.0, blue: 82/255.0, alpha: 1.0), //dark color
        "purple": UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0), //purple color
        "green": UIColor(red: 85/255.0, green: 176/255.0, blue: 112/255.0, alpha: 1.0), //green color
        "teal": UIColor(red: 53/255.0, green: 197/255.0, blue: 223/255.0, alpha: 1.0), //teal color
        "gray": UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0), //gray color
    ]
    
    func randomColor() -> UIColor {
        let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: colours.count)
        return colours[randomNumber]
    }
    
}




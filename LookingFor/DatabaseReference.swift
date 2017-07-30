//
//  DatabaseReference.swift
//  LookingFor
//
//  Created by Archie Tiu on 16/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit

//enum ChildReferences: String {
//    case users = "users"
//    case userInterests = "user-interests"
//    case interests = "interests"
//    case interestUsers = "interest-users"
//    case lobbies = "lobbies"
//    case lobbyInterests = "lobby-interests"
//    case interestsLobby = "interest-lobbies"
//    case parties = "parties"
//    case partyLobbies = "party-lobbies"
//    case lobbyParties = "lobby-parties"
//}

let ChildReferences: [String] = [
//    "users",
    "user-interests",
    "interests",
    "interest-users",
    "lobbies",
    "lobby-interests",
    "interest-lobbies",
    "parties",
    "party-lobbies",
    "lobby-parties",
    "party-location",
    "party-users",
    "user-parties",
    "messages",
    "user-messages"
]

struct ServiceKeys {
    static let GMSKey = "AIzaSyBncHgCmouq38Vei7XSYBxbECj_rKX9PuY"
    static let GooglePlacesKey = "AIzaSyDT9HTKyjPwJ-XiA0E6SV-AXQWidThbaOY"
    static let GooglePlacesKey2 = "AIzaSyCbKRgPouFe7jW9K9_Z3kW_136MV64T-TA"
    static let GoogleMapsDistanceMatrixAPIKey = "AIzaSyAGsbYtaZw8I8IdMXWx-kzbCnQ9rSbbj4s"
}

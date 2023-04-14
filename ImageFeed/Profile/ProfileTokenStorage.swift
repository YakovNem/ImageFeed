//
//  ProfileTokenStorage.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 10.03.2023.
//

import Foundation

struct ProfileTokenStorage {
    
    enum Keys: String, CodingKey {
        case token
    }
    
    private var userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            
        }
        set {
            
        }
    }
}

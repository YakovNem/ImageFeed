//
//  OAuthTokenStorage.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 26.02.2023.
//

import Foundation

final class OAuth2TokenStorage {
    
    enum Keys: String, CodingKey {
        case token
    }
    
    private var userDefaults = UserDefaults.standard

    var token: String? {
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}

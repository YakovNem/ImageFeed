//
//  OAuthTokenStorage.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 26.02.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    enum Keys: String, CodingKey {
        case token
    }
    
    var token: String? {
        get {
            
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            KeychainWrapper.standard.set(newValue!, forKey: Keys.token.rawValue)
        }
    }
}

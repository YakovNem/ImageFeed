//
//  OAuthTokenStorage.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 26.02.2023.
//

import Foundation
import SwiftKeychainWrapper
import WebKit

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
    
    static func removeToken () {
        KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
    }
    
    static func clean() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
          }
       }
    }
}

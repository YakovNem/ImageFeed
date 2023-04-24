//
//  Constants.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 22.02.2023.
//

import Foundation

let accessKey = "UAd_VnpWF8YJfMS6Cujbeeq91SCXphHmYXhk-RcFvpE"
let secretKey = "vxdQp1bRH1WLsZNajpvVst0JODRRA7nzfK-0yARJH6s"
let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
let accessScope = "public+read_user+write_likes"

let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let defaultBaseURL: URL = URL(string: "https://api.unsplash.com/")!
let defaultBaseURLString = "https://api.unsplash.com/"
let unsplashAuthorizePostURLString = "https://unsplash.com/oauth/token"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI:String
    let accessScope: String
    let defaultBaseURL: URL
    let defaultBaseURLString: String
    let unsplashAuthorizePostURLString: String
    let unsplashAuthorizeURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, defaultBaseURLString: String, unsplashAuthorizePostURLString: String, unsplashAuthorizeURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.defaultBaseURLString = defaultBaseURLString
        self.unsplashAuthorizePostURLString = unsplashAuthorizePostURLString
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
    }
}

var standard: AuthConfiguration {
    return AuthConfiguration(
        accessKey: accessKey,
        secretKey: secretKey,
        redirectURI: redirectURI,
        accessScope: accessScope,
        defaultBaseURL: defaultBaseURL,
        defaultBaseURLString: defaultBaseURLString,
        unsplashAuthorizePostURLString: unsplashAuthorizePostURLString,
        unsplashAuthorizeURLString: unsplashAuthorizeURLString)
}

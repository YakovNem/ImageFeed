//
//  Constants.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 22.02.2023.
//

import Foundation

enum Constants {
    static let accessKey = "UAd_VnpWF8YJfMS6Cujbeeq91SCXphHmYXhk-RcFvpE"
    static let secretKey = "vxdQp1bRH1WLsZNajpvVst0JODRRA7nzfK-0yARJH6s"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com/")!
    static let defaultBaseURLString = "https://api.unsplash.com/"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizePostURLString = "https://unsplash.com/oauth/token"
}

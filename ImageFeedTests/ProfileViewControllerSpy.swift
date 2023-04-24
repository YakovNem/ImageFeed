//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Yakov Nemychenkov on 22.04.2023.


import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileLabelsCalled = false
    var updateProfileImageCalled = false
    var nameLabel: String = ""
    var loginLabel: String = ""
    var bioLabel: String? = nil
    var imageURL: URL? = nil
    
    func updateProfileLabels(name: String, login: String, bio: String?) {
        updateProfileLabelsCalled = true
        nameLabel = name
        loginLabel = login
        bioLabel = bio
    }
    
    func updateProfileImage(with url: URL) {
        updateProfileImageCalled = true
        imageURL = url
    }
    
    
}

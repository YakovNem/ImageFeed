//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Yakov Nemychenkov on 22.04.2023.
//

import Foundation
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var fetchProfileCalled = false
    var updateAvatarCalled = false
    
    func fetchProfile() {
        fetchProfileCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
}

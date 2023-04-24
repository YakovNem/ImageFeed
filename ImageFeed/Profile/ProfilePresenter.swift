//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 21.04.2023.
//

import Foundation

protocol ProfilePresenterProtocol {
    func fetchProfile()
    func updateAvatar()
    var view: ProfileViewControllerProtocol? { get set }
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let oAuthTokenStorage = OAuth2TokenStorage()
    private let profileImageService = ProfileImageService.shared
    
    init(view: ProfileViewControllerProtocol?) {
        self.view = view
    }
    
    func fetchProfile() {
        guard let token = oAuthTokenStorage.token else { return }
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.view?.updateProfileLabels(name: profile.name, login: profile.login, bio: profile.bio)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL) else { return }
        view?.updateProfileImage(with: url)
    }
}

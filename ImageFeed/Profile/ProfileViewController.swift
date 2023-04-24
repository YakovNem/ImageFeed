//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 04.02.2023.
//
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let oAuthTokenStorage = OAuth2TokenStorage()
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "black")
        view.addSubview(profileImage)
        
        let nameLabel = createNameLabel(whithText: "Екатерина Новикова", font: UIFont.boldSystemFont(ofSize: 23), textColor: .white, backgroundColor: .clear)
        view.addSubview(nameLabel)
        
        let adressLabel = createNameLabel(whithText: "@ekaterina_nov", font: UIFont.systemFont(ofSize: 13), textColor: .gray, backgroundColor: .clear)
        view.addSubview(adressLabel)
        
        let textLabel = createTextLabel(whithText: "Hello, world!", font: UIFont.systemFont(ofSize: 13), textColor: .white, backgroundColor: .clear)
        view.addSubview(textLabel)
        
        let logoutButton = createLogoutButton()
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                                     profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                                     profileImage.heightAnchor.constraint(equalToConstant: 70),
                                     profileImage.widthAnchor.constraint(equalToConstant: 70),
                                     nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                                     nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
                                     nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
                                     adressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                                     adressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                                     adressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                                     textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                                     textLabel.topAnchor.constraint(equalTo: adressLabel.bottomAnchor, constant: 8),
                                     textLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                                     logoutButton.heightAnchor.constraint(equalToConstant: 22),
                                     logoutButton.widthAnchor.constraint(equalToConstant: 20),
                                     logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: profileImage.trailingAnchor),
                                     logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
                                     logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                                     
                                    ])
        
        profileService.fetchProfile(oAuthTokenStorage.token!) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let profile):
                nameLabel.text = profile.name
                adressLabel.text = profile.login
                textLabel.text = profile.bio
            case .failure(let error):
                print(error)
            }
        }
        
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private var profileImage: UIImageView = {
        let profileImage = UIImageView()
        profileImage.image = UIImage(named: "avatarProfile")
        profileImage.backgroundColor = .white
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 35
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        return profileImage
    }()
    
    private func createNameLabel (whithText text: String, font: UIFont, textColor: UIColor, backgroundColor: UIColor) -> UILabel {
        let nameLabel = UILabel()
        nameLabel.text = text
        nameLabel.font = font
        nameLabel.textColor = textColor
        nameLabel.backgroundColor = backgroundColor
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }
    
    private func createAdressLabel (whithText text: String, font: UIFont, textColor: UIColor, backgroundColor: UIColor) -> UILabel {
        let adressLabel = UILabel()
        adressLabel.text = text
        adressLabel.font = font
        adressLabel.textColor = textColor
        adressLabel.backgroundColor = backgroundColor
        adressLabel.translatesAutoresizingMaskIntoConstraints = false
        return adressLabel
    }
    
    private func createTextLabel (whithText text: String, font: UIFont, textColor: UIColor, backgroundColor: UIColor) -> UILabel {
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = font
        textLabel.textColor = textColor
        textLabel.backgroundColor = backgroundColor
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }
    
    private func createLogoutButton() -> UIButton {
        let logoutButton = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!, target: self, action: #selector(self.didTapLogout))
        logoutButton.tintColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        return logoutButton
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL) else { return }
        profileImage.kf.setImage(with: url)
    }
    
    @objc
    private func didTapLogout() {
        alertLogout()
    }
    
    private func logout () {
        OAuth2TokenStorage.clean()
        OAuth2TokenStorage.removeToken()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
    
    private func alertLogout () {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logout()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        present(alert, animated: true)
    }
}


//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 04.02.2023.
//
import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileLabels(name: String, login: String, bio: String?)
    func updateProfileImage(with url: URL)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let textLabel = UILabel()
    private var logoutButton: UIButton!
    
    private let presenter: ProfilePresenterProtocol
    private var profileImageServiceObserver: NSObjectProtocol?
       
       init(presenter: ProfilePresenterProtocol) {
           self.presenter = presenter
           super.init(nibName: nil, bundle: nil)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        presenter.fetchProfile()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.presenter.updateAvatar()
            }
        presenter.updateAvatar()
    }
    
    private func setLayout() {
        view.backgroundColor = UIColor(named: "black")
        
        profileImage.image = UIImage(named: "avatarProfile")
        profileImage.backgroundColor = .white
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 35
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        nameLabel.backgroundColor = .clear
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addressLabel.text = "@ekaterina_nov"
        addressLabel.font = UIFont.systemFont(ofSize: 13)
        addressLabel.textColor = .gray
        addressLabel.backgroundColor = .clear
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.text = "Hello, world!"
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(self.didTapLogout))
        logoutButton.tintColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(addressLabel)
        view.addSubview(textLabel)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                                     profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                                     profileImage.heightAnchor.constraint(equalToConstant: 70),
                                     profileImage.widthAnchor.constraint(equalToConstant: 70),
                                     nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                                     nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
                                     nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
                                     addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                                     addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                                     addressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                                     textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                                     textLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
                                     textLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                                     logoutButton.heightAnchor.constraint(equalToConstant: 22),
                                     logoutButton.widthAnchor.constraint(equalToConstant: 20),
                                     logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: profileImage.trailingAnchor),
                                     logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
                                     logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                                     
                                    ])
    }
    
    func updateProfileLabels(name: String, login: String, bio: String?) {
        nameLabel.text = name
        addressLabel.text = login
        textLabel.text = bio
    }
    
    func updateProfileImage(with url: URL) {
        profileImage.kf.setImage(with: url)
    }
        
    @objc
    private func didTapLogout() {
        alertLogout()
    }
    
    private func logout () {
        WebViewViewController.clean()
        OAuth2TokenStorage.removeToken()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
    
    //MARK: Alert
    public func alertLogout () {
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

//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 04.02.2023.
//
import UIKit
final class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "avatarProfile")
        let profileImageView = UIImageView(image: image)
        profileImageView.backgroundColor = .white
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 35
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        
        
        let adressLabel = UILabel()
        adressLabel.text = "@ekaterina_nov"
        adressLabel.textColor = .gray
        adressLabel.font = UIFont.systemFont(ofSize: 13)
        adressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adressLabel)
        adressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        adressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        adressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        
        let textLabel = UILabel()
        textLabel.text = "Hello, world!"
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: adressLabel.bottomAnchor, constant: 8).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        
        let logoutButton = UIButton.systemButton(with: UIImage(systemName:"ipad.and.arrow.forward")!,
                                                 target: self,
                                                 action: #selector(Self.didTapLogout)
        )
        logoutButton.tintColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: profileImageView.trailingAnchor).isActive = true
        logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        
    }
    @objc
    private func didTapLogout() {
        
    }
}

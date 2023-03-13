//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 01.03.2023.
//


import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarConrtoller()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "black")
        view.addSubview(splashScreenImage)
        
        NSLayoutConstraint.activate([
            splashScreenImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            splashScreenImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
    }
    
    private var splashScreenImage: UIImageView = {
        let splashScreenImage = UIImageView()
        splashScreenImage.image = UIImage(named: "Vector")
        splashScreenImage.backgroundColor = UIColor(named: "black")
        splashScreenImage.translatesAutoresizingMaskIntoConstraints = false
        return splashScreenImage
    }()
    
    private func switchToTabBarConrtoller() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        
        window.rootViewController = tabBarController
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(actionAlert)
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
}
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarConrtoller()
                UIBlockingProgressHUD.dismiss()
            case .failure:
                self.showAlert()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            switch result {
            case .success (let username):
                self.profileImageService.fetchProfileImageURL(username: username.username, token: token) { _ in }
                self.switchToTabBarConrtoller()
            case .failure:
                self.showAlert()
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
    private func fetchProfileImageURL (username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username, token: oauth2TokenStorage.token!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarConrtoller()
            case .failure:
                self.showAlert()
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
}



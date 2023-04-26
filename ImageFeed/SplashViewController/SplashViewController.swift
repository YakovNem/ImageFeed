
//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 01.03.2023.
//


import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let showAuthIdentifier = "ShowAuthIdentifier"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "black")
        view.addSubview(splashScreenImage)
        
        NSLayoutConstraint.activate([
            splashScreenImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            splashScreenImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = oauth2TokenStorage.token else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController else {
                return
            }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            return present(authViewController, animated: true)
        }
        UIBlockingProgressHUD.show()
        fetchProfile(token: token)
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
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
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
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchAuthToken(code) {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.oauth2TokenStorage.token = token
                self.fetchProfile(token: token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token, completion: {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.dismiss(animated: true)
                UIBlockingProgressHUD.dismiss()
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _  in }
                DispatchQueue.main.async {
                    self.switchToTabBarConrtoller()
                }
            case .failure:
                self.showAlert()
                break
            }
            UIBlockingProgressHUD.dismiss()
        })
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthIdentifier)") }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

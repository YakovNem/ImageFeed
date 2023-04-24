//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 24.02.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let showIdentifier = "ShowWebView"
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet private var authorizationButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { return assertionFailure("Failed to prepare for \(showIdentifier)") }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper )
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchAuthToken(code) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let token):
                    self.oAuth2TokenStorage.token = token
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
        
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

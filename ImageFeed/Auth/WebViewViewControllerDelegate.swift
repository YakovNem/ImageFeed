//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 24.02.2023.
//

import Foundation

protocol WebViewViewDelegate: WebViewViewController {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) -> String{
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        
    }
}

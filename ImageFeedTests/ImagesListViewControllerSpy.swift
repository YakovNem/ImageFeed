//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Yakov Nemychenkov on 24.04.2023.
//

import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewCalled: Bool = false
    var showAlertCalled: Bool = false
    var numberOfRows: Int = 0
    
    
    func updateTableView(oldCount: Int, newCount: Int) {
        updateTableViewCalled = true
    }
    
    func showAlert(title: String, message: String) {
        showAlertCalled = true
    }
    
    
}

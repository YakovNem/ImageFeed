//
//  File.swift
//  ImageFeedTests
//
//  Created by Yakov Nemychenkov on 22.04.2023.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTest {
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        let presenter = ProfileViewPresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        let window = UIWindow()
        
        //When
        window.addSubview(viewController.view)
        
        //Then
        XCTAssertTrue(presenter.fetchProfileCalled, "viewDidLoad() should call presenter's fetchProfile()")
        XCTAssertTrue(presenter.updateAvatarCalled, "viewDidLoad() should call presenter's updateAvatar()")
    }
    
    func testViewControllerUpdatesProfileLabels() {
        //Given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewControllerSpy)
        
        //When
        presenter.view?.updateProfileLabels(name: "test name", login: "@testlogin", bio: "test bio")
        
        //Then
        XCTAssertTrue(viewControllerSpy.updateProfileLabelsCalled)
        XCTAssertEqual(viewControllerSpy.nameLabel, "")
        XCTAssertEqual(viewControllerSpy.loginLabel, "")
        XCTAssertEqual(viewControllerSpy.bioLabel, "")
    }
}

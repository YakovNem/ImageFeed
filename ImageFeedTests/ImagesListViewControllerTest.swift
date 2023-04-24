//
//  ImageListViewControllerTest.swift
//  ImageFeedTests
//
//  Created by Yakov Nemychenkov on 24.04.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTest: XCTestCase {
    private var viewController: ImagesListViewController!
    private var viewControllerSpy: ImagesListViewControllerSpy!
    private var presenterSpy: ImagesListPresenterSpy!
    
    override func setUp() {
        super.setUp()
        viewControllerSpy = ImagesListViewControllerSpy()
        presenterSpy = ImagesListPresenterSpy()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        viewController.loadViewIfNeeded()
        viewController.presenter = presenterSpy
    }
    
    override func tearDown() {
        viewController = nil
        viewControllerSpy = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testUpdateTableViewCalled() {
        //Given
        viewControllerSpy.numberOfRows = 10
        let oldCount = 0
        let newCount = 10
        
        //When
        viewControllerSpy.updateTableView(oldCount: oldCount, newCount: newCount)
        
        //Then
        XCTAssertTrue(viewControllerSpy.updateTableViewCalled, "updateTableView() should be called on the view")
    }
    
    func testShowAlertCalled() {
        //Given
        let title = "test"
        let message = "test message"
        
        //When
        viewControllerSpy.showAlert(title: title, message: message)
        
        //Then
        XCTAssertTrue(viewControllerSpy.showAlertCalled, "showAlert() should be called on the view")
    }
    
    func testLoadNextPhotosPageCalled() {
        //When
        presenterSpy.loadNextPhotosPage()
        
        //Then
        XCTAssertTrue(presenterSpy.loadNextPhotosPageCalled, "loadNextPhotosPage() should be called on the presenter")
    }
    
    func testChangeLikeCalled() {
        //Given
        let expectation = self.expectation(description: "ChangeLikeCalled")
        let indexPath = IndexPath(row: 0, section: 0)
        
        //When
        presenterSpy.changeLike(at: indexPath) { _ in
            expectation.fulfill()
        }
        
        //Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(presenterSpy.changeLikeCalled, "changeLike() should be called on the presenter")
    }
}



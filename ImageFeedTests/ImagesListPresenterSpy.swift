//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Yakov Nemychenkov on 24.04.2023.
//

import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var configCellCalled: Bool = false
    var loadNextPhotosPageCalled: Bool = false
    var changeLikeCalled: Bool = false
    
    func configCell(for cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) {
        configCellCalled = true
    }
    
    func loadNextPhotosPage() {
        loadNextPhotosPageCalled = true
    }
    
    func changeLike(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
    
    
}

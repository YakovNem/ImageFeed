//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 22.04.2023.
//

import UIKit
import Kingfisher

protocol ImagesListPresenterProtocol {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func loadNextPhotosPage()
    func changeLike(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private let imagesListService: ImagesListService
    private weak var view: ImagesListViewControllerProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photos] = []
    private var isLoadingPhotos = false
    
    init(imagesListService: ImagesListService, view: ImagesListViewControllerProtocol?) {
        self.imagesListService = imagesListService
        self.view = view
        self.photos = imagesListService.photos
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                let oldCount = self.photos.count
                self.photos = self.imagesListService.photos
                let newCount = self.imagesListService.photos.count
                self.isLoadingPhotos = false
                self.view?.updateTableView(oldCount: oldCount, newCount: newCount)
            }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageURL = photos[indexPath.row].thumbImageURL
        let url = URL(string: imageURL)
        let placeholder = UIImage(named: "Stub")
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: placeholder)
        
        if let createdAt = photos[indexPath.row].createdAt {
            let dateString = dateFormatter.string(from: createdAt)
            cell.dateLabel.text = dateString
        } else {
            cell.dateLabel.text = ""
        }
        
        let isLiked = imagesListService.photos[indexPath.row].isLiked == false
        let likeImage = isLiked ? UIImage(named: "No Active") : UIImage(named: "Active")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.selectionStyle = .none
    }
    
    func loadNextPhotosPage() {
        if !isLoadingPhotos {
            isLoadingPhotos = true
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func changeLike(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            case .success:
                guard let self = self else { return }
                self.photos = self.imagesListService.photos
                completion(.success(()))
                UIBlockingProgressHUD.dismiss()
            case .failure (let error):
                UIBlockingProgressHUD.dismiss()
                completion(.failure(error))
            }
        }
    }
}



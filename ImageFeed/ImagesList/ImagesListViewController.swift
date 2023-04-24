//
//  ViewController.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 27.11.2022.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableView(oldCount: Int, newCount: Int)
    func showAlert(title: String, message: String)
}

class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photos] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var profileImageViewController: ProfileViewController!
    private var imagesListService = ImagesListService()
    var presenter: ImagesListPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profilePresenter = ProfilePresenter(view: profileImageViewController)
        profileImageViewController = ProfileViewController(presenter: profilePresenter)
        
        self.presenter = ImagesListPresenter(imagesListService: imagesListService, view: self)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else { return }
            guard let indexPatch = sender as? IndexPath else { return }
            let photo = photos[indexPatch.row]
            guard let imageURL = URL(string: photo.largeImageURL) else { return }
            viewController.imageUrl = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableView(oldCount: Int, newCount: Int) {
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(actionAlert)
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Extensions
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let  imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        presenter.configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageWidth = CGFloat(photo.size.width)
        let imageHeigth = CGFloat(photo.size.height)
        let aspectRatio = imageWidth / imageHeigth
        let screenWidth = UIScreen.main.bounds.width
        let cellHeight = screenWidth/aspectRatio
        return cellHeight
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            presenter.loadNextPhotosPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.changeLike(at: indexPath) { [weak self] result in
            switch result {
            case .success:
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure:
                self?.showAlert(title: "Что-то пошло не так", message: "Не удалось войти в систему")
            }
        }
    }
}




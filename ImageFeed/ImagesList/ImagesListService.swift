//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 14.03.2023.
//

import UIKit

final class ImagesListService {
    private (set) var photos: [Photos] = []
    private var currentPage: Int = 0
    private let perPage = 10
    private var lastLoadedPege: Int?
    private var task: URLSessionTask?
    private var lastCode: String?
    private var urlSession = URLSession.shared
    private var isLoading: Bool = false
    
    enum NetworkError: Error {
        case codeError
    }
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard !isLoading else { return }
        isLoading = true
        
        fetchPhotos(token: OAuth2TokenStorage().token!, page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map{ photoResults -> Photos in
                    let size = CGSize(width: photoResults.width, height: photoResults.height)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let createdAt = dateFormatter.date(from: photoResults.createdAt)
                    
                    return Photos(
                        id: photoResults.id,
                        size: size,
                        createdAt: createdAt,
                        welcomeDescription: photoResults.description,
                        thumbImageURL: photoResults.urls.thumb,
                        largeImageURL: photoResults.urls.full,
                        isLiked: photoResults.likedByUser)
                }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            case .failure(let error):
                print("Error fetching photos: \(error.localizedDescription)")
            }
            self.isLoading = false
            self.currentPage += 1
        }
    }
    private func fetchPhotos(token: String, page: Int, completion: @escaping (Result<[PhotoResults], Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == token { return }
        task?.cancel()
        lastCode = token
        let request = makeRequestPhotos(page: page, perPage: perPage, token: token)
        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.codeError))
                    return
                }
                
                if let data = data {
                    do {
                        let decode = try JSONDecoder().decode([PhotoResults].self, from: data)
                        completion(.success(decode))
                    } catch {
                        completion(.failure(NetworkError.codeError))
                    }
                }
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = OAuth2TokenStorage().token else {
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let url = URL(string: "\(standard.defaultBaseURLString)/photos/\(photoId)/like")!
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.codeError))
                    return
                }
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photos(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: isLike
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
                completion(.success(()))
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequestPhotos(page: Int, perPage: Int, token: String) -> URLRequest {
        let unsplashPhotosURLString = standard.defaultBaseURLString + "/photos?page=\(page)&&per_page=\(perPage)"
        guard let url = URL(string: unsplashPhotosURLString) else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct Photos {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResults: Codable {
    let id: String
    let createdAt: String
    let width: CGFloat
    let height: CGFloat
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Codable {
    let full: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case full
        case thumb
    }
}

extension Array {
    func withReplaced(itemAt index: Index, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}

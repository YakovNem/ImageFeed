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
    private var lastLoadedPege: Int?
    private var task: URLSessionTask?
    private var lastCode: String?
    private var urlSession = URLSession.shared
    private var isLoading: Bool = false
    
    
    enum NetworkError: Error {
        case codeError
    }
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        
        fetchPhotos(token: OAuth2TokenStorage().token!, page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
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
                            largeImageURL: photoResults.urls.regular,
                            isLiked: photoResults.likedByUser)
                    }
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                case .failure(let error):
                    print("Error fetching photos: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchPhotos(token: String, page: Int, completion: @escaping (Result<[PhotoResults], Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == token { return }
        task?.cancel()
        lastCode = token
        let request = makeRequestPhotos(page: page, token: token)
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
}

private func makeRequestPhotos(page: Int, token: String) -> URLRequest {
    let unsplashPhotosURLString = Constants.defaultBaseURLString + "photos"
    guard let url = URL(string: unsplashPhotosURLString) else { fatalError("Failed to create URL") }
    var requset = URLRequest(url: url)
    requset.httpMethod = "GET"
    requset.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return requset
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
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    
    private enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb
    }
}

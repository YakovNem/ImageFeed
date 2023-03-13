//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 11.03.2023.
//

import Foundation
import Kingfisher
final class ProfileImageService {
    static let shared = ProfileImageService()
    
    private var urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private var lastCode: String?
    
    private(set) var avatarURL: String?
    
    private var profileImage: ProfileImage?
    
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastUsername == username { return }
        if lastCode == token { return }
        task?.cancel()
        lastUsername = username
        lastCode = token
        let request = makeRequestProfileImage(username: username, token: token)
        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.invalidURL))
                    return
                }
                
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(UserResult.self, from: data)
                        guard let profileImageURL = result.profileImage.small else { return }
                        self.avatarURL = profileImageURL
                        completion(.success(profileImageURL))
                        NotificationCenter.default
                            .post(name: ProfileImageService.didChangeNotification,
                                  object: self,
                                  userInfo: ["URL": profileImageURL])
                    } catch {
                        completion(.failure(NetworkError.invalidData))
                    }
                }
                self.task = nil
                if error != nil {
                    self.lastUsername = nil
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequestProfileImage(username: String, token: String) -> URLRequest {
        let unsplashProfileImageURLString = Constants.defaultBaseURLString + "users/" + username
        guard let url = URL(string: unsplashProfileImageURLString) else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    struct ProfileImage: Codable {
        var small: String?
        
        enum CodingKeys: String, CodingKey {
            case small = "small"
        }
    }
    enum NetworkError: Error {
        case invalidURL
        case invalidData
        case decodingError
    }
}


//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 10.03.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private (set) var profile: Profile?
    
    enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == token { return }
        task?.cancel()
        lastCode = token
        let request = makeRequestProfile(token: token)
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
                        let decode = try JSONDecoder().decode(ProfileResult.self, from: data)
                        let profile =
                        Profile.init(username: decode.userName,
                                     name: "\(decode.firstName) \(decode.lastName)",
                                     login: "@\(decode.userName)",
                                     bio: decode.bio)
                        completion(.success(profile))
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
    
    private func makeRequestProfile(token: String) -> URLRequest {
        let unsplashProfileUserURLString = standard.defaultBaseURLString + "me"
        guard let url = URL(string: unsplashProfileUserURLString) else { fatalError("Failed to create URL") }
        var requset = URLRequest(url: url)
        requset.httpMethod = "GET"
        requset.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return requset
    }
}

private struct ProfileResult: Codable {
    let userName: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let login: String
    let bio: String?
}


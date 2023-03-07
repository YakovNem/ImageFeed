//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 26.02.2023.
//

import Foundation

final class OAuth2Service {

    static let shared = OAuth2Service()
    
    enum NetworkError: Error {
        case codeError
    }
    func fetchAuthToken (_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var urlComponents = URLComponents(string: Constants.unsplashAuthorizePostURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
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
                        let decode = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        completion(.success(decode.accessToken))
                    } catch {
                        completion(.failure(NetworkError.codeError))
                    }
                }
            }
        }
        task.resume()
    }
}

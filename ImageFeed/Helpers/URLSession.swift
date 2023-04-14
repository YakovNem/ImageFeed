//
//  URLSession.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 13.03.2023.
//

import Foundation

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(error!))
                    return
                }
                
                if let data = data {
                    do {
                        let decode = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decode))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        return task
    }
}

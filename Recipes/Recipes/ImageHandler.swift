//
//  ImageHandler.swift
//  Recipes
//
//  Created by Sean Acres on 7/8/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case otherError
    case badData
    case noDecode
    case noEncode
    case badResponse
}

struct ImageSearchResult: Codable {
    let items: [ImageResult]
}

struct ImageResult: Codable {
    let link: String
}

class ImageHandler {
    let baseURL = URL(string: "https://www.googleapis.com/customsearch/v1")!
    let searchEngineID = "000780968727558346872:wihzvfqiagc"
    let apiKey = "AIzaSyC6N-NxvomVfOIh3L6IdPrNxqKjiStPqiY"
    var imageSearchResult: ImageSearchResult?
    
    func searchImage(for searchTerm: String, completion: @escaping (Result<UIImage, NetworkError>) -> ()) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        let queryItems = [URLQueryItem(name: "q", value: searchTerm),
                          URLQueryItem(name: "cx", value: searchEngineID),
                          URLQueryItem(name: "key", value: apiKey),
                          URLQueryItem(name: "searchType", value: "image")]
        
        components.queryItems = queryItems
        let request = URLRequest(url: components.url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(.failure(.badResponse))
                return
            }
            
            if error != nil {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                self.imageSearchResult = try jsonDecoder.decode(ImageSearchResult.self, from: data)
                self.fetchImage(at: (self.imageSearchResult?.items.first!.link)!, completion: { (result) in
                    if let image = try? result.get() {
                        completion(.success(image))
                        print("got image")
                    }
                })
            } catch {
                print("error decoding data: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    // image fetch function
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> ()) {
        let imageURL = URL(string: urlString)!
        let request = URLRequest(url: imageURL)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let image = UIImage(data: data)!
            completion(.success(image))
            }.resume()
    }
}

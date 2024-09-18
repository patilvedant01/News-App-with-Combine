//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//


import Foundation
import Combine

struct NewsAPI {
    
    static let shared = NewsAPI()
    private init() {}
    
    private let apiKey = "278d6f845a644104a0c561225243ca90"
    private let session = URLSession.shared
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    // Combine-based fetch for category
    func fetch(from category: Category) -> AnyPublisher<[Article], Error> {
        fetchArticles(from: generateNewsURL(from: category))
    }
    
    // Combine-based search for query
    func search(for query: String) -> AnyPublisher<[Article], Error> {
        fetchArticles(from: generateSearchURL(from: query))
    }
    
    // Helper function for fetching articles using Combine
    private func fetchArticles(from url: URL) -> AnyPublisher<[Article], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw generateError(description: "Bad Response")
                }
                
                switch httpResponse.statusCode {
                case 200...299, 400...499:
                    return data
                default:
                    throw generateError(description: "A server error occurred")
                }
            }
            .decode(type: NewsAPIResponse.self, decoder: jsonDecoder)
            .tryMap { apiResponse in
                if apiResponse.status == "ok" {
                    return apiResponse.articles ?? []
                } else {
                    throw generateError(description: apiResponse.message ?? "An error occurred")
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() // Erase the publisher type for flexibility
    }
    
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "NewsAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    private func generateSearchURL(from query: String) -> URL {
        let percentEncodedString = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        var url = "https://newsapi.org/v2/everything?"
        url += "apiKey=\(apiKey)"
        url += "&language=en"
        url += "&q=\(percentEncodedString)"
        return URL(string: url)!
    }
    
    private func generateNewsURL(from category: Category) -> URL {
        var url = "https://newsapi.org/v2/top-headlines?"
        url += "apiKey=\(apiKey)"
        url += "&language=en"
        url += "&category=\(category.rawValue)"
        return URL(string: url)!
    }
}

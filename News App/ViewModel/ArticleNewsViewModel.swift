//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//

import SwiftUI
import Combine

enum DataFetchPhase<T> {
    case empty
    case success(T)
    case failure(Error)
}

struct FetchTaskToken: Equatable {
    var category: Category
    var token: Date
}

@MainActor
class ArticleNewsViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<[Article]>.empty
    @Published var fetchTaskToken: FetchTaskToken
    
    private let newsAPI = NewsAPI.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(articles: [Article]? = nil, selectedCategory: Category = .general) {
        if let articles = articles {
            self.phase = .success(articles)
        } else {
            self.phase = .empty
        }
        self.fetchTaskToken = FetchTaskToken(category: selectedCategory, token: Date())
    }
    
    // Use Combine to load articles
    func loadArticles() {
        phase = .empty
        
        newsAPI.fetch(from: fetchTaskToken.category)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.phase = .failure(error)
                case .finished:
                    break
                }
            }, receiveValue: { articles in
                self.phase = .success(articles)
            })
            .store(in: &cancellables) // Store the cancellable to prevent premature cancellation
    }
}

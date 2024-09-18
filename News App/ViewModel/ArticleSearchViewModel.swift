//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//


import SwiftUI
import Combine

@MainActor
class ArticleSearchViewModel: ObservableObject {

    @Published var phase: DataFetchPhase<[Article]> = .empty
    @Published var searchQuery = ""
    @Published var history = [String]()
    
    private let historyDataStore = PlistDataStore<[String]>(filename: "histories")
    private let historyMaxLimit = 10
    private let newsAPI = NewsAPI.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var trimmedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static let shared = ArticleSearchViewModel()
    
    private init() {
        load()
    }
    
    func addHistory(_ text: String) {
        if let index = history.firstIndex(where: { text.lowercased() == $0.lowercased() }) {
            history.remove(at: index)
        } else if history.count == historyMaxLimit {
            history.remove(at: history.count - 1)
        }
        
        history.insert(text, at: 0)
        historiesUpdated()
    }
    
    func removeHistory(_ text: String) {
        guard let index = history.firstIndex(where: { text.lowercased() == $0.lowercased() }) else {
            return
        }
        history.remove(at: index)
        historiesUpdated()
    }
    
    func removeAllHistory() {
        history.removeAll()
        historiesUpdated()
    }
    
    // Use Combine to search for articles
    func searchArticle() {
        phase = .empty
        
        newsAPI.search(for: searchQuery)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.phase = .failure(error)
                case .finished:
                    break
                }
            }, receiveValue: { articles in
                self.phase = .success(articles)
                self.addHistory(self.searchQuery)  // Optionally add the query to history after successful search
            })
            .store(in: &cancellables) // Store the cancellable to prevent premature cancellation
    }
    
    private func load() {
        Task {
            self.history = await historyDataStore.load() ?? []
        }
    }
    
    private func historiesUpdated() {
        let history = self.history
        Task {
            await historyDataStore.save(history)
        }
    }
}

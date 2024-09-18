//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//


import SwiftUI

struct SearchTabView: View {
    
    @StateObject var searchVM = ArticleSearchViewModel.shared
    
    var body: some View {
        NavigationView {
            ArticleListView(articles: articles)
                .overlay(overlayView)
                .navigationBarTitleDisplayMode(.inline)
                        .toolbar { // <2>
                            ToolbarItem(placement: .topBarLeading) { // <3>
                                VStack {
                                    Text("Search")
                                        .font(.system(size: 28))
                                        .fontWeight(.bold)
                                }
                                .padding(.leading)
                            }
                        }
        }
        .searchable(text: $searchVM.searchQuery) { suggestionsView }
//        .onChange(of: searchVM.searchQuery) { newValue in
//            if newValue.isEmpty {
//                searchVM.phase = .empty
//            }
//        }
        .onSubmit(of: .search, search)
    }
    
    private var articles: [Article] {
        if case .success(let articles) = searchVM.phase {
            return articles
        } else {
            return []
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch searchVM.phase {
        case .empty:
            if !searchVM.searchQuery.isEmpty {
                ProgressView()
            } else if !searchVM.history.isEmpty {
                SearchHistoryListView(searchVM: searchVM) { newValue in
                    // Need to be handled manually as it doesn't trigger default onSubmit modifier
                    searchVM.searchQuery = newValue
                    search()
                }
            } else {
                EmptyPlaceholderView(text: "Type a topic you want to search for news articles.", image: Image(systemName: "magnifyingglass"))
            }
            
        case .success(let articles) where articles.isEmpty:
            EmptyPlaceholderView(text: "No search results found", image: Image(systemName: "magnifyingglass"))
            
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: search)
            
        default: EmptyView()
            
        }
    }
    
    @ViewBuilder
    private var suggestionsView: some View {
        ForEach(["Swift", "SwiftUI", "PS5", "iOS 17","Football"], id: \.self) { text in
            Button {
                searchVM.searchQuery = text
            } label: {
                Text(text)
            }
        }
    }
    
    private func search() {
        let searchQuery = searchVM.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchQuery.isEmpty {
            // Add the search query to history
            searchVM.addHistory(searchQuery)
            
            // Check if articles are saved in UserDefaults
            if let savedArticles = UserDefaults.standard.loadArticles(for: searchQuery) {
                // If articles are found in UserDefaults, update the view model
                searchVM.phase = .success(savedArticles)
            } else {
                // If no articles are found, fetch from API
                Task {
                    do {
                        let fetchedArticles = try await searchVM.searchArticle()
                        // Save the fetched articles to UserDefaults
                        UserDefaults.standard.saveArticles(articles, for: searchQuery)
                    } catch {
                        searchVM.phase = .failure(error)
                    }
                }
            }
        }
    }

}


struct SearchTabView_Previews: PreviewProvider {
    
    @StateObject static var bookmarkVM = ArticleBookmarkViewModel.shared
    
    static var previews: some View {
        SearchTabView()
            .environmentObject(bookmarkVM)
    }
}

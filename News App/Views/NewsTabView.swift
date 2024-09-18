//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//

import SwiftUI

struct NewsTabView: View {
    
    @StateObject var articleNewsVM = ArticleNewsViewModel()
    @State private var showMenu = false

    var body: some View {
            ZStack(alignment: .leading) {
                NavigationView {
                    ArticleListView(articles: articles)
                        .overlay(overlayView)
                                        .task(id: articleNewsVM.fetchTaskToken, loadTask)
                                        .refreshable(action: refreshTask)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { // <2>
                            ToolbarItem(placement: .topBarTrailing) { // <3>
                                VStack {
                                    Text("\(articleNewsVM.fetchTaskToken.category.text)")
                                        .font(.system(size: 28))
                                        .fontWeight(.bold)
                                }
                                .padding(.leading)
                            }
                        }
                        .navigationBarItems(leading: menu)
                }
                
                if showMenu {
                                SideMenuView(selectedCategory: $articleNewsVM.fetchTaskToken.category, showMenu: $showMenu)
                                    .frame(width: UIScreen.main.bounds.width * 0.5)
                                    .transition(.move(edge: .leading))
                                
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea()
                                    .offset(x: UIScreen.main.bounds.width * 0.5)
                                    .onTapGesture {
                                        withAnimation {
                                            showMenu = false
                                        }
                                    }

                            }
            }

        }
    
    @ViewBuilder
        private var overlayView: some View {
            
            switch articleNewsVM.phase {
            case .empty:
                ProgressView()
            case .success(let articles) where articles.isEmpty:
                EmptyPlaceholderView(text: "No Articles", image: nil)
            case .failure(let error):
                RetryView(text: error.localizedDescription, retryAction: refreshTask)
            default: EmptyView()
            }
        }
    
    private var articles: [Article] {
            if case let .success(articles) = articleNewsVM.phase {
                return articles
            } else {
                return []
            }
        }
    
        private func loadTask() async {
            await articleNewsVM.loadArticles()
        }
    
        private func refreshTask() {
            DispatchQueue.main.async {
                articleNewsVM.fetchTaskToken = FetchTaskToken(category: articleNewsVM.fetchTaskToken.category, token: Date())
            }
        }
    
    private var menu: some View {
        Button(action: {
            withAnimation {
                showMenu.toggle()
            }
        }) {
            Image(systemName: "slider.horizontal.3")
                .imageScale(.large)
                .foregroundColor(.primary)
        }
    }
}

struct NewsTabView_Previews: PreviewProvider {
    
    @StateObject static var articleBookmarkVM = ArticleBookmarkViewModel.shared

    
    static var previews: some View {
        NewsTabView(articleNewsVM: ArticleNewsViewModel(articles: Article.previewData))
            .environmentObject(articleBookmarkVM)
    }
}

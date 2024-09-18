//
//  News_AppApp.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//

import SwiftUI

@main
struct NewsApp: App {
    
    @StateObject var articleBookmarkVM = ArticleBookmarkViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(articleBookmarkVM)
        }
    }
}


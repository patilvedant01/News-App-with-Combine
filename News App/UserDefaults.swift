//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//

import Foundation

extension UserDefaults {
    
    private enum Keys {
        static func articlesKey(for query: String) -> String {
            return "articles_\(query)"
        }
    }
    
    func saveArticles(_ articles: [Article], for query: String) {
            do {
                let data = try JSONEncoder().encode(articles)  // Convert articles to Data
                set(data, forKey: query)  // Save the data for the query key
            } catch {
                print("Unable to encode articles: \(error.localizedDescription)")
            }
        }
    
    func loadArticles(for query: String) -> [Article]? {
            guard let data = data(forKey: query) else {
                return nil  // Return nil if no data exists for the given query
            }
            
            do {
                return try JSONDecoder().decode([Article].self, from: data)  // Decode the data back into articles
            } catch {
                print("Unable to decode articles: \(error.localizedDescription)")
                return nil
            }
        }
}


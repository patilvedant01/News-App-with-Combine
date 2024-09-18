//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//

import Foundation

struct NewsAPIResponse: Decodable {
    
    let status: String
    let totalResults: Int?
    let articles: [Article]?
    
    let code: String?
    let message: String?
    
}

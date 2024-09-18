//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//


import Foundation

enum Category: String, CaseIterable {
    case general
    case business
    case technology
    case entertainment
    case sports
    case science
    case health
    
    var text: String {
        if self == .general {
            return "Top Headlines"
        }
        return rawValue.capitalized
    }
    
    //icons of the categories
    var icon: String {
            switch self {
            case .general: return "globe"
            case .business: return "briefcase"
            case .entertainment: return "film"
            case .health: return "heart"
            case .science: return "flask"
            case .sports: return "sportscourt"
            case .technology: return "desktopcomputer"
            }
        }
}

extension Category: Identifiable {
    var id: Self { self }
}

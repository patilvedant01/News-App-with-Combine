//
//  UserDefaults.swift
//  News App
//
//  Created by Vedant Patil on 28/08/24.
//


import SwiftUI

struct SideMenuView: View {
    @Binding var selectedCategory: Category
    @Binding var showMenu: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading) {
                    Text("Hello")
                        .foregroundColor(.secondary)
                    Text("Vedant Patil")
                        .foregroundColor(.primary)
                        .font(.headline)
                }
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Category.allCases) { category in
                    MenuRow(icon: category.icon, text: category.text, isSelected: selectedCategory == category)
                        .onTapGesture {
                            selectedCategory = category
                            withAnimation {
                                showMenu = false
                            }
                        }
                }
            }
            .padding(.top, 30)
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

struct MenuRow: View {
    var icon: String
    var text: String
    var isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .blue : .primary)
                .frame(width: 24, height: 24)
            Text(text)
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}

#Preview {
    SideMenuView(selectedCategory: .constant(.sports), showMenu: .constant(false))
}

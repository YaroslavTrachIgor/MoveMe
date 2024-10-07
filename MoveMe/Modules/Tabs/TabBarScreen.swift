//
//  TabBarScreen.swift
//  MoveMe
//
//  Created by User on 2024-07-06.
//

import Foundation
import SwiftUI

struct TabBarScreen: View {
    
    @State private var presentCustomCustomReelView: Bool = false
    
    @State private var presentPlusButton: Bool = true
    @State private var tabBarVisible: Bool = true
    
    var body: some View {
        ZStack {
            TabView {
                TemplatesView(tabBarVisible: $tabBarVisible)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Templates")
                    }
                
                HStack {}
                    .tabItem {
                        Image(systemName: "")
                        Text("")
                    }
                
                PhotoLibraryView(tabBarVisible: $tabBarVisible)
                    .tabItem {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Photos")
                    }
            }
            .tint(tabBarForeColor)
            .environment(\.colorScheme, .dark)
            .onAppear {
                presentPlusButton = true
                tabBarVisible = true
            }
            .onChange(of: tabBarVisible) { newValue in
                presentPlusButton = newValue
            }
            
            if presentPlusButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            presentCustomCustomReelView.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 23))
                                .fontWeight(.light)
                                .frame(width: 88, height: 38)
                                .background(tabBarForeColor)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .offset(y: -2)
                        
                        Spacer()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $presentCustomCustomReelView) {
            CustomCustomReelView()
        }
    }
}


struct TabBarVisibilityModifier: ViewModifier {
    @Binding var tabBarVisible: Bool
    let visibility: Visibility
    
    func body(content: Content) -> some View {
        content
            .toolbar(visibility, for: .tabBar)
            .onChange(of: visibility) { newValue in
                tabBarVisible = (newValue == .visible)
            }
    }
}


extension View {
    func customTabBarVisibility(_ visibility: Visibility, tabBarVisible: Binding<Bool>) -> some View {
        self.modifier(TabBarVisibilityModifier(tabBarVisible: tabBarVisible, visibility: visibility))
    }
}

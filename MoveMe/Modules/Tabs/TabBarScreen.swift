//
//  TabBarScreen.swift
//  MoveMe
//
//  Created by User on 2024-07-06.
//

import Foundation
import SwiftUI

struct TabBarScreen: View {
    var body: some View {
        TabView {
            TemplatesView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Templates")
                }
            
            PhotosView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Photos")
                }
        }
        .tint(foreColor)
        .environment(\.colorScheme, .dark)
    }
}

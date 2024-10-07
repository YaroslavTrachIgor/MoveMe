//
//  ContentView.swift
//  MoveMe
//
//  Created by User on 2024-06-29.
//

import SwiftUI
import PhotosUI
import AVFoundation
import AVKit
import FirebaseAuth

let backColor = Color(#colorLiteral(red: 0.02752985433, green: 0.02760775015, blue: 0.08294134587, alpha: 1))
let secondaryBackColor = Color(#colorLiteral(red: 0.05454473197, green: 0.05279297382, blue: 0.1667607129, alpha: 1))

let foreColor = Color(#colorLiteral(red: 0.8614941239, green: 0.3432193995, blue: 0.9051209092, alpha: 1))
let tabBarForeColor = Color(#colorLiteral(red: 0.9535612464, green: 0.6204099059, blue: 0.9816270471, alpha: 1))

struct ContentView: View {
    
    @State private var presentPlusButton = true
    
    var body: some View {
        if ((Auth.auth().currentUser?.isAnonymous) == nil) {
            SplashView()
                .environment(\.colorScheme, .dark)
                .onAppear {
                    Auth.auth().signInAnonymously()
                }
        } else {
            TabBarScreen()
                .environment(\.colorScheme, .dark)
        }
    }
}

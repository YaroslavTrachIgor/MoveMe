//
//  SplashView.swift
//  MoveMe
//
//  Created by User on 2024-07-06.
//

import Foundation
import SwiftUI

struct SplashView: View {
    
    @State private var presentTabsView = false
    
    var body: some View {
        ZStack {
            Image("SplashScreenBack")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            VStack {
                ZStack {
                    Color.white
                        .frame(width: 50, height: 50)
                        .cornerRadius(20)
                    
                    Image("AppIconPicrture")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 3)
                        .frame(width: 60, height: 60)
                        .opacity(0.5)
                }
                .padding(.top, 100)
                
                //Spacer()
                
                Text("Unleash Your \nCreativity in \nEvery Reel")
                    .font(.system(size: 45))
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
                Button {
                    presentTabsView.toggle()
                } label: {
                    Text("Continue")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color(#colorLiteral(red: 0.8614941239, green: 0.3432193995, blue: 0.9051209092, alpha: 1)))
                        .cornerRadius(20)
                        .padding(.top, 40)
                        .padding(.horizontal, 30)
                        .padding(.bottom)
                    
                }

                Text("By clicking Continue, you agree to our Terms & Conditions and Privacy Policy.")
                    .lineSpacing(4)
                    .padding(.horizontal, 34)
                    .foregroundStyle(Color.white.opacity(0.9))
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 100)
            }
        }
        .fullScreenCover(isPresented: $presentTabsView, content: {
            TabBarScreen()
        })
        .navigationBarHidden(true)
    }
}

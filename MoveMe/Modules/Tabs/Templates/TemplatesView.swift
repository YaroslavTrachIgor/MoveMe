//
//  TemplatesView.swift
//  MoveMe
//
//  Created by User on 2024-07-06.
//

import Foundation
import SwiftUI
import Photos
import _AVKit_SwiftUI

struct TemplatesView: View {
    
    @Binding var tabBarVisible: Bool
    
    @State private var presentSubscriptionsCoverView = false
    @State private var presentSettingsView = false
    
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    
                    
                    // Top Section
                    HStack {
                        Image("MoveMeTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 40)
                            .padding(.leading, 16)
                        
                        Spacer()
                        
                        
                        if !isPremium {
                            Button(action: {
                                presentSubscriptionsCoverView.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .padding(.leading, 8)
                                        .padding(.trailing, -10)
                                    Text("PRO")
                                        .fontWeight(.bold)
                                        .padding(8)
                                }
                                .padding(0)
                                .background(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(18)
                                .foregroundColor(.white)
                                .padding(.trailing, 16)
                            }
                        } else {
                            Button(action: {
                                presentSettingsView.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "gearshape")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .padding(.leading, 8)
                                        .foregroundStyle(Color.white)
                                }
                                .padding(.trailing, 16)
                            }
                        }
                    }
                    .padding(.top, 60)
                    
                    // Title
                    HStack {
                        Text("Select template")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                            .padding(.leading)
                        Spacer()
                    }
                    
                    // Image Grid
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            NavigationLink(destination:
                                            TemplateDetailView(template: Template.list[0], tabBarVisible: $tabBarVisible).customTabBarVisibility(.hidden, tabBarVisible: $tabBarVisible)
                            ) {
                                templateImageView(imageName: "Template1", template: Template.list[0])
                                    .overlay(
                                        Text("Try Now")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(8)
                                            .background(Color.purple)
                                            .cornerRadius(8)
                                            .foregroundColor(.white)
                                            .padding([.top, .trailing], 16)
                                            .padding([.bottom], 16),
                                        alignment: .bottomTrailing
                                    )
                            }
                            
                            
                            HStack(spacing: 16) {
                                NavigationLink(destination:
                                                TemplateDetailView(template: Template.list[1], tabBarVisible: $tabBarVisible).customTabBarVisibility(.hidden, tabBarVisible: $tabBarVisible)
                                ) {
                                    templateImageView(imageName: "Template2", template: Template.list[1])
                                }
                                
                                NavigationLink(destination:
                                                TemplateDetailView(template: Template.list[2], tabBarVisible: $tabBarVisible).customTabBarVisibility(.hidden, tabBarVisible: $tabBarVisible)
                                ) {
                                    templateImageView(imageName: "Template3", template: Template.list[2])
                                }
                            }
                            
                            HStack(spacing: 16) {
                                NavigationLink(destination:
                                                TemplateDetailView(template: Template.list[4], tabBarVisible: $tabBarVisible).customTabBarVisibility(.hidden, tabBarVisible: $tabBarVisible)
                                ) {
                                    templateImageView(imageName: "Template5", template: Template.list[4])
                                }
                                
                                NavigationLink(destination:
                                                TemplateDetailView(template: Template.list[3], tabBarVisible: $tabBarVisible).customTabBarVisibility(.hidden, tabBarVisible: $tabBarVisible)
                                ) {
                                    templateImageView(imageName: "Template4", template: Template.list[3])
                                }
                            }
                        }
                    }
                }
            }
            .background(backColor)
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $presentSubscriptionsCoverView, content: {
                SubscritionsCoverView()
            })
            .navigationDestination(isPresented: $presentSettingsView) {
                SettingsView(tabBarVisible: $tabBarVisible)
            }
        }
    }
    
    func templateImageView(imageName: String, template: Template) -> some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 300)
            .frame(width: imageName == "Template1" ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.width / 2 - 16)
            .cornerRadius(16)
            .overlay {
                detailTemplateOverlayView(with: template)
            }
    }
    
    func detailTemplateOverlayView(with template: Template) -> some View {
        VStack {
            Spacer()
            
            HStack {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 2)
                        .padding(.leading, 1)
                    Text("\(template.items)")
                        .foregroundStyle(Color.black)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.trailing, 3)
                        .padding(.leading, -2)
                }
                .frame(width: 44, height: 24)
                .background(Color.white)
                .cornerRadius(8)
                .padding()
                
                Spacer()
            }
        }
    }
}

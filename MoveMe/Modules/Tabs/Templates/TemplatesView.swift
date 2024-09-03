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
    
    @State private var presentSubscriptionsCoerView = false
    @State private var selectedTemplate: Template? = nil
    
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    
    var body: some View {
        NavigationStack {
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
                            presentSubscriptionsCoerView.toggle()
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
                        Image("Template1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .frame(width: UIScreen.main.bounds.width - 32)
                            .cornerRadius(16)
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
                            .onTapGesture {
                                selectedTemplate = Template.list[0]
                            }
                            .overlay {
                                detailTemplateOverlayView(with: Template.list[0])
                            }
                        
                        HStack(spacing: 16) {
                            Image("Template2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    selectedTemplate = Template.list[1]
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[1])
                                }
                            
                            Image("Template3")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    selectedTemplate = Template.list[2]
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[2])
                                }
                        }
                        
                        HStack(spacing: 16) {
                            Image("Template5")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    selectedTemplate = Template.list[4]
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[4])
                                }
                            
                            Image("Template4")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    selectedTemplate = Template.list[3]
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[3])
                                }
                        }
                    }
                }
            }
            .background(backColor)
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
//            .navigationDestination(item: $selectedTemplate) { template in
//                TemplateDetailView(template: template)
//            }
            .fullScreenCover(isPresented: $presentSubscriptionsCoerView, content: {
                SubscritionsCoverView()
            })
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

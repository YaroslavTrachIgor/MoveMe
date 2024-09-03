//
//  AddPhotosView.swift
//  MoveMe
//
//  Created by User on 2024-07-28.
//

import Foundation
import SwiftUI
import Photos
import _AVKit_SwiftUI

struct AddPhotosView: View {
    
    var completion: ((Set<MediaAsset>) -> ())
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var photoLibraryViewModel = PhotoLibraryViewModel()
    
    @State private var selectedCategory: PhotoCategory = .recent
    @State private var selectedAssets: Set<MediaAsset> = []
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "multiply")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.leading, 16)
                            .foregroundStyle(Color.white)
                    }
                    
                    Spacer()
                }
                .padding(.top, 2)
                
                HStack {
                    Text("My Photos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, -8)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(PhotoCategory.allCases, id: \.self) { category in
                            VStack {
                                Text(category.rawValue).tag(category)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(selectedCategory == category ? Color.white : Color.secondary.opacity(0.6))
                                    .padding(9)
                            }
                            .background(selectedCategory == category ? Color.clear : Color.secondary.opacity(0.3))
                            .overlay(content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedCategory == category ? foreColor : Color.clear, lineWidth: 3)
                            })
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation {
                                    selectedCategory = category
                                    selectedAssets = []
                                }
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, -12)
                .onChange(of: selectedCategory) { _ in
                    photoLibraryViewModel.fetchAssets(for: selectedCategory)
                }
                
                ScrollView {
                    if photoLibraryViewModel.assets.isEmpty {
                        Text("No Photos or Videos")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 5) {
                            ForEach(photoLibraryViewModel.assets, id: \.self) { asset in
                                if let image = asset.thumbnail {
                                    ZStack {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 115, height: 115)
                                            .clipped()
                                            .cornerRadius(8)
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedAssets.contains(asset) ? foreColor : Color.clear, lineWidth: selectedAssets.contains(asset) ? 2 : 1)
                                            })
                                        
                                        if asset.type == .video {
                                            Image(systemName: "play.circle")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.5))
                                                .clipShape(Circle())
                                        }
                                        
                                        VStack {
                                            HStack {
                                                Spacer()
                                                
                                                Image(systemName: "checkmark")
                                                    .padding(.all, 6)
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(selectedAssets.contains(asset) ? Color.white : Color.clear)
                                                    .background(selectedAssets.contains(asset) ? foreColor : Color.clear)
                                                    .cornerRadius(6)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(selectedAssets.contains(asset) ? foreColor : Color.clear, lineWidth: selectedAssets.contains(asset) ? 2 : 1)
                                                    }
                                                    .padding(.all, 8)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            if selectedAssets.contains(asset) {
                                                selectedAssets.remove(asset)
                                            } else {
                                                selectedAssets.insert(asset)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .onAppear {
                    photoLibraryViewModel.requestPhotoLibraryAccess(for: selectedCategory)
                }
                .sheet(isPresented: $photoLibraryViewModel.isPresentingVideoPlayer) {
                    if let player = photoLibraryViewModel.videoPlayer {
                        VideoPlayer(player: player)
                            .onDisappear {
                                photoLibraryViewModel.videoPlayer = nil
                            }
                    }
                }
                .padding(.top, -4)
            }
            
            
            VStack {
                Spacer()
                
                ZStack {
                    BlurView(style: .dark)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, -34)
                        .overlay {
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                .padding(.bottom, -80)
                                .padding(.horizontal, -34)
                                .ignoresSafeArea(.all)
                        }
                    
                    Button(action: {
                        completion(selectedAssets)
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(foreColor)
                            .cornerRadius(18)
                            .shadow(color: foreColor.opacity(0.2), radius: 10)
                    })
                    .padding(.all, 12)
                }
                .ignoresSafeArea(.all)
            }
        }
        .background(backColor)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

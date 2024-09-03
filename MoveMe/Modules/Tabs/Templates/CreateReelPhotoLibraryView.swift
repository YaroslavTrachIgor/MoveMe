//
//  CreateReelPhotoLibraryView.swift
//  MoveMe
//
//  Created by User on 2024-07-10.
//

import Foundation
import SwiftUI
import Photos
import _AVKit_SwiftUI

struct CreateReelPhotoLibraryView: View {
    
    @State var template: Template
    
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    
    @StateObject private var photoLibraryViewModel = PhotoLibraryViewModel()
    
    @State private var presentSubscritionsCoverView = false
    
    @State private var isCropping = false
    @State private var croppingProgress: Double = 0
    
    @State private var selectedCategory: PhotoCategory = .recent
    @State private var selectedAssets: [MediaAsset] = []
    @State private var croppedAssets: [MediaAsset] = []
    
    @State private var presentVideoEditingView: Bool = false
    
    @State private var generatedVideoURL: URL?
    
    var isCorrectNumberOfAssetsSelected: Bool {
        selectedAssets.count == template.slides.count
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.leading, 16)
                            .foregroundStyle(Color.white)
                    }
                    
                    Spacer()
                    
                    if !isPremium {
                        Button(action: {
                            presentSubscritionsCoverView.toggle()
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
                .padding(.top, 2)
                
                HStack {
                    
                    
                    Text("My Photos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                        .padding(.leading)
                    
                    Spacer()
                    
                    
                    Text("\(selectedAssets.count)/\(template.slides.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(#colorLiteral(red: 0.9535612464, green: 0.6204099059, blue: 0.9816270471, alpha: 1)))
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    
                    
                }
                .padding(.bottom, -8)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(PhotoCategory.allCases, id: \.self) { category in
                            VStack {
                                Text(category.rawValue).tag(category)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(selectedCategory == category ? Color.white : Color.secondary.opacity(0.3))
                                    .padding(9)
                            }
                            .background(selectedCategory == category ? Color.clear : Color.secondary.opacity(0.1))
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
                .onChange(of: selectedCategory) {
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
                                            if selectedAssets.contains(where: { $0.id == asset.id }) {
                                                selectedAssets.removeAll { $0.id == asset.id }
                                            } else {
                                                selectedAssets.append(asset)
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
                .padding(.bottom, 78)
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
                        prepareAssetsForEditing()
                    }, label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(!isCorrectNumberOfAssetsSelected ? Color(.systemGray3) : Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(!isCorrectNumberOfAssetsSelected ? Color(.systemGray) : foreColor)
                            .cornerRadius(18)
                            .shadow(color: !isCorrectNumberOfAssetsSelected ? Color.clear : foreColor.opacity(0.2), radius: 10)
                    })
                    .disabled(!isCorrectNumberOfAssetsSelected)
                    .padding(.all, 12)
                    
                    
                }
                .ignoresSafeArea(.all)
                
            }
            
            
            
            
            if isCropping {
                backColor.opacity(0.5)
                
                BlurView(style: .dark)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView("", value: croppingProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing))
                        .padding()
                        .padding(.horizontal)
                        .padding(.bottom, -30)
                    
                    Text("\(Int(croppingProgress * 100))%")
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.3))
                        .padding()
                        .padding(.bottom)
                }
            }
            
            
            
            
            
        }
        .fullScreenCover(isPresented: $presentSubscritionsCoverView) {
            SubscritionsCoverView()
        }
        .navigationDestination(isPresented: $presentVideoEditingView, destination: {
            VideoEditingView(selectedAssetsArray: selectedAssets, template: template)
        })
        .background(backColor)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func prepareAssetsForEditing() {
        for (index, asset) in selectedAssets.enumerated() {
            if index < template.slides.count {
                template.slides[index].isVideo = asset.type == .video
            }
        }
        
        // Crop videos if necessary
        let videoAssets = selectedAssets.filter { $0.type == .video }
        if !videoAssets.isEmpty {
            cropSelectedVideos {
                presentVideoEditingView.toggle()
            }
        } else {
            presentVideoEditingView.toggle()
        }
    }
    
    func cropSelectedVideos(completion: @escaping () -> Void) {
        if template.slides.count == Template.list[4].slides.count {
            let tempSelectedAssets = selectedAssets
            for asset in tempSelectedAssets {
                var tempAsset = asset
                tempAsset.id = UUID()
                selectedAssets.append(tempAsset)
            }
        }
        
        let videoAssets = selectedAssets.filter { $0.type == .video }
        let videoSlides = template.slides.filter { $0.isVideo }
        
        withAnimation {
            isCropping = true
            croppingProgress = 0
        }
        
        let group = DispatchGroup()
        croppedAssets = [] // Clear the array before populating
        
        for (index, asset) in videoAssets.enumerated() {
            group.enter()
            VideoRenderingManager.shared.cropVideo(asset: asset, slide: videoSlides[index]) { result in
                switch result {
                case .success(let croppedAsset):
                    DispatchQueue.main.async {
                        self.croppedAssets.append(croppedAsset)
                        withAnimation {
                            self.croppingProgress = Double(self.croppedAssets.count) / Double(videoAssets.count)
                        }
                    }
                case .failure(let error):
                    print("Error cropping video: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.croppedAssets.sort { (asset1, asset2) -> Bool in
                guard let index1 = videoAssets.firstIndex(where: { $0.id == asset1.id }),
                      let index2 = videoAssets.firstIndex(where: { $0.id == asset2.id }) else {
                    return false
                }
                return index1 < index2
            }
            withAnimation {
                self.isCropping = false
            }
            completion()
        }
    }
    
    func orderAssetsAccordingToSlides() -> [MediaAsset] {
        var orderedAssets: [MediaAsset] = []
        var photoIndex = 0
        var videoIndex = 0
        
        print(croppedAssets.count)
        
        // Create ordered arrays of video and photo assets
        let orderedSelectedAssets = Array(selectedAssets)
        let orderedVideoAssets = orderedSelectedAssets.filter { $0.type == .video }
        let orderedPhotoAssets = orderedSelectedAssets.filter { $0.type == .photo }
        
        for slide in template.slides {
            if slide.isVideo {
                if !croppedAssets.isEmpty {
                    orderedAssets.append(croppedAssets[videoIndex])
                    videoIndex += 1
                }
            } else {
                if !orderedPhotoAssets.isEmpty {
                    orderedAssets.append(orderedPhotoAssets[photoIndex])
                    photoIndex += 1
                }
            }
        }
        
        return orderedAssets
    }
}


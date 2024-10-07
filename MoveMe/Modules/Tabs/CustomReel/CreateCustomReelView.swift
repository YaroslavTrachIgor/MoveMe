//
//  CreateCustomReelView.swift
//  MoveMe
//
//  Created by User on 2024-10-07.
//

import Foundation
import SwiftUI
import Photos

struct CustomCustomReelView: View {
    
    @State private var template: Template
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    @StateObject private var photoLibraryViewModel = PhotoLibraryViewModel()
    
    @State private var presentSubscritionsCoverView = false
    @State private var selectedCategory: PhotoCategory = .recent
    @State private var selectedAssets: [MediaAsset] = []
    @State private var isLoadingFullSizeImages = false
    @State private var loadingProgress: Double = 0
    
    @State private var presentVideoEditingView: Bool = false
    
    let maxAssets = 20
    let defaultSlideDuration: Double = 2.0
    
    var isCorrectNumberOfAssetsSelected: Bool {
        return selectedAssets.count > 0 && selectedAssets.count <= maxAssets
    }
    
    init() {
        _template = State(initialValue: Template(
            id: UUID(),
            name: "Custom Template",
            iconName: "photo.stack",
            items: 0,
            duration: 0,
            example: nil,
            slides: [],
            defaultAudioPath: nil
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Header
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
                    
                    // Title and asset count
                    HStack {
                        Text("My Photos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Text("\(selectedAssets.count)/\(maxAssets)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(#colorLiteral(red: 0.9535612464, green: 0.6204099059, blue: 0.9816270471, alpha: 1)))
                            .padding(.trailing, 16)
                            .padding(.top, 16)
                    }
                    .padding(.bottom, -8)
                    
                    // Category selection
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
                    .onChange(of: selectedCategory) { newValue in
                        photoLibraryViewModel.fetchAssets(for: selectedCategory)
                    }
                    
                    // Photo grid
                    ScrollView {
                        if photoLibraryViewModel.assets.isEmpty {
                            Text("No Photos or Videos")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            let columns = [
                                GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 5),
                                GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 5),
                                GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 5)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 5) {
                                ForEach(photoLibraryViewModel.assets, id: \.self) { asset in
                                    if let image = asset.thumbnail {
                                        AssetThumbnailView(asset: asset, image: image, isSelected: selectedAssets.contains(asset))
                                            .onTapGesture {
                                                withAnimation {
                                                    if selectedAssets.contains(where: { $0.id == asset.id }) {
                                                        selectedAssets.removeAll { $0.id == asset.id }
                                                    } else if selectedAssets.count < maxAssets {
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
                    .padding(.top, -4)
                    .padding(.bottom, 78)
                }
                
                // Continue button
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
                            loadFullSizeImagesAndPrepareAssets()
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
                
                // Loading overlay
                if isLoadingFullSizeImages {
                    LoadingOverlay(progress: $loadingProgress)
                }
            }
            .fullScreenCover(isPresented: $presentSubscritionsCoverView) {
                SubscritionsCoverView()
            }
            .navigationDestination(isPresented: $presentVideoEditingView, destination: {
                VideoEditingView(selectedAssetsArray: selectedAssets, template: template)
            })
            .onDisappear(perform: {
                self.selectedAssets = []
            })
            .background(backColor)
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .preferredColorScheme(.dark)
            .tint(tabBarForeColor)
        }
    }
    
    func loadFullSizeImagesAndPrepareAssets() {
        isLoadingFullSizeImages = true
        loadingProgress = 0
        
        let totalAssets = Double(selectedAssets.count)
        var loadedAssets = 0
        
        let group = DispatchGroup()
        
        for asset in selectedAssets {
            group.enter()
            
            if asset.type == .photo {
                photoLibraryViewModel.loadFullSizeImage(for: asset) { fullSizeImage in
                    DispatchQueue.main.async {
                        if let fullSizeImage = fullSizeImage {
                            asset.fullSizeImage = fullSizeImage
                        }
                        loadedAssets += 1
                        self.loadingProgress = Double(loadedAssets) / totalAssets
                        group.leave()
                    }
                }
            } else {
                loadedAssets += 1
                self.loadingProgress = Double(loadedAssets) / totalAssets
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoadingFullSizeImages = false
            self.selectedAssets = self.selectedAssets
            self.prepareAssetsForEditing()
        }
    }
    
    func prepareAssetsForEditing() {
        template.slides = selectedAssets.map { asset in
            Slide(id: UUID(), duration: defaultSlideDuration, isHDApplied: false, isVideo: asset.type == .video)
        }
        template.duration = Double(selectedAssets.count) * defaultSlideDuration
        presentVideoEditingView.toggle()
    }
}

struct AssetThumbnailView: View {
    let asset: MediaAsset
    let image: UIImage
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 100, maxWidth: 200, minHeight: 100, maxHeight: 200)
                .clipped()
                .cornerRadius(8)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? foreColor : Color.clear, lineWidth: isSelected ? 2 : 1)
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
                        .foregroundStyle(isSelected ? Color.white : Color.clear)
                        .background(isSelected ? foreColor : Color.clear)
                        .cornerRadius(6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? foreColor : Color.clear, lineWidth: isSelected ? 2 : 1)
                        }
                        .padding(.all, 8)
                }
                Spacer()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct LoadingOverlay: View {
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            BlurView(style: .dark)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView("", value: progress, total: 1.0)
                    .tint(tabBarForeColor)
                    .progressViewStyle(LinearProgressViewStyle())
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing))
                    .padding()
                    .padding(.horizontal)
                    .padding(.bottom, -30)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.3))
                    .padding()
                    .padding(.bottom)
            }
        }
    }
}

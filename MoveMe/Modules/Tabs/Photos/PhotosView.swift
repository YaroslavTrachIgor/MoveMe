//
//  PhotosView.swift
//  MoveMe
//
//  Created by User on 2024-07-06.
//

import Foundation
import SwiftUI
import Photos
import _AVKit_SwiftUI

struct PhotosView: View {
    var body: some View {
        PhotoLibraryView()
    }
    
}

#Preview(body: {
    PhotosView()
})

struct PhotoLibraryView: View {
    
    @StateObject private var photoLibraryViewModel = PhotoLibraryViewModel()
    
    @State private var presentSelectTemplateView = false
    @State private var presentSubscritionsCoverView = false
    
    @State private var selectedCategory: PhotoCategory = .recent
    @State private var selectedAssets: Set<MediaAsset> = []
    
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Image("MoveMeTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 40)
                            .padding(.leading, 16)
                        
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
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, -96)
                            .overlay {
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    .padding(.bottom, -80)
                                    .padding(.horizontal, -34)
                                    .ignoresSafeArea(.all)
                            }
                        
                        Button(action: {
                            presentSelectTemplateView.toggle()
                        }, label: {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(selectedAssets.count < 2 ? Color(.systemGray3) : Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(selectedAssets.count < 2 ? Color(.systemGray) : foreColor)
                                .cornerRadius(18)
                                .shadow(color: selectedAssets.count < 2 ? Color.clear : foreColor.opacity(0.2), radius: 10)
                        })
                        .disabled(selectedAssets.count < 2)
                        .padding(.all, 12)
                        .padding(.bottom, -4)
                    }
                    .ignoresSafeArea(.all)
                }
            }
            .background(backColor)
            .navigationBarHidden(true)
            .onDisappear {
                selectedAssets = []
            }
            .navigationDestination(isPresented: $presentSelectTemplateView) {
                SelectTemplateView(selectedAssets: Array(selectedAssets))
            }
            .fullScreenCover(isPresented: $presentSubscritionsCoverView) {
                SubscritionsCoverView()
            }
        }
    }
}


enum PhotoCategory: String, CaseIterable {
    case recent = "Recent"
    case screenshots = "Screenshots"
    case favorites = "Favorites"
}

class PhotoLibraryViewModel: ObservableObject {
    
    @Published var assets: [MediaAsset] = []
    @Published var videoPlayer: AVPlayer?
    @Published var isPresentingVideoPlayer = false
    
    private var fetchResult: PHFetchResult<PHAsset>?
    
    func requestPhotoLibraryAccess(for category: PhotoCategory) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.fetchAssets(for: category)
                }
            }
        }
    }
    
    func fetchAssets(for category: PhotoCategory) {
        assets.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 400
        
        switch category {
        case .recent:
            break // Fetch all assets (default behavior)
        case .screenshots:
            fetchOptions.predicate = NSPredicate(format: "mediaSubtypes == %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
        case .favorites:
            fetchOptions.predicate = NSPredicate(format: "isFavorite == YES")
        }
        
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        guard let fetchResult = fetchResult else { return }
        
        assets = (0..<fetchResult.count).map { _ in MediaAsset(thumbnail: UIImage()) }
        
        fetchResult.enumerateObjects { (asset, index, stop) in
            if asset.mediaType == .video {
                MediaAsset.createVideoAsset(from: asset) { [weak self] mediaAsset in
                    self?.updateAsset(mediaAsset, at: index)
                }
            } else {
                let mediaAsset = MediaAsset(asset: asset)
                self.updateAsset(mediaAsset, at: index)
            }
        }
    }
    
    private func updateAsset(_ mediaAsset: MediaAsset, at index: Int) {
        DispatchQueue.main.async {
            if index < self.assets.count {
                self.assets[index] = mediaAsset
            }
            
            self.loadThumbnail(for: mediaAsset, at: index)
            
            if mediaAsset.type == .photo {
                self.loadFullSizeImage(for: mediaAsset, at: index)
            }
        }
    }
    
    private func loadThumbnail(for mediaAsset: MediaAsset, at index: Int) {
        guard let asset = mediaAsset.asset else { return }
        
        let imageManager = PHImageManager.default()
        let thumbnailOptions = PHImageRequestOptions()
        thumbnailOptions.deliveryMode = .opportunistic
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: thumbnailOptions) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    self?.assets[index].thumbnail = image
                } else if asset.mediaType == .video {
                    self?.generateVideoThumbnail(for: asset) { thumbnail in
                        DispatchQueue.main.async {
                            self?.assets[index].thumbnail = thumbnail
                        }
                    }
                }
            }
        }
    }
    
    private func loadFullSizeImage(for mediaAsset: MediaAsset, at index: Int) {
        guard let asset = mediaAsset.asset else { return }
        
        let imageManager = PHImageManager.default()
        let fullSizeOptions = PHImageRequestOptions()
        fullSizeOptions.deliveryMode = .highQualityFormat
        fullSizeOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: fullSizeOptions) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    self?.assets[index].fullSizeImage = image
                }
            }
        }
    }
    
    func generateVideoThumbnail(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHVideoRequestOptions()
        options.version = .current
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            guard let avAsset = avAsset else {
                completion(nil)
                return
            }
            
            let imageGenerator = AVAssetImageGenerator(asset: avAsset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                completion(thumbnail)
            } catch {
                completion(nil)
            }
        }
    }
    
    func playVideo(asset: MediaAsset) {
        guard let asset = asset.asset else { return }
        
        let options = PHVideoRequestOptions()
        options.version = .current
        
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { playerItem, _ in
            DispatchQueue.main.async {
                if let playerItem = playerItem {
                    self.videoPlayer = AVPlayer(playerItem: playerItem)
                    self.isPresentingVideoPlayer = true
                    self.videoPlayer?.play()
                }
            }
        }
    }
}

struct MediaAsset: Identifiable, Hashable {
    var id = UUID()
    let asset: PHAsset?
    var thumbnail: UIImage? = nil
    var type: MediaType
    var fullSizeImage: UIImage?
    var videoAsset: AVAsset?
    
    init(asset: PHAsset) {
        self.asset = asset
        self.type = asset.mediaType == .image ? .photo : .video
    }
    
    init(thumbnail: UIImage) {
        self.asset = nil
        self.type = .photo
    }
    
    static func createVideoAsset(from asset: PHAsset, completion: @escaping (MediaAsset) -> Void) {
        var mediaAsset = MediaAsset(asset: asset)
        if mediaAsset.type == .video {
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
                mediaAsset.videoAsset = avAsset
                completion(mediaAsset)
            }
        } else {
            completion(mediaAsset)
        }
    }
    
    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Conforming to Equatable (required for Hashable)
    static func == (lhs: MediaAsset, rhs: MediaAsset) -> Bool {
        lhs.id == rhs.id
    }
}

enum MediaType {
    case photo
    case video
}

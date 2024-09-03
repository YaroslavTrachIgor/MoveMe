//
//  VideoEditingView.swift
//  MoveMe
//
//  Created by User on 2024-07-17.
//

import Foundation
import SwiftUI
import Photos
import _AVKit_SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct VideoEditingView: View {
    
    @State private var selectedAssets: Set<MediaAsset> = []
    
    @State var selectedAssetsArray: [MediaAsset]
    
    @State private var selectedAsset: MediaAsset? = nil
    @State private var videoPlayer: AVPlayer?
    @State private var isRendering: Bool = false
    @State private var renderProgress: Double = 0.0
    
    @State var template: Template
    
    @State private var isCutting = false
    @State private var selectedCuttingAsset: MediaAsset? = nil
    
    @State private var presentAddPhotosView = false
    @State private var presentSaveVideoView = false
    @State private var presentMusicLibraryView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isRenderingVideo = false
    @State private var renderedVideoURL: URL?
    @State private var showVideoPlayer = false
    @State private var tempURLs: [URL] = []
    
    @State private var audioURL: URL?
    @State private var audioName: String?
    @State private var audioStartTime: Double = 0.0
    @State private var audioEndTime: Double = 0.0
    
    var body: some View {
        ZStack {
            VStack {
                
                
                videoPreview
                
                
                    VStack {
                        
                        
                        if !isCutting {
                            HStack {
                                if let firstAsset = selectedAssetsArray.first {
                                    Image(systemName: "arrow.uturn.backward")
                                        .fontWeight(.semibold)
                                        .foregroundColor(firstAsset == selectedAsset ? Color.gray : Color.white)
                                        .padding(.leading, 16)
                                        .padding(.trailing, 8)
                                        .onTapGesture {
                                            jumpToPreviousAsset()
                                        }
                                        .disabled(firstAsset == selectedAsset)
                                }
                                
                                if let lastAsset = selectedAssetsArray.last {
                                    Image(systemName: "arrow.uturn.right")
                                        .fontWeight(.semibold)
                                        .foregroundColor(lastAsset == selectedAsset ? Color.gray : Color.white)
                                        .padding(.leading, 2)
                                        .onTapGesture {
                                            jumpToNextAsset()
                                        }
                                        .disabled(lastAsset == selectedAsset)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "play.fill")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.white)
                                    .padding(.leading, -48)
                                    .onTapGesture {
                                        renderAndPlayVideo()
                                    }
                                
                                Spacer()
                            }
                            .padding(.bottom, -20)
                            .padding(.top)
                        }
                    
                        
                        
                        
                        
                        
                    
                    
                    if isCutting {
                        VStack {
                            if isCutting, let selectedAsset = selectedAsset, let index = selectedAssetsArray.firstIndex(of: selectedAsset) {
                                DurationEditView(selectedAssetsArray: $selectedAssetsArray, selectedAsset: $selectedAsset, duration: Binding(
                                    get: { self.template.slides[index].duration },
                                    set: { self.template.slides[index].duration = $0 }
                                ),
                                                 asset: selectedAsset, template: template, isEditingDuration: $isCutting)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 16)
                                .transition(.opacity)
                                .zIndex(1)
                            }
                        }
                    } else {
                        HStack {
                            VStack {
                                HStack {
                                    Image(systemName: "plus")
                                        .fontWeight(.bold)
                                }
                                .padding(7)
                                .background(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(.trailing, 45)
                                .padding(.leading, 16)
                                .padding(.bottom, -85)
                                .onTapGesture {
                                    presentAddPhotosView.toggle()
                                }
                            }
                            
                            assetSelectionView
                        }
                    }
                    
                    
                    
                        
                    
                    if !isCutting {
                        HStack {}
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
                            .background(Color.indigo.opacity(0.85))
                            .padding(.horizontal, -6)
                            .padding(.top, -10)
                    }
                    
                        
                        
                        
                        
                    HStack(spacing: 12) {
                        footerButton(title: "Cut", icon: "scissors", foregroundColor: isCutting ? foreColor : .white) {
                            withAnimation(.bouncy) {
                                isCutting.toggle()
                            }
                        }
                        
                        if let selectedAsset = selectedAsset, template.slides[selectedAssetsArray.firstIndex(of: selectedAsset) ?? 0].isHDApplied {
                            footerButton(title: "HD Filter", icon: "sparkles", foregroundColor: foreColor) {
                                applyHDSelectedSlide()
                            }
                        } else {
                            footerButton(title: "HD Filter", icon: "sparkles", foregroundColor: .white) {
                                applyHDSelectedSlide()
                            }
                        }
                        
                        footerButton(title: "Music", icon: "music.note") {
                            presentMusicLibraryView.toggle()
                        }
                        
                        footerButton(title: "Delete", icon: "trash.fill") {
                            deleteSelectedSlide()
                            
                            print(template.slides.count)
                            print(selectedAssetsArray.count)
                        }
                        .disabled(selectedAssets.count == 1 || template.slides.count == 1)
                        .opacity(selectedAssets.count == 1 || template.slides.count == 1 ? 0.4 : 1)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .padding(.horizontal, 16)
                    .padding(.bottom, isCutting ? 52 : 0)
                    .padding(.top, isCutting ? 8 : 0)
                    .padding(.bottom, (audioURL != nil ? -50 : 0))
                        
                        
                        
                        
                        
                        
                        
                }
                .frame(height: 250)
                .padding(.bottom, 0)
            }
            .background(backColor.edgesIgnoringSafeArea(.all))
            
            
            
            VStack {
                headerView
                Spacer()
            }
            
            
            
            if isRenderingVideo {
                renderVideoView
            }
            
            
            
        }
        .background(backColor.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $presentAddPhotosView, content: {
            AddPhotosView { addedPhotos in
                addAssets(assets: addedPhotos)
            }
        })
        .fullScreenCover(isPresented: $showVideoPlayer) {
            if let url = renderedVideoURL {
                VideoPlayerView(videoURL: url) {
                    deleteRenderedVideo()
                }
            }
        }
        .onAppear {
            selectedAssets = Set(selectedAssetsArray)
            selectedAsset = selectedAssetsArray[0]
        }
        .onChange(of: selectedAssetsArray, perform: { newValue in
            selectedAssets = Set(selectedAssetsArray)
        })
        .navigationDestination(isPresented: $presentSaveVideoView) {
            SaveVideoView(audioURL: audioURL, selectedAssets: selectedAssetsArray, template: template)
        }
        .navigationDestination(isPresented: $presentMusicLibraryView) {
            MusicLibraryView { url, startTime, endTime, audioName in
                self.audioURL = url
                self.audioStartTime = startTime
                self.audioEndTime = endTime
                self.audioName = audioName
            }
        }
    }
    
    private func addAssets(assets: Set<MediaAsset>) {
        let addedAssets = Array(assets)
        for asset in addedAssets.reversed() {
            selectedAssetsArray.insert(asset, at: 0)
        }
        for asset in addedAssets {
            template.slides.insert(Slide(id: UUID(), duration: 2, isHDApplied: false, isVideo: asset.type == .video ? true : false), at: 0)
        }
    }
    
    private func jumpToPreviousAsset() {
        guard let selectedAsset = selectedAsset else { return }
        if let currentIndex = selectedAssetsArray.firstIndex(of: selectedAsset) {
            let previousIndex = selectedAssetsArray.index(before: currentIndex)
            if previousIndex >= selectedAssetsArray.startIndex {
                self.selectedAsset = selectedAssetsArray[previousIndex]
            }
        }
    }

    private func jumpToNextAsset() {
        guard let selectedAsset = selectedAsset else { return }
        if let currentIndex = selectedAssetsArray.firstIndex(of: selectedAsset) {
            let nextIndex = selectedAssetsArray.index(after: currentIndex)
            if nextIndex < selectedAssetsArray.endIndex {
                self.selectedAsset = selectedAssetsArray[nextIndex]
            }
        }
    }
    
    private func applyHDSelectedSlide() {
        guard let selectedAsset = selectedAsset else { return }
        if let index = selectedAssetsArray.firstIndex(of: selectedAsset) {
            template.slides[index].isHDApplied.toggle()
        }
    }
    
    private func deleteSelectedSlide() {
        guard let selectedAsset = selectedAsset else { return }
        if let assetIndex = selectedAssetsArray.firstIndex(where: { $0.id == selectedAsset.id }) {
            withAnimation(.bouncy) {
                selectedAssetsArray.remove(at: assetIndex)
                if assetIndex < template.slides.count {
                    template.slides.remove(at: assetIndex)
                }
                
                self.selectedAsset = selectedAssetsArray.first
            }
        }
    }
    
    private func footerButton(title: String, icon: String, foregroundColor: Color = .white, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            VStack {
                Image(systemName: icon)
                    .font(.title3)
                    .bold()
                Text(title)
                    .padding(.top, 6)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color(#colorLiteral(red: 0.1568616629, green: 0.1568636, blue: 0.1952569187, alpha: 1)))
            .cornerRadius(12)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button {
                selectedAssets = []
                selectedAssetsArray = []
                presentationMode.wrappedValue.dismiss()
            } label: {
                ZStack {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(8)
                }
                .frame(width: 35, height: 35)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
                .padding(.leading, 16)
            }
            
            Spacer()
            
            Button(action: {
                selectedAssets = Set(selectedAssetsArray)
                presentSaveVideoView.toggle()
            }) {
                HStack {
                    Text("Save")
                        .fontWeight(.medium)
                        .padding(.leading, 12)
                        .padding(.trailing, -10)
                    Image(systemName: "chevron.right")
                        .padding(8)
                        .fontWeight(.medium)
                        .padding(.trailing, 4)
                }
                .foregroundColor(Color.black)
                .padding(0)
                .background(Color.white)
                .cornerRadius(18)
                .foregroundColor(.white)
                .padding(.trailing, 16)
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .padding(.top, 25)
    }
    
    private var videoPreview: some View {
        VStack {
            if let selectedAsset = selectedAsset, let index = selectedAssetsArray.firstIndex(of: selectedAsset) {
                if index < template.slides.count, template.slides[index].isHDApplied {
                    Image(uiImage: (selectedAsset.fullSizeImage ?? selectedAsset.thumbnail ?? UIImage(named: "")!).applyHDEffect())
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .frame(height: UIScreen.main.bounds.height - (audioURL != nil ? 440 : 375))
                        .clipped()
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.top, (audioURL != nil ? -60 : 0))
                } else {
                    Image(uiImage: selectedAsset.fullSizeImage ?? selectedAsset.thumbnail ?? UIImage(systemName: "photo")!)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .frame(height: UIScreen.main.bounds.height - (audioURL != nil ? 440 : 375))
                        .clipped()
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.top, (audioURL != nil ? -60 : 0))
                }
            }
        }
    }
    
    private var assetSelectionView: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        timeCodesView
                        
                        assetPreviewsView
                            .padding(.top, -20)
                        
                        if let audioURL = audioURL {
                            audioRoadView(audioURL: audioURL)
                                .padding(.top, 8)
                        }
                    }
                }
            }
            
            HStack {
                Rectangle()
                    .frame(width: 1, height: audioURL != nil ? 113 : 65)
                    .foregroundStyle(Color.white)
                    .padding(.leading, 7)
                    .padding(.bottom, -40)
                Spacer()
            }
        }
        .frame(height: audioURL != nil ? 200 : 150)
    }
    
    private func audioRoadView(audioURL: URL) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.clear.opacity(0.3))
                    .frame(height: 40)
                
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [foreColor, .purple, .indigo]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(audioEndTime - audioStartTime) / CGFloat(totalDurationInSeconds) * geometry.size.width, height: 40)
                    .offset(x: CGFloat(audioStartTime) / CGFloat(totalDurationInSeconds) * geometry.size.width)
                    .cornerRadius(8)
                
                if let audioName = audioName {
                    Text(audioName)
                        .lineLimit(1)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                }
            }
        }
        .frame(height: 40)
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }
    
    private var timeCodesView: some View {
        return HStack(spacing: 0) {
            ForEach(0...totalDurationInSeconds, id: \.self) { second in
                HStack {
                    Text(formatTimeCode(second))
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                    Spacer()
                    Circle()
                        .fill(.gray.opacity(0.8))
                        .frame(width: 4, height: 4)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .frame(height: 30)
    }

    private var assetPreviewsView: some View {
        let assetsCount = selectedAssetsArray.count
        let slidesCount = template.slides.count
        return HStack {
            if assetsCount > slidesCount {
                HStack(spacing: 0) {
                    ForEach(Array(zip(template.slides.indices, selectedAssetsArray)), id: \.1.id) { (index, card) in
                        assetView(for: index)
                            .onTapGesture {
                                selectedAsset = selectedAssetsArray[index]
                            }
                            .padding(.vertical, 1)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 30)
            } else {
                HStack(spacing: 0) {
                    ForEach(Array(zip(selectedAssetsArray.indices, selectedAssetsArray)), id: \.1.id) { (index, card) in
                        assetView(for: index)
                            .onTapGesture {
                                selectedAsset = selectedAssetsArray[index]
                            }
                            .padding(.vertical, 1)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 30)
            }
        }
    }

    private func assetView(for index: Int) -> some View {
        let asset = selectedAssetsArray[index]
        let slide = template.slides[index]
        
        return Group {
            if let image = asset.thumbnail {
                ZStack {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(0..<Int(ceil(slide.duration * 2)), id: \.self) { _ in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width / CGFloat(ceil(slide.duration * 2)), height: 60)
                                    .clipped()
                            }
                        }
                    }
                    .frame(width: CGFloat(slide.duration) * 100, height: 60)
                    .cornerRadius(12)
                    
                    if asset.type == .video {
                        Image(systemName: "play.circle")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedAsset == selectedAssetsArray[index] ? foreColor : Color.clear, lineWidth: 2)
                }
                .padding(.trailing, 2)
            }
        }
    }
    
    private var renderVideoView: some View {
        VStack {
            Text("Rendering Video")
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(Color.white)
                .padding()
                .padding(.top)
            Text("Please do not close this window and wait for the video to finish rendering.")
                .lineLimit(3)
                .lineSpacing(6)
                .padding(.horizontal, 35)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white)
            
            Spacer()
            
            ProgressView("", value: renderProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing))
                .padding()
                .padding(.horizontal)
                .padding(.bottom, -30)
            
            Text("\(Int(renderProgress * 100))%")
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.3))
                .padding()
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 225)
        .background(backColor.opacity(0.2))
        .background(
            BlurView(style: .dark)
                .cornerRadius(30)
        )
        .cornerRadius(30)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .cornerRadius(20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
        }
        .padding(.horizontal, 25)
    }
    
    private func renderAndPlayVideo() {
        let outputSize = CGSize(width: 1080, height: 1920) // 1080p vertical video

        // Start rendering
        DispatchQueue.main.async {
            self.isRenderingVideo = true
            self.renderProgress = 0.0
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let audioDuration: Double
            if let audioURL = self.audioURL {
                let audioAsset = AVAsset(url: audioURL)
                audioDuration = CMTimeGetSeconds(audioAsset.duration)
            } else {
                audioDuration = 0
            }

            VideoRenderingManager.shared.createFinalVideo(
                from: selectedAssetsArray,
                template: self.template,
                outputSize: outputSize,
                frameRate: 30,
                outputFileName: "preview_template_video_\(UUID().uuidString)",
                audioURL: self.audioURL,
                audioStartTime: 0, // Set audio start time to 0
                audioEndTime: audioDuration, // Set audio end time to audio duration
                progressHandler: { progress in
                    DispatchQueue.main.async {
                        withAnimation {
                            self.renderProgress = progress
                        }
                    }
                },
                completion: { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let finalVideoURL):
                            print("Final video created at: \(finalVideoURL)")
                            withAnimation {
                                self.isRenderingVideo = false
                                self.renderedVideoURL = finalVideoURL
                                self.showVideoPlayer = true
                            }
                            self.tempURLs = VideoRenderingManager.shared.getTempURLs()
                        case .failure(let error):
                            print("Error creating final video: \(error)")
                            withAnimation {
                                self.isRendering = false
                            }
                        }
                    }
                }
            )
        }
    }
    
    private func deleteRenderedVideo() {
        if let url = renderedVideoURL {
            do {
                try FileManager.default.removeItem(at: url)
                print("Temporary video file deleted successfully")
            } catch {
                print("Error deleting temporary video file: \(error)")
            }
            renderedVideoURL = nil
        }
    }
    
    private func playVideo(asset: MediaAsset) {
        guard let asset = asset.asset else { return }
        let options = PHVideoRequestOptions()
        options.version = .current
        
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { playerItem, _ in
            DispatchQueue.main.async {
                if let playerItem = playerItem {
                    self.videoPlayer = AVPlayer(playerItem: playerItem)
                    self.videoPlayer?.play()
                }
            }
        }
    }
    
    private func startRendering() {
        isRendering = true
        renderProgress = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            renderProgress += 0.05
            if renderProgress >= 1.0 {
                timer.invalidate()
                isRendering = false
            }
        }
    }
    
    private var totalDurationInSeconds: Int {
        Int(template.slides.reduce(0) { $0 + $1.duration })
    }

    private func formatTimeCode(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}









struct VideoPlayerView: View {
    let videoURL: URL
    let onDismiss: () -> Void
    @State private var player: AVPlayer?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            } else {
                ProgressView()
            }

            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            self.player = AVPlayer(url: videoURL)
            self.player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}

//
//  SaveVideoView.swift
//  MoveMe
//
//  Created by User on 2024-07-30.
//

import Foundation
import SwiftUI
import AVKit

enum ShareOption {
    case instagram
    case tiktok
    case device
    case none
}

struct SaveVideoView: View {
    
    var audioURL: URL?
    var selectedAssets: [MediaAsset]
    var template: Template
    
    @State private var tempURLs: [URL] = []
    
    @State private var isRendering = false
    @State private var renderProgress: Double = 0.0
    @State private var renderStatus = ""
    @State private var renderingComplete = false
    @State private var renderedVideoURL: URL?
    @State private var isSharePresented = false
    @State private var shareSelectedOption: ShareOption = .none
    
    @State private var presentSubscriptionsCoerView = false
    @State private var presentMainTemplatesView = false
    @State private var presentDownloadsLimitAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    
    var body: some View {
        ZStack {
            
            VStack {
                
                ZStack {
                    
                    LinearGradient(gradient: Gradient(colors: [.indigo.opacity(0.3), .clear,  .clear]), startPoint: .bottom, endPoint: .top)
                    
                    VStack {
                        
                        HStack {
                            
                            Button {
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
                            }
                            .disabled(isRendering)
                            .opacity(isRendering ? 0.4 : 1)

                            
                            Spacer()
                            
                            
                            Button {
                                presentMainTemplatesView.toggle()
                                deleteTempURLs()
                            } label: {
                                HStack {
                                    Text("Done")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(Color.black)
                                .padding(.horizontal, 4)
                                .padding(7)
                                .background(Color.white)
                                .cornerRadius(18)
                                .padding(.horizontal, 4)
                            }
                            .disabled(isRendering)
                            .opacity(isRendering ? 0.4 : 1)
                            
                        }
                        .padding(.top, 12)
                        
                        Image(uiImage: Array(selectedAssets)[0].fullSizeImage ?? Array(selectedAssets)[0].thumbnail ?? UIImage(named: "")!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 45)
                            .frame(height: UIScreen.main.bounds.height - 446)
                            .clipped()
                            .cornerRadius(18)
                            .padding(.vertical, 25)
                            .padding(.bottom, -6)
                        
                        HStack {
                            Text("Select format for your reel")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.bottom, 10)
                            
                            Spacer()
                        }
                        
                        HStack {
                            
                            Button {
                                VideoCountManager.shared.checkDownloadLimit { isAllowed in
                                    if isPremium || isAllowed {
                                        withAnimation {
                                            shareSelectedOption = .instagram
                                        }
                                    } else {
                                        withAnimation {
                                            presentDownloadsLimitAlert.toggle()
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image("Instagram_icon")
                                        .resizable()
                                        .frame(width: 21, height: 21)
                                    Text("Instagram reel")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.white)
                                }
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(backColor.opacity(0.85))
                                .cornerRadius(16)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(gradient: Gradient(colors: shareSelectedOption == .instagram ? [.purple, .pink, .orange] : []), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                                }
                            }
                            .padding(.trailing, 8)
                            
                            
                            Button {
                                VideoCountManager.shared.checkDownloadLimit { isAllowed in
                                    if isPremium || isAllowed {
                                        withAnimation {
                                            shareSelectedOption = .tiktok
                                        }
                                    } else {
                                        withAnimation {
                                            presentDownloadsLimitAlert.toggle()
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image("Tiktok-icon")
                                        .resizable()
                                        .frame(width: 21, height: 21)
                                    Text("Tiktok")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.white)
                                }
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(backColor.opacity(0.85))
                                .cornerRadius(16)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(gradient: Gradient(colors: shareSelectedOption == .tiktok ? [.purple, .pink, .orange] : []), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                                }
                            }
                        }
                        
                        Text("Instagram and TikTok may mute your video's sound due to copytight policies. You might need to re-add the audio track before publishing.")
                            .font(.caption2)
                            .foregroundStyle(Color.white.opacity(0.6))
                            .frame(height: 60)
                            .lineLimit(3)
                            .lineSpacing(3)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                            .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 20)
                }
                
                HStack {}
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                    .background(Color.indigo)
                    .padding(.horizontal, -20)
                    .padding(.top, -10)
                    .padding(.bottom, 4)
                
                Button {
                    VideoCountManager.shared.checkDownloadLimit { isAllowed in
                        if isPremium || isAllowed {
                            withAnimation {
                                isRendering = true
                            }
                            if shareSelectedOption == .none {
                                shareSelectedOption = .device
                            }
                            createVideoFromTemplate()
                        } else {
                            withAnimation {
                                presentDownloadsLimitAlert.toggle()
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(Color.white)
                            .fontWeight(.semibold)
                        Text("Save video")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(foreColor)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
            
            if isRendering {
                renderVideoView
            }
            
            if presentDownloadsLimitAlert {
                downloadsLimitAlert
            }
        }
        .background(backColor)
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        .onChange(of: renderProgress) { newValue in
            if newValue >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if renderedVideoURL != nil {
                        switch shareSelectedOption {
                        case .instagram:
                            shareToInstagramReel()
                        case .tiktok:
                            isSharePresented.toggle()
                        case .device:
                            isSharePresented.toggle()
                        case .none:
                            break
                        }
                    }
                }
            }
        }
        .shareSheet(isPresented: $isSharePresented, activityItems: [renderedVideoURL].compactMap { $0 }, completion: {
            switch shareSelectedOption {
            case .instagram:
                break
            case .tiktok:
                shareTikTok()
            case .device:
                break
            case .none:
                break
            }
        })
        .fullScreenCover(isPresented: $presentMainTemplatesView) {
            ContentView()
        }
        .fullScreenCover(isPresented: $presentSubscriptionsCoerView, content: {
            SubscritionsCoverView()
        })
    }
    
    func createVideoFromTemplate() {
        let outputSize = CGSize(width: 1080, height: 1920) // 1080p vertical video

        // Start rendering
        DispatchQueue.main.async {
            self.isRendering = true
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
                from: selectedAssets,
                template: self.template,
                outputSize: outputSize,
                frameRate: 30,
                outputFileName: "Template_\(VideoCountManager.shared.videoCount)",
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
                                self.isRendering = false
                                self.renderingComplete = true
                                self.renderedVideoURL = finalVideoURL
                            }
                            VideoCountManager.shared.incrementDownloadCount()
                            self.tempURLs = VideoRenderingManager.shared.getTempURLs()
                        case .failure(let error):
                            print("Error creating final video: \(error)")
                            withAnimation {
                                self.isRendering = false
                                self.renderingComplete = false
                            }
                        }
                    }
                }
            )
        }
    }
    
    func shareToInstagramReel() {
        guard let renderedVideoURL = renderedVideoURL else {
            print("No rendered video available")
            return
        }

        let appIDString = "1971497316616787"

        do {
            let backgroundVideoData = try Data(contentsOf: renderedVideoURL)
            shareBackgroundVideo(backgroundVideoData: backgroundVideoData, appID: appIDString)
        } catch {
            print("Error reading video data: \(error)")
        }
    }

    func shareBackgroundVideo(backgroundVideoData: Data, appID: String) {
        if let urlScheme = URL(string: "instagram-reels://share"), UIApplication.shared.canOpenURL(urlScheme) {
            let pasteboardItems: [[String: Any]] = [
                ["com.instagram.sharedSticker.backgroundVideo": backgroundVideoData],
                ["com.instagram.sharedSticker.appID": appID]
            ]
                
            let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
                
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(urlScheme)
        } else {
            print("Instagram Reels app is not installed")
        }
    }
    
    func shareTikTok() {
        let tiktokURL = URL(string: "tiktok://")!
        if UIApplication.shared.canOpenURL(tiktokURL) {
            UIApplication.shared.open(tiktokURL, options: [:], completionHandler: nil)
        } else {
            // TikTok app is not installed, open the App Store link
            if let appStoreURL = URL(string: "https://apps.apple.com/us/app/tiktok/id835599320") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private var renderVideoView: some View {
        VStack {
            Text("Downloading Video")
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(Color.white)
                .padding()
                .padding(.top)
            Text("Please do not close this window.")
                .lineLimit(3)
                .lineSpacing(6)
                .padding(.horizontal, 35)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white)
            Text(renderStatus)
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.top, 8)
            
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
    
    private var downloadsLimitAlert: some View {
        VStack {
            Text("Downloads Limit")
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(Color.white)
                .padding()
                .padding(.top)
            Text("You have exceeded your download limit. Continue with MoveMe Pro to get unlimited downloads.")
                .lineLimit(3)
                .lineSpacing(6)
                .padding(.horizontal, 35)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white)
            
            Spacer() 
            
            Button {
                withAnimation {
                    presentDownloadsLimitAlert.toggle()
                    presentSubscriptionsCoerView.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                        .padding(.leading, 8)
                        .padding(.trailing, -10)
                    Text("PRO")
                        .fontWeight(.bold)
                        .padding(11)
                }
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(14)
                .foregroundColor(.white)
                .shadow(color: foreColor.opacity(0.4), radius: 6)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
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
    
    func deleteTempURLs() {
        for url in tempURLs {
            try? FileManager.default.removeItem(at: url)
        }
        tempURLs.removeAll()
    }
}

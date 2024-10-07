//
//  TemplateDetailView.swift
//  MoveMe
//
//  Created by User on 2024-07-10.
//

import SwiftUI
import AVKit
import AVFoundation

struct TemplateDetailView: View {
    
    var template: Template
    
    @Binding var tabBarVisible: Bool
    
    @State private var player: AVPlayer?
    @State private var presentCreateReelPhotoLibraryView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Image(template.iconName)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
                .frame(height: UIScreen.main.bounds.height)
                .ignoresSafeArea(.all)
            
            VStack {
                if let player = player {
                    FullScreenVideoPlayer(player: player)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: UIScreen.main.bounds.height)
                        .onAppear {
                            player.play()
                        }
                        .disabled(true)
                }
            }
            .ignoresSafeArea(.all)
            .edgesIgnoringSafeArea(.all)
            .frame(width: UIScreen.main.bounds.width)
            .frame(height: UIScreen.main.bounds.height)
            
            VStack(alignment: .leading) {
                HStack {}
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(height: 1)
                    .background(Color.black)
                    .shadow(color: Color.black, radius: 20)
                    .padding(.top, -16)
                
                Button {
                    withAnimation {
                        tabBarVisible = true
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.leading, 16)
                        .foregroundStyle(Color.white)
                }
                .padding(.top, 50)

                
                Spacer()
            }
            
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
                    
                    Image("instagram-white-icon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 14, height: 14)
                    
                    Image("tiktok-round-white-icon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 14, height: 14)
                    
                    Spacer()
                }
                .padding(.bottom, 4)
                .padding(.leading, 12)
                
                ZStack {
                    BlurView(style: .dark)
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                .padding(.bottom, -80)
                                .padding(.horizontal, -34)
                                .ignoresSafeArea(.all)
                        }
                    
                    Button(action: {
                        presentCreateReelPhotoLibraryView.toggle()
                    }, label: {
                        Text("USE TEMPLATE")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(foreColor)
                            .cornerRadius(18)
                            .shadow(color: foreColor.opacity(0.2), radius: 10)
                    })
                    .padding(.all, 12)
                    .padding(.bottom, 41)
                }
                .ignoresSafeArea(.all)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $presentCreateReelPhotoLibraryView) {
            CreateReelPhotoLibraryView(template: template)
        }
        .onAppear {
            setupVideoPlayer()
            tabBarVisible = false
            if let player = player {
                player.play()
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
            player?.pause()
            player?.volume = 0
            player = nil
        }
    }
    
    private func setupVideoPlayer() {
        if let example = template.example {
            guard let videoURL = Bundle.main.url(forResource: example, withExtension: "mp4") else {
                print("Video file not found")
                return
            }
            
            let playerItem = AVPlayerItem(url: videoURL)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            
        } else {
            print("Example was not found.")
        }
    }
}



struct FullScreenVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        return FullScreenVideoPlayerUIView(player: player)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class FullScreenVideoPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    private var player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
        super.init(frame: .zero)
    
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        playerLayer.frame = bounds
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        print(" layer frame: \(frame)")
        print("Player layer frame: \(playerLayer.frame)")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.status) {
            switch player.status {
            case .readyToPlay:
                print("Player is ready to play")
            case .failed:
                print("Player failed: \(player.error?.localizedDescription ?? "unknown error")")
            case .unknown:
                print("Player status is unknown")
            @unknown default:
                break
            }
        }
    }
}




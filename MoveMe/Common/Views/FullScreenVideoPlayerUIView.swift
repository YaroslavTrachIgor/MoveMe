//
//  FullScreenVideoPlayerUIView.swift
//  MoveMe
//
//  Created by User on 2024-10-07.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation

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




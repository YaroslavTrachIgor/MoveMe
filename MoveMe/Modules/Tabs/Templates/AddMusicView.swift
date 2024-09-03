//
//  AddMusicView.swift
//  MoveMe
//
//  Created by User on 2024-08-12.
//

import Foundation
import SwiftUI
import FirebaseStorage
import AVFAudio
import AVFoundation

struct Track: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let duration: Int
    let imageName: String
    let filePath: String
    let isShazamTrack: Bool
    
    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MusicLibraryView: View {
    
    var onAudioSelected: (URL, Double, Double, String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTrack: Track? = nil
    @State private var isPlaying: Bool = false
    @State private var playbackTime: Double = 0.0
    
    @State private var isLoading: Bool = true
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var avPlayer: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var playerTimeObserver: Any?
    @State private var timer: Timer?
    
    @State private var presentSelectAudioStartEndTimeView: Bool = false
    
    @State private var startTime: Double = 0.0
    @State private var endTime: Double = 0.0
    
    @State private var searchText: String = ""
    @State private var searchedTracks: [Track] = []
    
    private let shazamAPIManager = ShazamAPIManager()
    
    let tracks = [
        Track(title: "National Sweetheart",
              artist: "Copy of Tasty Waves",
              duration: 169,
              imageName: "music.note",
              filePath: "Copy of Tasty Waves - National Sweetheart.mp3",
              isShazamTrack: false),
        Track(title: "Jungles",
              artist: "Bobby Renz",
              duration: 111,
              imageName: "music.note",
              filePath: "Jungles - Text Me Records _ Bobby Renz.mp3",
              isShazamTrack: false),
        Track(title: "Sunspots",
              artist: "Jeremy Blake",
              duration: 342,
              imageName: "music.note",
              filePath: "Sunspots - Jeremy Blake.mp3",
              isShazamTrack: false),
        Track(title: "Oh, Pretty Woman",
              artist: "Roy Orbison",
              duration: 176,
              imageName: "music.note",
              filePath: "spotifydown.com - Oh, Pretty Woman.mp3",
              isShazamTrack: false),
        Track(title: "Pon de Replay",
              artist: "Rihanna",
              duration: 246,
              imageName: "music.note",
              filePath: "spotifydown.com - Pon de Replay.mp3", 
              isShazamTrack: false)
    ]

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
                    
                    Button(action: {
                        presentSelectAudioStartEndTimeView.toggle()
                    }) {
                        HStack {
                            Text("Add")
                                .fontWeight(.medium)
                                .padding(.leading, 12)
                                .padding(.trailing, -10)
                            Image(systemName: "checkmark")
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
                        .padding(.top, 6)
                    }
                    .disabled(selectedTrack == nil)
                    .opacity(selectedTrack == nil ? 0.4 : 1)
                }
                .padding(.top, 2)
                
                HStack {
                    Text("Music Library")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, -8)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.white.opacity(0.6))
                        .padding(.leading, 16)
                    TextField("Search Popular Tracks", text: $searchText, onCommit: searchTracks)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.all, 8)
                }
                .background(secondaryBackColor)
                .cornerRadius(25)
                .padding(.horizontal, 18)
                .padding(.top, 10)
                
                VStack {
                    List(searchedTracks.isEmpty ? tracks : searchedTracks) { track in
                        HStack {
                            ZStack {
                                Image(systemName: track.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(foreColor)
                            }
                            .frame(width: 50, height: 50)
                            .background(foreColor.opacity(0.12))
                            .cornerRadius(8)
                            .padding(.trailing, 8)
                            
                            VStack(alignment: .leading) {
                                Text(track.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(track.artist)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(track.formattedDuration)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTrack?.id != track.id {
                                stopPlayback()
                                selectedTrack = track
                                playTrack(track)
                                endTime = Double(track.duration)
                            } else {
                                togglePlayback()
                            }
                        }
                        .background(backColor.edgesIgnoringSafeArea(.all))
                        .listRowBackground(backColor)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .background(backColor.edgesIgnoringSafeArea(.all))
                    .padding(.top, 12)
                }
                
                if let track = selectedTrack {
                    HStack {}
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .background(Color.indigo)
                        .padding(.horizontal, -20)
                        .padding(.bottom, 0)
                    VStack {
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                            
                        } else {
                            VStack {
                                HStack {
                                    TrackInfoView(track: track)
                                    Spacer()
                                    PlaybackControlView(isPlaying: $isPlaying, togglePlayback: togglePlayback)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                
                                Slider(value: $playbackTime, in: 0...Double(track.duration)) { editing in
                                    if editing {
                                        pausePlayback()
                                    } else {
                                        seekToTime(time: playbackTime)
                                    }
                                }
                                .padding([.leading, .trailing])
                                
                                HStack {
                                    Text(formatTime(playbackTime)).foregroundStyle(Color.gray).font(.caption)
                                    Spacer()
                                    Text(track.formattedDuration).foregroundStyle(Color.gray).font(.caption)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                    .frame(height: 125)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                }
            }
            
            if presentSelectAudioStartEndTimeView {
                selectAudioStartEndTimeView
            }
            
        }
        .background(backColor.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onDisappear(perform: {
            NotificationCenter.default.removeObserver(self)
            if let observer = playerTimeObserver {
                avPlayer?.removeTimeObserver(observer)
            }
        })
    }
    
    
    private func playTrack(_ track: Track) {
        isLoading = true
        DispatchQueue.global(qos: .userInteractive).async {
            if track.isShazamTrack {
                self.setupAVPlayer(with: track.filePath)
            } else {
                self.getAudioFromFirebase(path: track.filePath) { result in
                    switch result {
                    case .success(let url):
                        self.setupAVAudioPlayer(with: url)
                    case .failure(let error):
                        print("Error getting audio file: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    private func setupAVPlayer(with urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        self.playerItem = playerItem
        self.avPlayer = AVPlayer(playerItem: playerItem)
        
        DispatchQueue.main.async {
            self.addPlayerItemObserver()
            self.addPeriodicTimeObserver()
            self.avPlayer?.seek(to: CMTime(seconds: self.startTime, preferredTimescale: 1))
            self.avPlayer?.play()
            self.isPlaying = true
            self.isLoading = false
        }
    }
    
    private func setupAVAudioPlayer(with url: URL) {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            DispatchQueue.main.async {
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.currentTime = self.startTime
                self.audioPlayer?.play()
                self.isPlaying = true
                self.startTimer()
                self.isLoading = false
            }
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func addPlayerItemObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [self] _ in
            stopPlayback()
        }
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerTimeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] time in
            playbackTime = time.seconds
            if playbackTime >= self.endTime {
                stopPlayback()
            }
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            resumePlayback()
        }
    }
    
    private func pausePlayback() {
        audioPlayer?.pause()
        avPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
    }
    
    private func resumePlayback() {
        audioPlayer?.play()
        avPlayer?.play()
        isPlaying = true
        if audioPlayer != nil {
            startTimer()
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        avPlayer?.pause()
        avPlayer?.seek(to: .zero)
        isPlaying = false
        playbackTime = 0
        timer?.invalidate()
        if let observer = playerTimeObserver {
            avPlayer?.removeTimeObserver(observer)
            playerTimeObserver = nil
        }
    }
    
    private func seekToTime(time: Double) {
        audioPlayer?.currentTime = time
        avPlayer?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        resumePlayback()
    }
    
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = self.audioPlayer {
                self.playbackTime = player.currentTime
                if player.currentTime >= self.endTime {
                    self.stopPlayback()
                }
            }
        }
    }
    
    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getAudioFromFirebase(path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let audioRef = storageRef.child(path)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("tempAudio.mp3")
        print(filePath)
        
        audioRef.write(toFile: filePath) { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }
    
    
    private var selectAudioStartEndTimeView: some View {
        ZStack {
            VStack {
                Text("Add Audio")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.white)
                    .padding()
                    .padding(.top)
                Text("Choose start and end time for the selected audio track.")
                    .lineLimit(3)
                    .lineSpacing(6)
                    .padding(.horizontal, 35)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                if let track = selectedTrack {
                    VStack {
                        HStack {
                            Text("Start Time:".uppercased())
                                .foregroundColor(.secondary.opacity(0.8))
                                .font(.caption)
                            Spacer()
                            Text("\(formatTime(startTime))")
                                .foregroundColor(.white)
                                .font(.callout)
                                .opacity(0.8)
                        }
                        .padding(.bottom, -2)
                        .padding(.horizontal)
                        
                        Slider(value: $startTime, in: 0...Double(track.duration), step: 1.0)
                            .accentColor(.white)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        HStack {
                            Text("End Time:".uppercased())
                                .foregroundColor(.secondary.opacity(0.8))
                                .font(.caption)
                            Spacer()
                            Text("\(formatTime(endTime))")
                                .foregroundColor(.white)
                                .font(.callout)
                                .opacity(0.8)
                        }
                        .padding(.bottom, -2)
                        .padding(.horizontal)
                        
                        Slider(value: $endTime, in: 0...Double(track.duration), step: 1.0)
                            .accentColor(.white)
                            .padding(.horizontal)
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack {
                    Button {
                        withAnimation {
                            addAudioWithAdjustedTime()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                                .padding(.leading, 8)
                                .padding(.trailing, -10)
                            Text("Add Audio")
                                .fontWeight(.bold)
                                .padding(11)
                        }
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(foreColor)
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .shadow(color: foreColor.opacity(0.4), radius: 6)
                    }
                    
                    Button {
                        withAnimation {
                            playSelectedPortion()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .fontWeight(.medium)
                                .foregroundStyle(backColor)
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .shadow(color: Color.white.opacity(0.4), radius: 6)
                    }
                    .opacity(isPlaying ? 0.5 : 1)
                    .disabled(isPlaying)
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            presentSelectAudioStartEndTimeView.toggle()
                        }
                    } label: {
                        Image(systemName: "multiply")
                            .foregroundStyle(Color.white)
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.all, 20)
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
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
    
    
    
    private func searchTracks() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        
        shazamAPIManager.searchTrack(term: searchText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let tracks = response.tracks?.hits else { return }
                    let group = DispatchGroup()
                    
                    var tempTracks: [Track] = []
                    
                    for trackHit in tracks {
                        guard let track = trackHit.track else { continue }
                        
                        // Extract audio URLs
                        let audioUrls = track.hub?.actions?.compactMap { action -> String? in
                            if action.type == "uri", let uri = action.uri {
                                return uri
                            }
                            return nil
                        } ?? []
                        
                        // Use the first audio URL if available
                        if let audioUrlString = audioUrls.first, let audioUrl = URL(string: audioUrlString) {
                            group.enter()
                            let asset = AVAsset(url: audioUrl)
                            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                                var error: NSError? = nil
                                let status = asset.statusOfValue(forKey: "duration", error: &error)
                                if status == .loaded {
                                    let duration = CMTimeGetSeconds(asset.duration)
                                    let newTrack = Track(
                                        title: track.title ?? "Unknown Title",
                                        artist: track.subtitle ?? "Unknown Artist",
                                        duration: Int(duration),
                                        imageName: "music.note",
                                        filePath: audioUrlString,
                                        isShazamTrack: true
                                    )
                                    tempTracks.append(newTrack)
                                } else {
                                    print("Failed to load duration for track: \(track.title ?? "Unknown")")
                                }
                                group.leave()
                            }
                        } else {
                            print("No audio URL found for track: \(track.title ?? "Unknown")")
                        }
                    }
                    
                    group.notify(queue: .main) {
                        self.searchedTracks = tempTracks
                        self.isLoading = false
                    }
                    
                case .failure(let error):
                    print("Error fetching tracks: \(error.localizedDescription)")
                    self.searchedTracks = []
                    self.isLoading = false
                }
            }
        }
    }
    
    private func playSelectedPortion() {
        guard let track = selectedTrack else { return }
        
        isLoading = true
        DispatchQueue.global(qos: .userInteractive).async {
            if track.isShazamTrack {
                self.setupAVPlayer(with: track.filePath)
            } else {
                self.getAudioFromFirebase(path: track.filePath) { result in
                    switch result {
                    case .success(let url):
                        self.setupAVAudioPlayer(with: url)
                    case .failure(let error):
                        print("Error getting audio file: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    private func addAudioWithAdjustedTime() {
        guard let track = selectedTrack else { return }
        
        let processAudio = { (url: URL) in
            let asset = AVAsset(url: url)
            let composition = AVMutableComposition()
            
            guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
                  let assetAudioTrack = asset.tracks(withMediaType: .audio).first else {
                print("Failed to create audio track")
                return
            }
            
            let startTime = CMTime(seconds: self.startTime, preferredTimescale: 600)
            let endTime = CMTime(seconds: self.endTime, preferredTimescale: 600)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            do {
                try audioTrack.insertTimeRange(timeRange, of: assetAudioTrack, at: .zero)
                
                let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("adjustedAudio_\(UUID().uuidString).m4a")
                
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    try FileManager.default.removeItem(at: outputURL)
                }
                
                guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
                    print("Failed to create export session")
                    return
                }
                
                exportSession.outputURL = outputURL
                exportSession.outputFileType = .m4a
                
                exportSession.exportAsynchronously {
                    switch exportSession.status {
                    case .completed:
                        DispatchQueue.main.async {
                            print("Adjusted audio URL: \(outputURL)")
                            self.onAudioSelected(outputURL, self.startTime, self.endTime, "\(track.artist) - \(track.title)")
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    case .failed:
                        print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    case .cancelled:
                        print("Export cancelled")
                    default:
                        break
                    }
                }
            } catch {
                print("Error creating adjusted audio: \(error.localizedDescription)")
            }
        }
        
        if track.isShazamTrack {
            guard let url = URL(string: track.filePath) else {
                print("Invalid Shazam track URL")
                return
            }
            
            // Download the audio file from the Shazam URL
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error downloading Shazam track: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received from Shazam URL")
                    return
                }
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempShazamTrack_\(UUID().uuidString).m4a")
                
                do {
                    try data.write(to: tempURL)
                    processAudio(tempURL)
                } catch {
                    print("Error saving temporary Shazam track: \(error.localizedDescription)")
                }
            }.resume()
        } else {
            getAudioFromFirebase(path: track.filePath) { result in
                switch result {
                case .success(let url):
                    processAudio(url)
                case .failure(let error):
                    print("Error getting audio file from Firebase: \(error.localizedDescription)")
                }
            }
        }
    }
}


struct TrackInfoView: View {
    let track: Track

    var body: some View {
        HStack {
            ZStack {
                Image(systemName: track.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(foreColor)
            }
            .frame(width: 50, height: 50)
            .background(foreColor.opacity(0.12))
            .cornerRadius(8)
            .padding(.trailing, 8)

            VStack(alignment: .leading) {
                Text(track.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct PlaybackControlView: View {
    @Binding var isPlaying: Bool
    let togglePlayback: () -> Void

    var body: some View {
        Button(action: togglePlayback) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
        }
    }
}

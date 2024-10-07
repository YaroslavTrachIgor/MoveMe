//
//  Track.swift
//  MoveMe
//
//  Created by User on 2024-10-07.
//

import Foundation


//MARK: - Track model
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


//MARK: - Suggested Tracks
extension Track {
    
    static func getSuggestedTrack(with template: Template) -> [Track] {
        switch template.name {
        case "Template #1":
            return suggestedTracks1
        case "Template #2":
            return suggestedTracks2
        case "Template #3":
            return suggestedTracks3
        case "Template #4":
            return suggestedTracks4
        case "Template #5":
            return suggestedTracks5
        default:
            return suggestedTracks1
        }
    }
    
    
    static let suggestedTracks1 = [
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
    static let suggestedTracks2 = [
        Track(title: "Beach House",
              artist: "Bobby Renz",
              duration: 100,
              imageName: "music.note",
              filePath: "Beach House - Text Me Records _ Bobby Renz.mp3",
              isShazamTrack: false),
        Track(title: "Mountain",
              artist: "Bobby Renz",
              duration: 113,
              imageName: "music.note",
              filePath: "Copy of Mountain - Text Me Records _ Bobby Renz.mp3",
              isShazamTrack: false),
        Track(title: "Never Play",
              artist: "Jeremy Blake",
              duration: 250,
              imageName: "music.note",
              filePath: "Copy of Never Play - Jeremy Blake.mp3",
              isShazamTrack: false),
        Track(title: "Rockville",
              artist: "Patrick Patrikios",
              duration: 169,
              imageName: "music.note",
              filePath: "Copy of Rockville - Patrick Patrikios.mp3",
              isShazamTrack: false),
        Track(title: "Sunspots",
              artist: "Jeremy Blake",
              duration: 342,
              imageName: "music.note",
              filePath: "Sunspots - Jeremy Blake.mp3",
              isShazamTrack: false),
    ]
    static let suggestedTracks3 = [
        Track(title: "Lawrence",
              artist: "TrackTribe",
              duration: 169,
              imageName: "music.note",
              filePath: "Copy of Lawrence - TrackTribe.mp3",
              isShazamTrack: false),
        Track(title: "National Sweetheart",
              artist: "Copy of Tasty Waves",
              duration: 169,
              imageName: "music.note",
              filePath: "Copy of Tasty Waves - National Sweetheart.mp3",
              isShazamTrack: false),
        Track(title: "Grand Avenue",
              artist: "Bobby Renz",
              duration: 125,
              imageName: "music.note",
              filePath: "Grand Avenue - Text Me Records _ Bobby Renz.mp3",
              isShazamTrack: false),
        Track(title: "Mountain",
              artist: "Bobby Renz",
              duration: 113,
              imageName: "music.note",
              filePath: "Copy of Mountain - Text Me Records _ Bobby Renz.mp3",
              isShazamTrack: false),
        Track(title: "Rockville",
              artist: "Patrick Patrikios",
              duration: 169,
              imageName: "music.note",
              filePath: "Copy of Rockville - Patrick Patrikios.mp3",
              isShazamTrack: false)
    ]
    static let suggestedTracks4 = [
        Track(title: "Grand Avenue",
              artist: "Bobby Renz",
              duration: 125,
              imageName: "music.note",
              filePath: "Grand Avenue - Text Me Records _ Bobby Renz.mp3",
              isShazamTrack: false),
        Track(title: "Hideout",
              artist: "Bobby Renz",
              duration: 133,
              imageName: "music.note",
              filePath: "Hideout - Text Me Records _ Bobby Renz.mp3",
              isShazamTrack: false),
        Track(title: "Never Play",
              artist: "Jeremy Blake",
              duration: 250,
              imageName: "music.note",
              filePath: "Copy of Never Play - Jeremy Blake.mp3",
              isShazamTrack: false),
        Track(title: "Rockville",
              artist: "Patrick Patrikios",
              duration: 169,
              imageName: "music.note",
              filePath: "Copy of Rockville - Patrick Patrikios.mp3",
              isShazamTrack: false),
        Track(title: "National Sweetheart",
              artist: "Copy of Tasty Waves",
              duration: 169,
              imageName: "music.note",
              filePath: "Copy of Tasty Waves - National Sweetheart.mp3",
              isShazamTrack: false),
    ]
    static let suggestedTracks5 = [
        Track(title: "Template 5",
              artist: "Unknown Artist",
              duration: 14,
              imageName: "music.note",
              filePath: "5_no ID - zuubamusic.mp3",
              isShazamTrack: false)
    ]
}

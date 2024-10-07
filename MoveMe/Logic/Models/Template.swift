//
//  Template.swift
//  MoveMe
//
//  Created by User on 2024-07-31.
//

import Foundation

struct Template: Identifiable, Hashable {
    let id: UUID
    let name: String
    let iconName: String
    let items: Int
    var duration: Double
    let example: String?
    var slides: [Slide]
    var defaultAudioPath: String?
}

struct Slide: Identifiable, Hashable {
    var id: UUID
    var duration: Double
    var isHDApplied: Bool
    var isVideo: Bool
}


extension Template {
    static let list = [
        Template(id: UUID(), name: "Template #1", iconName: "Template1", items: 12, duration: 13.0, example: "Reel1", slides: [
            Slide(id: UUID(), duration: 0.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.7, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.8, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.9, isHDApplied: false, isVideo: false),
        ], defaultAudioPath: "spotifydown.com - Pon de Replay.mp3"),
        Template(id: UUID(), name: "Template #2", iconName: "Template2", items: 7, duration: 12.4, example: "Reel2", slides: [
            Slide(id: UUID(), duration: 2.1, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.8, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.3, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.8, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 2.3, isHDApplied: false, isVideo: false),
        ], defaultAudioPath: "2_Timpani Beat - Nana Kwabena.mp3"),
        Template(id: UUID(), name: "Template #3", iconName: "Template3", items: 6, duration: 6.6, example: "Reel3", slides: [
            Slide(id: UUID(), duration: 1.1, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.1, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.1, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.1, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.1, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.1, isHDApplied: false, isVideo: false),
        ], defaultAudioPath: "Copy of Rockville - Patrick Patrikios.mp3"),
        Template(id: UUID(), name: "Template #4", iconName: "Template4", items: 10, duration: 10.9, example: "Reel4", slides: [
            Slide(id: UUID(), duration: 1.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.7, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.0, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.7, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.7, isHDApplied: false, isVideo: false),
        ], defaultAudioPath: "Grand Avenue - Text Me Records _ Bobby Renz.mp3"),
        Template(id: UUID(), name: "Template #5", iconName: "Template5", items: 12, duration: 20.6, example: "Reel5", slides: [
            Slide(id: UUID(), duration: 0.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.3, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.3, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.3, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.4, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.2, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.1, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.7, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.6, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 1.5, isHDApplied: false, isVideo: false),
            Slide(id: UUID(), duration: 0.8, isHDApplied: false, isVideo: false),
        ], defaultAudioPath: "5_no ID - zuubamusic.mp3")
    ]
}

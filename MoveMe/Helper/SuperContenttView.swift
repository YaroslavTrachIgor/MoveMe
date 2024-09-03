//
//  SuperContenttView.swift
//  MoveMe
//
//  Created by User on 2024-07-06.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation
import AVKit

enum ConstructionError: Error {
    case invalidImage
    case invalidURL
    case invalidExportSession
    case exportFailed
}

struct SuperContenttView: View {
    @State private var showPhotoPicker = false
    @State private var selectedPhotos: [UIImage] = []
    
    @State private var backgroundMusic: URL?
    @State private var showMusicPicker = false
    
    var body: some View {
        VStack {
            Button("Select Photos") {
                showPhotoPicker = true
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(selectedPhotos: $selectedPhotos)
            }
            
            if !selectedPhotos.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedPhotos, id: \.self) { photo in
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                .padding(4)
                        }
                    }
                }
            }
            
            Button("Add Background Music") {
                showMusicPicker = true
            }
            .sheet(isPresented: $showMusicPicker) {
                MusicPicker(selectedMusic: $backgroundMusic)
            }
            
            if let music = backgroundMusic {
                Text("Selected Music: \(music.lastPathComponent)")
            }
            
            Spacer()
            
            Button("Create Video") {
                let images: [UIImage] = selectedPhotos
                let outputSize = CGSize(width: 1920, height: 1080)
                let frameRate: Int32 = 30
                let durationPerImage: Double = 2.0
                let outputFileName = "slideshow"
                do {
                    let videoURL = try createTransitionedVideo(from: images, outputSize: outputSize, totalDuration: 10.0, outputFileName: outputFileName)
                    print("Video created at URL: \(videoURL)")
                } catch {
                    print("Error creating video: \(error)")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    func createVideo(from images: [UIImage], outputSize: CGSize, frameRate: Int32 = 30, durationPerImage: Double, outputFileName: String) throws -> URL {
        // Generate a file URL to store the video
        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(outputFileName).mov") else {
            throw ConstructionError.invalidURL
        }
        
        // Delete any old file
        try? FileManager.default.removeItem(at: outputMovieURL)
        
        // Create an asset writer instance
        guard let assetWriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov) else {
            throw ConstructionError.invalidURL
        }
        
        // Create 1080p settings
        let settingsAssistant = AVOutputSettingsAssistant(preset: .preset1920x1080)?.videoSettings
        
        // Create a single video input
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settingsAssistant)
        
        // Create an adaptor for the pixel buffer
        let assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        
        // Add the input to the asset writer
        assetWriter.add(assetWriterInput)
        
        // Begin the session
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        // Create a CIContext
        let context = CIContext()
        
        // Set up some standard attributes for pixel buffer creation
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        // Determine the number of frames we need to generate per image
        let framesPerImage = Int(durationPerImage * Double(frameRate))
        
        // Loop through images
        var frameCount = 0
        for image in images {
            // Create a CIImage from UIImage
            guard var ciImage = CIImage(image: image) else {
                throw ConstructionError.invalidImage
            }
            
            // Create the pixel buffer
            var pixelBuffer: CVPixelBuffer?
            CVPixelBufferCreate(kCFAllocatorDefault,
                                Int(outputSize.width),
                                Int(outputSize.height),
                                kCVPixelFormatType_32BGRA,
                                attrs,
                                &pixelBuffer)
            
            // Render the CIImage into the pixel buffer
            context.render(ciImage, to: pixelBuffer!)
            
            // Append the pixel buffer to the video
            for _ in 0..<framesPerImage {
                if assetWriterInput.isReadyForMoreMediaData {
                    let frameTime = CMTimeMake(value: Int64(frameCount), timescale: frameRate)
                    assetWriterAdaptor.append(pixelBuffer!, withPresentationTime: frameTime)
                    frameCount += 1
                }
            }
        }
        
        // Finish writing
        assetWriterInput.markAsFinished()
        assetWriter.finishWriting {
            // Clean up
            print("Finished video location: \(outputMovieURL)")
        }
        
        return outputMovieURL
    }
    
    func createTransitionedVideo(from images: [UIImage], outputSize: CGSize, frameRate: Int32 = 30, totalDuration: Double = 10.0, outputFileName: String) throws -> URL {
        guard images.count > 1 else {
            throw ConstructionError.invalidImage // Ensure there are at least two images for transitions
        }
        
        // Calculate duration per image and transition duration
        let durationPerImage = totalDuration / Double(images.count)
        let transitionDuration = durationPerImage * 0.2
        let displayDuration = durationPerImage * 0.8
        
        // Generate a file URL to store the video
        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(outputFileName).mov") else {
            throw ConstructionError.invalidURL
        }
        
        // Delete any old file
        try? FileManager.default.removeItem(at: outputMovieURL)
        
        // Create an asset writer instance
        guard let assetWriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov) else {
            throw ConstructionError.invalidURL
        }
        
        // Create video settings
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: outputSize.width,
            AVVideoHeightKey: outputSize.height
        ]
        
        // Create a single video input
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterInput.expectsMediaDataInRealTime = true
        
        // Create an adaptor for the pixel buffer
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: outputSize.width,
            kCVPixelBufferHeightKey as String: outputSize.height,
            kCVPixelFormatOpenGLESCompatibility as String: true
        ]
        let assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        
        // Add the input to the asset writer
        assetWriter.add(assetWriterInput)
        
        // Begin the session
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        // Create a CIContext
        let context = CIContext()
        
        // Set up some standard attributes for pixel buffer creation
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        // Variable to hold the pixel buffer
        var pixelBuffer: CVPixelBuffer?
        
        // Loop through images
        var frameCount = 0
        for i in 0..<images.count {
            guard let ciImage = CIImage(image: images[i]) else {
                throw ConstructionError.invalidImage
            }
            
            // Display image without transition
            for _ in 0..<Int(displayDuration * Double(frameRate)) {
                if assetWriterInput.isReadyForMoreMediaData {
                    let frameTime = CMTimeMake(value: Int64(frameCount), timescale: frameRate)
                    pixelBuffer = createPixelBuffer(from: ciImage, context: context, outputSize: outputSize, attrs: attrs)
                    assetWriterAdaptor.append(pixelBuffer!, withPresentationTime: frameTime)
                    frameCount += 1
                }
            }
            
            // Apply transition if not the last image
            if i < images.count - 1 {
                guard let nextImage = CIImage(image: images[i + 1]) else {
                    throw ConstructionError.invalidImage
                }
                for t in 0..<Int(transitionDuration * Double(frameRate)) {
                    if assetWriterInput.isReadyForMoreMediaData {
                        let frameTime = CMTimeMake(value: Int64(frameCount), timescale: frameRate)
                        let alpha = CGFloat(t) / CGFloat(transitionDuration * Double(frameRate))
                        let transitionImage = blendImages(from: ciImage, to: nextImage, alpha: alpha)
                        pixelBuffer = createPixelBuffer(from: transitionImage, context: context, outputSize: outputSize, attrs: attrs)
                        assetWriterAdaptor.append(pixelBuffer!, withPresentationTime: frameTime)
                        frameCount += 1
                    }
                }
            }
        }
        
        // Finish writing
        assetWriterInput.markAsFinished()
        assetWriter.finishWriting {
            print("Finished video location: \(outputMovieURL)")
        }
        
        return outputMovieURL
    }

    private func createPixelBuffer(from ciImage: CIImage, context: CIContext, outputSize: CGSize, attrs: CFDictionary) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                            Int(outputSize.width),
                            Int(outputSize.height),
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
        context.render(ciImage, to: pixelBuffer!)
        return pixelBuffer
    }

    private func blendImages(from image1: CIImage, to image2: CIImage, alpha: CGFloat) -> CIImage {
        let overlayImage = image1.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0, y: 0, z: 0, w: alpha),
            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: alpha),
            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: alpha),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: alpha)
        ])
        return image2.composited(over: overlayImage)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedPhotos: [UIImage]
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.selectedPhotos.removeAll()
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedPhotos.append(image)
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

struct MusicPicker: View {
    @Binding var selectedMusic: URL?
    
    let musicLibrary: [URL] = [URL(string: "https://github.com/rafaelreis-hotmart/Audio-Sample-files/raw/master/sample.mp4")!] // Add your open-source music URLs here
    
    var body: some View {
        List(musicLibrary, id: \.self) { music in
            Button(action: {
                selectedMusic = music
            }) {
                Text(music.lastPathComponent)
            }
        }
    }
}

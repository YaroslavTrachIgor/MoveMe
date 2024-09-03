//
//  VideoRenderingManager.swift
//  MoveMe
//
//  Created by User on 2024-07-30.
//

import Foundation
import AVKit
import AVFoundation
import CoreMedia
import QuartzCore

//MARK: - Main Manager
final class VideoRenderingManager {
    
    //MARK: Private
    private var tempURLs: [URL] = []
    
    //MARK: Static
    static let shared = VideoRenderingManager()
    
    
    
    
    
    
    //MARK: - Get Temp URLs
    /// - Returns: array of temp video components of the final video
    func getTempURLs() -> [URL] {
        return tempURLs
    }
    
    
    
    
    
    
    
    
    
    //MARK: - Scale/Crop Image
    /// Scales and crops a `CIImage` to the specified size.
    ///
    /// This function scales the input image proportionally so that it fits the target size
    /// while maintaining its aspect ratio. It then crops the scaled image to exactly match
    /// the specified size, ensuring that the image is centered in the resulting output.
    ///
    /// - Parameters:
    ///   - image: The `CIImage` to be scaled and cropped.
    ///   - size: The target `CGSize` to which the image should be scaled and cropped.
    /// - Returns: A new `CIImage` that has been scaled and cropped to the specified size.
    func scaleAndCropImage(_ image: CIImage, to size: CGSize) -> CIImage {
        let scaleX = size.width / image.extent.width
        let scaleY = size.height / image.extent.height
        let scale = max(scaleX, scaleY)
        
        let scaledImage = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        let centeredImage = scaledImage.transformed(by: CGAffineTransform(translationX: (size.width - scaledImage.extent.width) / 2, y: (size.height - scaledImage.extent.height) / 2))
        
        return centeredImage.cropped(to: CGRect(origin: .zero, size: size))
    }
    
    
    
    
    
    
    
    // MARK: - Check and Convert HDR to SDR
    /// Checks if a video contains HDR content and converts it to SDR if necessary.
    ///
    /// This function checks whether the input video has HDR content. If HDR content is found,
    /// it transcodes the video to SDR using the `transcodeVideo` function. If no HDR content is detected,
    /// the original video URL is returned.
    ///
    /// - Parameters:
    ///   - inputVideoURL: The URL of the video to check for HDR content.
    ///   - completion: A completion handler that is called with a `Result` containing either the
    ///     SDR-converted video URL or an `Error` if the conversion process failed.
    private func checkAndConvertHDRToSDR(inputVideoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        var isHdrVideo = false
        let pVideoTrack = AVAsset(url: inputVideoURL)
        
        if #available(iOS 14.0, *) {
            let tracks = pVideoTrack.tracks(withMediaCharacteristic: .containsHDRVideo)
            for track in tracks {
                isHdrVideo = track.hasMediaCharacteristic(.containsHDRVideo)
                if isHdrVideo {
                    break
                }
            }
        }
        
        if isHdrVideo {
            let sdrOutputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "_SDR.mov")
            transcodeVideo(using: inputVideoURL, outputVideoURL: sdrOutputURL) { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(inputVideoURL))
        }
    }
    
    
    
    
    
    
    
    
    /// Transcodes a video from the given input URL to the specified output URL using a 1080p preset.
    ///
    /// - Parameters:
    ///   - inputVideoURL: The URL of the input video file.
    ///   - outputVideoURL: The URL where the transcoded video will be saved.
    ///
    /// This function creates an `AVAssetExportSession` to transcode the video to a 1080p resolution.
    /// It also monitors the export progress using a helper function, `reportProgressForAsyncExportSessionAndWait`.
    /// If the export session cannot be created, an error message is printed.
    private func transcodeVideo(using inputVideoURL: URL, outputVideoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlAsset = AVURLAsset(url: inputVideoURL)
        
        guard let exporter = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1920x1080) else {
            completion(.failure(NSError(domain: "VideoProcessing", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])))
            return
        }
        
        exporter.outputURL = outputVideoURL
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = true
        
        exporter.exportAsynchronously {
            switch exporter.status {
            case .completed:
                completion(.success(outputVideoURL))
            case .failed:
                completion(.failure(exporter.error ?? NSError(domain: "VideoProcessing", code: 8, userInfo: [NSLocalizedDescriptionKey: "Export failed"])))
            case .cancelled:
                completion(.failure(NSError(domain: "VideoProcessing", code: 9, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"])))
            default:
                completion(.failure(NSError(domain: "VideoProcessing", code: 10, userInfo: [NSLocalizedDescriptionKey: "Export ended with unexpected status: \(exporter.status.rawValue)"])))
            }
        }
    }
    
    
    
    
    
    
    
    /// Checks if the video at the specified URL contains HDR content.
    ///
    /// - Parameter assetURL: The file path of the video asset as a `String`.
    /// - Returns: A `Bool` indicating whether the video contains HDR content.
    ///
    /// This function uses the `AVAsset` class to load the video asset and checks
    /// if any of the tracks in the asset have the `.containsHDRVideo` media characteristic.
    /// It is available on devices running iOS 14.0 or later.
    func checkIfHDRVideo(for assetURL: String) -> Bool {
        var isHdrVideo = false
        let pVideoTrack = AVAsset(url: URL(fileURLWithPath: assetURL))
        
        if #available(iOS 14.0, *) {
            let tracks = pVideoTrack.tracks(withMediaCharacteristic: .containsHDRVideo)
            for track in tracks {
                if track.hasMediaCharacteristic(.containsHDRVideo) {
                    isHdrVideo = true
                    break
                }
            }
        }
        
        return isHdrVideo
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - Crop Video Asset
    /// Crops a video based on the specified `Slide` parameters and returns the cropped video as a `MediaAsset`.
    ///
    /// This function takes an input video asset, crops it according to the specified slide's duration,
    /// applies any necessary transformations, and exports the cropped video to a temporary file.
    /// The function then returns the resulting `MediaAsset` through the completion handler.
    ///
    /// - Parameters:
    ///   - asset: The original `MediaAsset` containing the video to be cropped.
    ///   - slide: The `Slide` object that defines the duration and other parameters for cropping.
    ///   - completion: A completion handler that is called with a `Result` containing either the
    ///     successfully cropped `MediaAsset` or an `Error` if the cropping process failed.
    func cropVideo(asset: MediaAsset, slide: Slide, completion: @escaping (Result<MediaAsset, Error>) -> Void) {
        guard let videoAsset = asset.videoAsset as? AVURLAsset else {
            completion(.failure(NSError(domain: "VideoProcessing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Video asset is not available or not of type AVURLAsset"])))
            return
        }
        
        let composition = AVMutableComposition()
        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(.failure(NSError(domain: "VideoProcessing", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to add composition track"])))
            return
        }
        
        let duration = CMTime(seconds: slide.duration, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: .zero, duration: min(duration, videoAsset.duration))
        
        do {
            let sourceTrack = videoAsset.tracks(withMediaType: .video)[0]
            try compositionTrack.insertTimeRange(timeRange, of: sourceTrack, at: .zero)
            
            // Get the source track's dimensions and transform
            let sourceSize = sourceTrack.naturalSize
            let transform = sourceTrack.preferredTransform
            
            // Calculate the actual size after applying the transform
            let transformedSize = sourceSize.applying(transform)
            let videoSize = CGSize(width: abs(transformedSize.width), height: abs(transformedSize.height))
            
            // Create a video composition
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
            layerInstruction.setTransform(transform, at: .zero)
            
            instruction.layerInstructions = [layerInstruction]
            videoComposition.instructions = [instruction]
            
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                completion(.failure(NSError(domain: "VideoProcessing", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])))
                return
            }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            exportSession.timeRange = timeRange
            exportSession.videoComposition = videoComposition
            
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    self.checkAndConvertHDRToSDR(inputVideoURL: outputURL) { result in
                        switch result {
                        case .success(let sdrVideoURL):
                            let croppedAsset = AVURLAsset(url: sdrVideoURL)
                            var newMediaAsset = MediaAsset(asset: asset.asset!)
                            newMediaAsset.videoAsset = croppedAsset
                            newMediaAsset.id = asset.id
                            
                            // Generate thumbnail
                            self.generateThumbnail(for: croppedAsset) { thumbnail in
                                newMediaAsset.thumbnail = thumbnail
                                completion(.success(newMediaAsset))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failed:
                    completion(.failure(exportSession.error ?? NSError(domain: "VideoProcessing", code: 4, userInfo: [NSLocalizedDescriptionKey: "Export failed"])))
                case .cancelled:
                    completion(.failure(NSError(domain: "VideoProcessing", code: 5, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"])))
                default:
                    completion(.failure(NSError(domain: "VideoProcessing", code: 6, userInfo: [NSLocalizedDescriptionKey: "Export ended with unexpected status: \(exportSession.status.rawValue)"])))
                }
                
                // Remove the temporary file if it still exists (in case of failure or cancellation)
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    do {
                        try FileManager.default.removeItem(at: outputURL)
                        print("Temporary file removed: \(outputURL)")
                    } catch {
                        print("Error removing temporary file: \(error)")
                    }
                }
            }
        } catch {
            completion(.failure(error))
            return
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - Generate Video Thumbnail
    /// Generates a thumbnail image from a given video asset.
    ///
    /// This function extracts a frame from the beginning of the video to create a thumbnail image.
    /// The thumbnail is generated asynchronously and returned through the completion handler.
    /// If there is an error during the thumbnail generation, the completion handler will be called with `nil`.
    ///
    /// - Parameters:
    ///   - asset: The `AVAsset` representing the video from which the thumbnail should be generated.
    ///   - completion: A closure that is called with an optional `UIImage` representing the thumbnail, or `nil` if the thumbnail generation fails.
    func generateThumbnail(for asset: AVAsset, completion: @escaping (UIImage?) -> Void) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 600)
        
        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
            if let error = error {
                print("Error generating thumbnail: \(error.localizedDescription)")
                completion(nil)
            } else if let cgImage = cgImage {
                let thumbnail = UIImage(cgImage: cgImage)
                completion(thumbnail)
            } else {
                completion(nil)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - Create Video from UIImages
    /// Creates a video from a sequence of images, with each image displayed for a specified duration, and saves it to a file.
    ///
    /// This function takes an array of images and their corresponding display durations, creates a video of the specified size and frame rate, and writes it to the specified output file.
    /// The function also reports the progress of the video creation process through a closure.
    ///
    /// - Parameters:
    ///   - images: An array of `UIImage` objects representing the frames of the video.
    ///   - durations: An array of `Double` values representing the duration (in seconds) each image should be displayed in the video. The array should be the same length as the `images` array.
    ///   - outputSize: The size of the output video in points. The function scales this size by 1.5 to produce a high-resolution output.
    ///   - frameRate: The frame rate (frames per second) for the video.
    ///   - outputFileName: The name of the output video file (without the file extension).
    ///   - progressHandler: A closure that receives a `Double` value representing the progress of the video creation, where `0.0` is no progress and `1.0` is 100% complete.
    ///
    /// - Throws: An error of type `ConstructionError` if the output URL cannot be created or if the asset writer fails to initialize.
    ///
    /// - Returns: A `URL` pointing to the location of the created video file.
    func createVideoFromImages(images: [UIImage], durations: [Double], outputSize: CGSize, frameRate: Int32, outputFileName: String, progressHandler: @escaping (Double) -> Void) throws -> URL {
        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(outputFileName).mov") else {
            throw ConstructionError.invalidURL
        }
        
        try? FileManager.default.removeItem(at: outputMovieURL)
        
        guard let assetWriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov) else {
            throw ConstructionError.invalidURL
        }
        
        let highResOutputSize = CGSize(width: outputSize.width * 1.5, height: outputSize.height * 1.5)
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: highResOutputSize.width,
            AVVideoHeightKey: highResOutputSize.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 10_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                AVVideoH264EntropyModeKey: AVVideoH264EntropyModeCABAC
            ]
        ]
        
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterInput.expectsMediaDataInRealTime = true
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: highResOutputSize.width,
            kCVPixelBufferHeightKey as String: highResOutputSize.height,
            kCVPixelFormatOpenGLESCompatibility as String: true
        ]
        
        let assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        
        assetWriter.add(assetWriterInput)
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        let context = CIContext()
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var frameCount = 0
        let totalFrames = durations.reduce(0) { $0 + Int($1 * Double(frameRate)) }
        
        for (index, image) in images.enumerated() {
            autoreleasepool {
                guard let ciImage = CIImage(image: image) else { return }
                
                let framesForSlide = Int(durations[index] * Double(frameRate))
                for _ in 0..<framesForSlide {
                    if assetWriterInput.isReadyForMoreMediaData {
                        let frameTime = CMTimeMake(value: Int64(frameCount), timescale: frameRate)
                        if let pixelBuffer = createPixelBuffer(from: ciImage, context: context, outputSize: highResOutputSize, attrs: attrs) {
                            assetWriterAdaptor.append(pixelBuffer, withPresentationTime: frameTime)
                            frameCount += 1
                            
                            // Report progress for each frame
                            let progress = Double(frameCount) / Double(totalFrames)
                            DispatchQueue.main.async {
                                progressHandler(progress)
                            }
                        }
                    }
                }
            }
        }
        
        assetWriterInput.markAsFinished()
        
        let semaphore = DispatchSemaphore(value: 0)
        assetWriter.finishWriting {
            print("Finished video location: \(outputMovieURL)")
            semaphore.signal()
        }
        semaphore.wait()
        
        return outputMovieURL
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - Create PixelBuffer for Images
    /// Creates a pixel buffer from a given `CIImage` by scaling and cropping the image to the specified output size.
    ///
    /// This function creates a `CVPixelBuffer` and renders the provided `CIImage` into it using the given `CIContext`.
    /// The image is first scaled and cropped to match the output size, and then rendered into the pixel buffer.
    ///
    /// - Parameters:
    ///   - ciImage: The `CIImage` that will be rendered into the pixel buffer.
    ///   - context: The `CIContext` used for rendering the image.
    ///   - outputSize: The desired size of the output pixel buffer.
    ///   - attrs: A `CFDictionary` containing attributes for creating the pixel buffer.
    ///
    /// - Returns: A `CVPixelBuffer?` containing the rendered image, or `nil` if the pixel buffer could not be created.
    func createPixelBuffer(from ciImage: CIImage, context: CIContext, outputSize: CGSize, attrs: CFDictionary) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(outputSize.width), Int(outputSize.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        
        if let pixelBuffer = pixelBuffer {
            let scaledImage = scaleAndCropImage(ciImage, to: outputSize)
            context.render(scaledImage, to: pixelBuffer, bounds: scaledImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        }
        
        return pixelBuffer
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - Combine Videos
    /// Combines multiple video assets into a single video with optional audio, transformations, and progress tracking.
    ///
    /// This function takes a list of video assets and combines them into a single video file, optionally applying a zoom effect,
    /// scaling, and centering the video according to a specified template. It also supports adding an external audio track and
    /// includes options for keeping the original audio from the video assets. Progress is reported periodically during the export process.
    ///
    /// - Parameters:
    ///   - template: The `Template` object specifying how the video assets should be combined.
    ///   - videoAssets: An array of `AVAsset` objects representing the videos to be combined.
    ///   - durations: An array of `Double` values specifying the duration (in seconds) for each video segment.
    ///   - outputSize: The desired output size of the final video.
    ///   - outputFileName: The name of the output video file (without extension).
    ///   - audioURL: An optional `URL` pointing to an external audio file to be added to the video.
    ///   - audioStartTime: The start time (in seconds) for the external audio track.
    ///   - audioEndTime: The end time (in seconds) for the external audio track.
    ///   - includeOriginalAudio: A `Bool` indicating whether to include the original audio from the video assets.
    ///   - progressHandler: A closure that is called periodically with the export progress (0.0 to 1.0).
    ///   - completion: A closure that is called upon completion with a `Result<URL, Error>`. On success, it provides the output URL of the combined video. On failure, it provides an error.
    ///
    /// - Throws: This function does not throw errors directly, but errors can be returned in the completion handler.
    ///
    /// - Note: The video is exported in `.mov` format with a resolution of 1920x1080. If the device supports iOS 14.0 or later, the export session can perform multiple passes over the source media data.
    func combineVideos(template: Template, videoAssets: [AVAsset], durations: [Double], outputSize: CGSize, outputFileName: String, audioURL: URL?, audioStartTime: Double, audioEndTime: Double, includeOriginalAudio: Bool, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = outputSize
        
        var insertTime = CMTime.zero
        var instructions: [AVMutableVideoCompositionInstruction] = []
        
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAudioTrack = includeOriginalAudio ? composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) : nil
        
        /// Process the rest of the video assets
        for (index, asset) in videoAssets.enumerated() {
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("No video track found for asset at index \(index)")
                continue
            }
            
            do {
                
                if template.id == Template.list[0].id {
                    
                    
                    //MARK: - Template 1
                    let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
                    let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
                    try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
                    
                    let instruction = AVMutableVideoCompositionInstruction()
                    instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
                    
                    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
                    let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                    let scaleX = outputSize.width / abs(assetTrackSize.width)
                    let scaleY = outputSize.height / abs(assetTrackSize.height)
                    let scale = max(scaleX, scaleY)
                    var transform = CGAffineTransform(scaleX: scale, y: scale)
                    let xTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
                    let yTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
                    transform = transform.translatedBy(x: xTranslation, y: yTranslation)
                    
                    transform = transform.concatenating(videoTrack.preferredTransform)
                    
                    layerInstruction.setTransform(transform, at: .zero)
                    instruction.layerInstructions = [layerInstruction]
                    instructions.append(instruction)
                    
                    if includeOriginalAudio, let audioTrack = asset.tracks(withMediaType: .audio).first {
                        do {
                            try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
                        } catch {
                            print("Error inserting original audio track: \(error)")
                        }
                    }
                    
                    insertTime = CMTimeAdd(insertTime, timeRange.duration)
                    
                    
                    
                    
                    
                } else if template.id == Template.list[1].id {
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    //MARK: - Template 2
                    
                    if index == 2 {
                        guard let compositionVideoTrack = compositionVideoTrack else {
                            continue
                        }
                        
                        let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
                        let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
                        try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
                        
                        let instruction = AVMutableVideoCompositionInstruction()
                        instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
                        
                        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
                        
                        let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                        let scaleX = outputSize.width / abs(assetTrackSize.width)
                        let scaleY = outputSize.height / abs(assetTrackSize.height)
                        let scale = max(scaleX, scaleY)
                        
                        // Create keyframe animations for zoom effect
                        let zoomDuration = timeRange.duration
                        let zoomStartTime = insertTime
                        let zoomEndTime = CMTimeAdd(zoomStartTime, zoomDuration)
                        
                        var startTransform = CGAffineTransform(scaleX: scale, y: scale)
                        var endTransform = CGAffineTransform(scaleX: scale * 1.2, y: scale * 1.2)
                        
                        // Center the video
                        let startXTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
                        let startYTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
                        startTransform = startTransform.translatedBy(x: startXTranslation, y: startYTranslation)
                        
                        let endXTranslation = (outputSize.width - assetTrackSize.width * scale * 1.2) / 2
                        let endYTranslation = (outputSize.height - assetTrackSize.height * scale * 1.2) / 2
                        endTransform = endTransform.translatedBy(x: endXTranslation, y: endYTranslation)
                        
                        // Apply zoom effect
                        layerInstruction.setTransformRamp(fromStart: startTransform, toEnd: endTransform, timeRange: CMTimeRange(start: zoomStartTime, duration: zoomDuration))
                        
                        instruction.layerInstructions = [layerInstruction]
                        instructions.append(instruction)
                        
                        if let audioTrack = asset.tracks(withMediaType: .audio).first {
                            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .audio)[index]
                            try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
                        }
                        
                        insertTime = CMTimeAdd(insertTime, timeRange.duration)
                    } else {
                        let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
                        let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
                        try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
                        
                        let instruction = AVMutableVideoCompositionInstruction()
                        instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
                        
                        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
                        let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                        let scaleX = outputSize.width / abs(assetTrackSize.width)
                        let scaleY = outputSize.height / abs(assetTrackSize.height)
                        let scale = max(scaleX, scaleY)
                        var transform = CGAffineTransform(scaleX: scale, y: scale)
                        let xTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
                        let yTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
                        transform = transform.translatedBy(x: xTranslation, y: yTranslation)
                        
                        transform = transform.concatenating(videoTrack.preferredTransform)
                        
                        layerInstruction.setTransform(transform, at: .zero)
                        instruction.layerInstructions = [layerInstruction]
                        instructions.append(instruction)
                        
                        if includeOriginalAudio, let audioTrack = asset.tracks(withMediaType: .audio).first {
                            do {
                                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
                            } catch {
                                print("Error inserting original audio track: \(error)")
                            }
                        }
                        
                        insertTime = CMTimeAdd(insertTime, timeRange.duration)
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                } else if template.id == Template.list[2].id {
                    
                    //MARK: - Template 3
                    guard let compositionVideoTrack = compositionVideoTrack else {
                        continue
                    }
                    
                    let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
                    let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
                    try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
                    
                    let instruction = AVMutableVideoCompositionInstruction()
                    instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
                    
                    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
                    
                    let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                    let scaleX = outputSize.width / abs(assetTrackSize.width)
                    let scaleY = outputSize.height / abs(assetTrackSize.height)
                    let scale = max(scaleX, scaleY)
                    
                    // Create keyframe animations for zoom effect
                    let zoomDuration = timeRange.duration
                    let zoomStartTime = insertTime
                    let zoomEndTime = CMTimeAdd(zoomStartTime, zoomDuration)
                    
                    var startTransform = CGAffineTransform(scaleX: scale, y: scale)
                    var endTransform = CGAffineTransform(scaleX: scale * 1.2, y: scale * 1.2)
                    
                    // Center the video
                    let startXTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
                    let startYTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
                    startTransform = startTransform.translatedBy(x: startXTranslation, y: startYTranslation)
                    
                    let endXTranslation = (outputSize.width - assetTrackSize.width * scale * 1.2) / 2
                    let endYTranslation = (outputSize.height - assetTrackSize.height * scale * 1.2) / 2
                    endTransform = endTransform.translatedBy(x: endXTranslation, y: endYTranslation)
                    
                    // Apply zoom effect
                    layerInstruction.setTransformRamp(fromStart: startTransform, toEnd: endTransform, timeRange: CMTimeRange(start: zoomStartTime, duration: zoomDuration))
                    
                    instruction.layerInstructions = [layerInstruction]
                    instructions.append(instruction)
                    
                    if let audioTrack = asset.tracks(withMediaType: .audio).first {
                        let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .audio)[index]
                        try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
                    }
                    
                    insertTime = CMTimeAdd(insertTime, timeRange.duration)
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                } else if template.id == Template.list[3].id {
                    
                    //MARK: - Template 4
                    
                    let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
                    let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
                    try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
                    
                    let instruction = AVMutableVideoCompositionInstruction()
                    instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
                    
                    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
                    let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                    let scaleX = outputSize.width / abs(assetTrackSize.width)
                    let scaleY = outputSize.height / abs(assetTrackSize.height)
                    let scale = max(scaleX, scaleY)
                    var transform = CGAffineTransform(scaleX: scale, y: scale)
                    let xTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
                    let yTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
                    transform = transform.translatedBy(x: xTranslation, y: yTranslation)
                    
                    transform = transform.concatenating(videoTrack.preferredTransform)
                    
                    layerInstruction.setTransform(transform, at: .zero)
                    
                    let fadeDuration = CMTime(seconds: 0.5, preferredTimescale: 600)
                    
                    // Add fade-in effect only for the first video segment
                    if index == 0 {
                        layerInstruction.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0, timeRange: CMTimeRange(start: insertTime, duration: fadeDuration))
                    }
                    
                    // Add fade-out effect only for the last video segment
                    if index == videoAssets.count - 1 {
                        let fadeOutStartTime = CMTimeSubtract(CMTimeAdd(insertTime, timeRange.duration), fadeDuration)
                        layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange(start: fadeOutStartTime, duration: fadeDuration))
                    }
                    
                    instruction.layerInstructions = [layerInstruction]
                    instructions.append(instruction)
                    
                    if includeOriginalAudio, let audioTrack = asset.tracks(withMediaType: .audio).first {
                        do {
                            try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
                        } catch {
                            print("Error inserting original audio track: \(error)")
                        }
                    }
                    
                    insertTime = CMTimeAdd(insertTime, timeRange.duration)
                    
                    
                    
                
                    
                    
                    
                    
                    
                } else {
                    
                    //MARK: - Template 5
                    let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
                    let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
                    try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
                    
                    let instruction = AVMutableVideoCompositionInstruction()
                    instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
                    
                    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
                    let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                    let scaleX = outputSize.width / abs(assetTrackSize.width)
                    let scaleY = outputSize.height / abs(assetTrackSize.height)
                    let scale = max(scaleX, scaleY)
                    var transform = CGAffineTransform(scaleX: scale, y: scale)
                    let xTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
                    let yTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
                    transform = transform.translatedBy(x: xTranslation, y: yTranslation)
                    
                    transform = transform.concatenating(videoTrack.preferredTransform)
                    
                    layerInstruction.setTransform(transform, at: .zero)
                    instruction.layerInstructions = [layerInstruction]
                    instructions.append(instruction)
                    
                    if includeOriginalAudio, let audioTrack = asset.tracks(withMediaType: .audio).first {
                        do {
                            try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
                        } catch {
                            print("Error inserting original audio track: \(error)")
                        }
                    }
                    
                    insertTime = CMTimeAdd(insertTime, timeRange.duration)
                }
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
            } catch {
                print("Error inserting video track: \(error)")
                completion(.failure(error))
                return
            }
        }
        
        videoComposition.instructions = instructions
        
        // Add background audio if provided
        if let audioURL = audioURL {
            let audioAsset = AVAsset(url: audioURL)
            if let audioTrack = audioAsset.tracks(withMediaType: .audio).first {
                let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                
                let totalDuration = CMTimeGetSeconds(composition.duration)
                let audioDuration = min(audioEndTime - audioStartTime, totalDuration)
                let audioTimeRange = CMTimeRangeMake(start: CMTime(seconds: audioStartTime, preferredTimescale: 600), duration: CMTime(seconds: audioDuration, preferredTimescale: 600))
                
                do {
                    try audioCompositionTrack.insertTimeRange(audioTimeRange, of: audioTrack, at: .zero)
                } catch {
                    print("Error inserting audio track: \(error)")
                    completion(.failure(error))
                    return
                }
            } else {
                print("No audio track found in the provided audio asset")
            }
        }
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName + ".mov")
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVC1920x1080) else {
            print("Failed to create export session")
            completion(.failure(ConstructionError.exportFailed))
            return
        }
        
        
        // Set HDR to SDR conversion properties
        if #available(iOS 14.0, *) {
            exportSession.canPerformMultiplePassesOverSourceMediaData = true
        }
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.videoComposition = videoComposition
        
        // Create a timer to periodically check and report progress
        var progressTimer: Timer?
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let progress = exportSession.progress
            DispatchQueue.main.async {
                progressHandler(Double(progress))
            }
        }
        
        exportSession.exportAsynchronously {
            progressTimer?.invalidate()
            
            switch exportSession.status {
            case .completed:
                completion(.success(outputURL))
            case .failed:
                print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                if let error = exportSession.error as NSError? {
                    print("Error domain: \(error.domain)")
                    print("Error code: \(error.code)")
                    print("Error user info: \(error.userInfo)")
                }
                completion(.failure(exportSession.error ?? ConstructionError.exportFailed))
            case .cancelled:
                print("Export cancelled")
                completion(.failure(ConstructionError.exportFailed))
            default:
                print("Unexpected export status: \(exportSession.status.rawValue)")
                completion(.failure(ConstructionError.exportFailed))
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - Final Video Render
    /// Creates a final video by combining a series of media assets (images and videos) according to a specified template,
    /// applying transformations, and adding an optional background audio track.
    ///
    /// This function processes a list of media assets (images and videos) based on the provided template, creates video segments
    /// from images, and combines everything into a final video file. It also supports adding background audio and tracks
    /// the progress of the entire video creation process, reporting it back to the caller.
    ///
    /// - Parameters:
    ///   - mediaAssets: An array of `MediaAsset` objects, where each asset could be either an image or a video.
    ///   - template: The `Template` object that dictates how the media assets are combined, including effects, durations, and order.
    ///   - outputSize: The desired output size of the final video.
    ///   - frameRate: The frame rate for the video. Defaults to 30 fps.
    ///   - outputFileName: The name of the final output video file (without extension).
    ///   - audioURL: An optional `URL` pointing to an external audio file to be added as background music.
    ///   - audioStartTime: The start time (in seconds) for the external audio track.
    ///   - audioEndTime: The end time (in seconds) for the external audio track.
    ///   - progressHandler: A closure that is called periodically with the overall progress (0.0 to 1.0) of the video creation process.
    ///   - completion: A closure that is called upon completion with a `Result<URL, Error>`. On success, it provides the URL of the final video. On failure, it provides an error.
    ///
    /// - Throws: This function does not throw errors directly, but errors can be returned in the completion handler.
    ///
    /// - Note: Temporary video files created during the process are automatically deleted upon completion.
    func createFinalVideo(from mediaAssets: [MediaAsset], template: Template, outputSize: CGSize, frameRate: Int32 = 30, outputFileName: String, audioURL: URL?, audioStartTime: Double, audioEndTime: Double, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        var tempURLsArrayToSort: [String: AVAsset] = [:]
        var tempURLsDurationToSort: [String: Double] = [:]

        tempURLs = []

        let totalSteps = Double(mediaAssets.count + 1) // +1 for final combination
        var currentStep = 0.0

        func updateProgress(_ stepProgress: Double) {
            let overallProgress = (currentStep + stepProgress) / totalSteps
            DispatchQueue.main.async {
                progressHandler(overallProgress)
            }
        }

        let processingGroup = DispatchGroup()

        for (index, mediaAsset) in mediaAssets.enumerated() {
            processingGroup.enter()

            if index >= template.slides.count {
                processingGroup.leave()
                continue
            }

            let slide = template.slides[index]
            let outputFileName = "temp_video_slide_\(index)"

            if slide.isVideo {
                if let videoAsset = mediaAsset.videoAsset {
                    tempURLsArrayToSort[outputFileName] = videoAsset
                    tempURLsDurationToSort[outputFileName] = slide.duration
                    processingGroup.leave()
                } else {
                    processingGroup.leave()
                }
            } else {
                if let image = mediaAsset.fullSizeImage ?? mediaAsset.thumbnail {
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            let imageVideoURL = try self.createVideoFromImages(images: [image], durations: [slide.duration], outputSize: outputSize, frameRate: frameRate, outputFileName: outputFileName, progressHandler: { imageProgress in
                                updateProgress(imageProgress / Double(totalSteps))
                            })
                            let imageVideoAsset = AVAsset(url: imageVideoURL)
                            tempURLsArrayToSort[outputFileName] = imageVideoAsset
                            tempURLsDurationToSort[outputFileName] = slide.duration
                            self.tempURLs.append(imageVideoURL)
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                        processingGroup.leave()
                    }
                } else {
                    processingGroup.leave()
                }
            }

            currentStep += 1
            updateProgress(0)
        }

        processingGroup.notify(queue: .main) {
            // Sort the assets and durations based on the index in the filename
            let sortedKeys = tempURLsArrayToSort.keys.sorted {
                let index1 = Int($0.components(separatedBy: "_").last ?? "") ?? 0
                let index2 = Int($1.components(separatedBy: "_").last ?? "") ?? 0
                return index1 < index2
            }

            let allAssets = sortedKeys.compactMap { tempURLsArrayToSort[$0] }
            let allDurations = sortedKeys.compactMap { tempURLsDurationToSort[$0] }

            self.combineVideos(template: template, videoAssets: allAssets, durations: allDurations, outputSize: outputSize, outputFileName: outputFileName, audioURL: audioURL, audioStartTime: audioStartTime, audioEndTime: audioEndTime, includeOriginalAudio: audioURL != nil, progressHandler: { combineProgress in
                updateProgress(combineProgress)
            }) { result in
                for url in self.tempURLs {
                    try? FileManager.default.removeItem(at: url)
                }

                switch result {
                case .success(let finalVideoURL):
                    updateProgress(0.99)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        completion(.success(finalVideoURL))
                        updateProgress(1)
                        self.tempURLs.append(finalVideoURL)
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    
//    
//    func combineVideosAppearingEffect(videoAssets: [AVAsset], durations: [Double], outputSize: CGSize, outputFileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        let composition = AVMutableComposition()
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//        videoComposition.renderSize = outputSize
//        
//        var insertTime = CMTime.zero
//        var instructions: [AVMutableVideoCompositionInstruction] = []
//        
//        for (index, asset) in videoAssets.enumerated() {
//            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
//                print("No video track found for asset at index \(index)")
//                continue
//            }
//            
//            let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .video)[index]
//            
//            do {
//                let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
//                let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
//                try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
//                
//                let instruction = AVMutableVideoCompositionInstruction()
//                instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
//                
//                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
//                
//                let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
//                let scaleX = outputSize.width / abs(assetTrackSize.width)
//                let scaleY = outputSize.height / abs(assetTrackSize.height)
//                let scale = max(scaleX, scaleY)
//                
//                // Create keyframe animations for zoom effect
//                let zoomDuration = timeRange.duration
//                let zoomStartTime = insertTime
//                let zoomEndTime = CMTimeAdd(zoomStartTime, zoomDuration)
//                
//                var startTransform = CGAffineTransform(scaleX: scale, y: scale)
//                var endTransform = CGAffineTransform(scaleX: scale * 1.2, y: scale * 1.2)
//                
//                // Center the video
//                let startXTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
//                let startYTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
//                startTransform = startTransform.translatedBy(x: startXTranslation, y: startYTranslation)
//                
//                let endXTranslation = (outputSize.width - assetTrackSize.width * scale * 1.2) / 2
//                let endYTranslation = (outputSize.height - assetTrackSize.height * scale * 1.2) / 2
//                endTransform = endTransform.translatedBy(x: endXTranslation, y: endYTranslation)
//                
//                // Apply zoom effect
//                layerInstruction.setTransformRamp(fromStart: startTransform, toEnd: endTransform, timeRange: CMTimeRange(start: zoomStartTime, duration: zoomDuration))
//                
//                // Add appearing effect for the first video
//                if index == 0 {
//                    let appearingDuration = CMTime(seconds: 1.5, preferredTimescale: 600)
//                    let endTime = CMTimeAdd(insertTime, appearingDuration)
//                    
//                    layerInstruction.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0, timeRange: CMTimeRange(start: insertTime, end: endTime))
//                    
//                    // Create a black solid color video track
//                    let blackTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//                    let blackVideoURL = createBlackVideoAsset(size: outputSize, duration: appearingDuration)
//                    let blackAsset = AVAsset(url: blackVideoURL)
//                    if let blackVideoTrack = blackAsset.tracks(withMediaType: .video).first {
//                        try blackTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: appearingDuration), of: blackVideoTrack, at: insertTime)
//                    }
//                    
//                    let blackLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: blackTrack!)
//                    blackLayerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange(start: insertTime, end: endTime))
//                    
//                    instruction.layerInstructions = [blackLayerInstruction, layerInstruction]
//                } else {
//                    instruction.layerInstructions = [layerInstruction]
//                }
//                
//                instructions.append(instruction)
//                
//                if let audioTrack = asset.tracks(withMediaType: .audio).first {
//                    let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .audio)[index]
//                    try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
//                }
//                
//                insertTime = CMTimeAdd(insertTime, timeRange.duration)
//            } catch {
//                print("Error inserting video track: \(error)")
//                completion(.failure(error))
//                return
//            }
//        }
//        
//        videoComposition.instructions = instructions
//        
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName + ".mov")
//        
//        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
//            print("Failed to create export session")
//            completion(.failure(ConstructionError.exportFailed))
//            return
//        }
//        
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .mov
//        exportSession.videoComposition = videoComposition
//        
//        exportSession.exportAsynchronously {
//            switch exportSession.status {
//            case .completed:
//                completion(.success(outputURL))
//            case .failed:
//                print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
//                completion(.failure(exportSession.error ?? ConstructionError.exportFailed))
//            case .cancelled:
//                print("Export cancelled")
//                completion(.failure(ConstructionError.exportFailed))
//            default:
//                print("Unexpected export status: \(exportSession.status.rawValue)")
//                completion(.failure(ConstructionError.exportFailed))
//            }
//        }
//    }
//
//    
//    func createBlackVideoAsset(size: CGSize, duration: CMTime) -> URL {
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("black_video.mov")
//        
//        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else {
//            fatalError("Failed to create AVAssetWriter")
//        }
//        
//        let videoSettings: [String: Any] = [
//            AVVideoCodecKey: AVVideoCodecType.h264,
//            AVVideoWidthKey: size.width,
//            AVVideoHeightKey: size.height
//        ]
//        
//        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
//        writerInput.expectsMediaDataInRealTime = true
//        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
//        
//        writer.add(writerInput)
//        
//        writer.startWriting()
//        writer.startSession(atSourceTime: .zero)
//        
//        let blackImage = UIImage(color: .black, size: size)
//        guard let pixelBuffer = blackImage.pixelBuffer() else {
//            fatalError("Failed to create pixel buffer")
//        }
//        
//        let frameDuration = CMTimeMake(value: 1, timescale: 30)
//        var currentTime = CMTime.zero
//        
//        let queue = DispatchQueue(label: "com.example.blackvideowriter")
//        
//        let semaphore = DispatchSemaphore(value: 0)
//        
//        queue.async {
//            while currentTime < duration {
//                if writerInput.isReadyForMoreMediaData {
//                    if adaptor.append(pixelBuffer, withPresentationTime: currentTime) {
//                        currentTime = CMTimeAdd(currentTime, frameDuration)
//                    } else {
//                        fatalError("Failed to append pixel buffer")
//                    }
//                } else {
//                    Thread.sleep(forTimeInterval: 0.1)
//                }
//            }
//            
//            writerInput.markAsFinished()
//            writer.finishWriting {
//                print("Finished writing black video")
//                semaphore.signal()
//            }
//        }
//        
//        semaphore.wait()
//        
//        return outputURL
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//   
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    func combineVideosWithBlurTransitions(videoAssets: [AVAsset], durations: [Double], transitionDuration: Double, outputSize: CGSize, outputFileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        let composition = AVMutableComposition()
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//        videoComposition.renderSize = outputSize
//        
//        var insertTime = CMTime.zero
//        var instructions: [AVMutableVideoCompositionInstruction] = []
//        
//        for (index, asset) in videoAssets.enumerated() {
//            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
//                print("No video track found for asset at index \(index)")
//                continue
//            }
//            
//            let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .video)[index]
//            
//            do {
//                let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
//                let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
//                try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
//                
//                let instruction = AVMutableVideoCompositionInstruction()
//                instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
//                
//                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
//
//                let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
//                let scaleX = outputSize.width / abs(assetTrackSize.width)
//                let scaleY = outputSize.height / abs(assetTrackSize.height)
//                let scale = max(scaleX, scaleY)
//
//                var transform = CGAffineTransform(scaleX: scale, y: scale)
//
//                let xTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
//                let yTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
//                transform = transform.translatedBy(x: xTranslation, y: yTranslation)
//
//                layerInstruction.setTransform(transform, at: .zero)
//                instruction.layerInstructions = [layerInstruction]
//                instructions.append(instruction)
//                
//                if let audioTrack = asset.tracks(withMediaType: .audio).first {
//                    let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .audio)[index]
//                    try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
//                }
//                
//                insertTime = CMTimeAdd(insertTime, timeRange.duration)
//            } catch {
//                print("Error inserting video track: \(error)")
//                completion(.failure(error))
//                return
//            }
//        }
//        
//        videoComposition.instructions = instructions
//        
//        class BlurCompositor: NSObject, AVVideoCompositing {
//            let renderContextQueue = DispatchQueue(label: "com.yourapp.rendercontextqueue")
//            var renderContext: AVVideoCompositionRenderContext?
//            let ciContext = CIContext()
//            
//            var requiredPixelBufferAttributesForRenderContext: [String: Any] {
//                return [
//                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
//                    kCVPixelBufferMetalCompatibilityKey as String: true
//                ]
//            }
//            
//            var sourcePixelBufferAttributes: [String: Any]? {
//                return [
//                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
//                    kCVPixelBufferMetalCompatibilityKey as String: true
//                ]
//            }
//            
//            func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
//                renderContextQueue.sync {
//                    renderContext = newRenderContext
//                }
//            }
//            
//            func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
//                autoreleasepool {
//                    guard let resultPixels = asyncVideoCompositionRequest.renderContext.newPixelBuffer() else {
//                        asyncVideoCompositionRequest.finish(with: NSError(domain: "BlurCompositor", code: -1, userInfo: nil))
//                        return
//                    }
//                    
//                    guard let sourcePixels = asyncVideoCompositionRequest.sourceFrame(byTrackID: asyncVideoCompositionRequest.sourceTrackIDs[0].int32Value) else {
//                        asyncVideoCompositionRequest.finish(with: NSError(domain: "BlurCompositor", code: -1, userInfo: nil))
//                        return
//                    }
//                    
//                    let sourceImage = CIImage(cvPixelBuffer: sourcePixels)
//                    
//                    let time = asyncVideoCompositionRequest.compositionTime
//                    let instruction = asyncVideoCompositionRequest.videoCompositionInstruction
//                    let instructionTimeRange = instruction.timeRange
//                    
//                    let transitionDuration = 0.5 // Adjust this value to match your transition duration
//                    let isInTransition = time.seconds - instructionTimeRange.start.seconds < transitionDuration ||
//                                         instructionTimeRange.end.seconds - time.seconds < transitionDuration
//                    
//                    if isInTransition {
//                        let blurFilter = CIFilter(name: "CIGaussianBlur")!
//                        blurFilter.setValue(sourceImage, forKey: kCIInputImageKey)
//                        
//                        let progress: Double
//                        if time.seconds - instructionTimeRange.start.seconds < transitionDuration {
//                            progress = (time.seconds - instructionTimeRange.start.seconds) / transitionDuration
//                        } else {
//                            progress = (instructionTimeRange.end.seconds - time.seconds) / transitionDuration
//                        }
//                        
//                        let blurRadius = 20 * (1 - progress)
//                        blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
//                        
//                        if let blurredImage = blurFilter.outputImage {
//                            self.ciContext.render(blurredImage, to: resultPixels)
//                        } else {
//                            self.ciContext.render(sourceImage, to: resultPixels)
//                        }
//                    } else {
//                        self.ciContext.render(sourceImage, to: resultPixels)
//                    }
//                    
//                    asyncVideoCompositionRequest.finish(withComposedVideoFrame: resultPixels)
//                }
//            }
//            
//            func cancelAllPendingVideoCompositionRequests() {
//                // Implement if needed
//            }
//        }
//        
//        videoComposition.customVideoCompositorClass = BlurCompositor.self
//        
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName + ".mov")
//        
//        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
//            print("Failed to create export session")
//            completion(.failure(ConstructionError.exportFailed))
//            return
//        }
//        
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .mov
//        exportSession.videoComposition = videoComposition
//        
//        exportSession.exportAsynchronously {
//            switch exportSession.status {
//            case .completed:
//                completion(.success(outputURL))
//            case .failed:
//                print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
//                completion(.failure(exportSession.error ?? ConstructionError.exportFailed))
//            case .cancelled:
//                print("Export cancelled")
//                completion(.failure(ConstructionError.exportFailed))
//            default:
//                print("Unexpected export status: \(exportSession.status.rawValue)")
//                completion(.failure(ConstructionError.exportFailed))
//            }
//        }
//    }
//    
//    
//
//
//    func combineVideosWithTransitions(videoAssets: [AVAsset], durations: [Double], transitionDuration: Double, outputSize: CGSize, outputFileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        let composition = AVMutableComposition()
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//        videoComposition.renderSize = outputSize
//        
//        var insertTime = CMTime.zero
//        var instructions: [AVMutableVideoCompositionInstruction] = []
//        
//        for (index, asset) in videoAssets.enumerated() {
//            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
//                print("No video track found for asset at index \(index)")
//                continue
//            }
//            
//            let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .video)[index]
//            
//            do {
//                let assetDuration = CMTime(seconds: durations[index], preferredTimescale: 600)
//                let timeRange = CMTimeRangeMake(start: .zero, duration: min(assetDuration, asset.duration))
//                try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: insertTime)
//                
//                let instruction = AVMutableVideoCompositionInstruction()
//                instruction.timeRange = CMTimeRangeMake(start: insertTime, duration: timeRange.duration)
//                
//                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
//                
//                let assetTrackSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
//                let scaleX = outputSize.width / abs(assetTrackSize.width)
//                let scaleY = outputSize.height / abs(assetTrackSize.height)
//                let scale = max(scaleX, scaleY)
//                
//                var transform = CGAffineTransform(scaleX: scale, y: scale)
//                let xTranslation = (outputSize.width - assetTrackSize.width * scale) / 2
//                let yTranslation = (outputSize.height - assetTrackSize.height * scale) / 2
//                transform = transform.translatedBy(x: xTranslation, y: yTranslation)
//                
//                layerInstruction.setTransform(transform, at: .zero)
//                
//                // Add opacity transitions
//                if index > 0 {
//                    layerInstruction.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0, timeRange: CMTimeRangeMake(start: insertTime, duration: CMTime(seconds: transitionDuration, preferredTimescale: 600)))
//                }
//                if index < videoAssets.count - 1 {
//                    let fadeOutStart = CMTimeAdd(insertTime, CMTime(seconds: timeRange.duration.seconds - transitionDuration, preferredTimescale: 600))
//                    layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRangeMake(start: fadeOutStart, duration: CMTime(seconds: transitionDuration, preferredTimescale: 600)))
//                }
//                
//                instruction.layerInstructions = [layerInstruction]
//                instructions.append(instruction)
//                
//                if let audioTrack = asset.tracks(withMediaType: .audio).first {
//                    let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) ?? composition.tracks(withMediaType: .audio)[index]
//                    try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: insertTime)
//                }
//                
//                insertTime = CMTimeAdd(insertTime, timeRange.duration)
//            } catch {
//                print("Error inserting video track: \(error)")
//                completion(.failure(error))
//                return
//            }
//        }
//        
//        videoComposition.instructions = instructions
//        
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName + ".mov")
//        
//        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
//            print("Failed to create export session")
//            completion(.failure(ConstructionError.exportFailed))
//            return
//        }
//        
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .mov
//        exportSession.videoComposition = videoComposition
//        
//        exportSession.exportAsynchronously {
//            switch exportSession.status {
//            case .completed:
//                completion(.success(outputURL))
//            case .failed:
//                print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
//                completion(.failure(exportSession.error ?? ConstructionError.exportFailed))
//            case .cancelled:
//                print("Export cancelled")
//                completion(.failure(ConstructionError.exportFailed))
//            default:
//                print("Unexpected export status: \(exportSession.status.rawValue)")
//                completion(.failure(ConstructionError.exportFailed))
//            }
//        }
//    }
}





extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}







//    func createFinalVideo(from mediaAssets: [MediaAsset], template: Template, outputSize: CGSize, frameRate: Int32 = 30, outputFileName: String, audioURL: URL?, audioStartTime: Double, audioEndTime: Double, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
//        var allAssets: [AVAsset] = []
//        var allDurations: [Double] = []
//        tempURLs = []
//
//        var tempURLsArrayToSort: [String: AVAsset] = [:]
//        var tempURLsDurationToSort: [String: Double] = [:]
//
//        let totalSteps = Double(mediaAssets.count + 1) // +1 for final combination
//        var currentStep = 0.0
//
//        func updateProgress(_ stepProgress: Double) {
//            let overallProgress = (currentStep + stepProgress) / totalSteps
//            DispatchQueue.main.async {
//                progressHandler(overallProgress)
//            }
//        }
//
//        let processingGroup = DispatchGroup()
//
//        for (index, mediaAsset) in mediaAssets.enumerated() {
//            processingGroup.enter()
//
//            if index >= template.slides.count {
//                processingGroup.leave()
//                continue
//            }
//
//            let slide = template.slides[index]
//
//            if slide.isVideo {
//                if let videoAsset = mediaAsset.videoAsset {
//                    let outputFileName = "temp_video_slide_\(index)"
//
//                    allAssets.append(videoAsset)
//                    allDurations.append(slide.duration)
//
//                    tempURLsArrayToSort[outputFileName] = videoAsset
//                    tempURLsDurationToSort[outputFileName] = slide.duration
//
//                    processingGroup.leave()
//                } else {
//                    processingGroup.leave()
//                }
//            } else {
//                if let image = mediaAsset.fullSizeImage ?? mediaAsset.thumbnail {
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        do {
//                            let outputFileName = "temp_video_slide_\(index)"
//                            let imageVideoURL = try self.createVideoFromImages(images: [image], durations: [slide.duration], outputSize: outputSize, frameRate: frameRate, outputFileName: outputFileName, progressHandler: { imageProgress in
//                                updateProgress(imageProgress / Double(totalSteps))
//                            })
//                            let imageVideoAsset = AVAsset(url: imageVideoURL)
//                            allAssets.append(imageVideoAsset)
//                            allDurations.append(slide.duration)
//
//                            tempURLsArrayToSort[outputFileName] = imageVideoAsset
//                            tempURLsDurationToSort[outputFileName] = slide.duration
//
//                            self.tempURLs.append(imageVideoURL)
//                        } catch {
//                            DispatchQueue.main.async {
//                                completion(.failure(error))
//                            }
//                        }
//                        processingGroup.leave()
//                    }
//                } else {
//                    processingGroup.leave()
//                }
//            }
//
//            currentStep += 1
//            updateProgress(0)
//        }
//
//
//
//        processingGroup.notify(queue: .main) {
//
//
//
//            self.combineVideos(template: template, videoAssets: allAssets, durations: allDurations, outputSize: outputSize, outputFileName: outputFileName, audioURL: audioURL, audioStartTime: audioStartTime, audioEndTime: audioEndTime, includeOriginalAudio: audioURL != nil, progressHandler: { combineProgress in
//                updateProgress(combineProgress)
//            }) { result in
//                for url in self.tempURLs {
//                    try? FileManager.default.removeItem(at: url)
//                }
//
//                switch result {
//                case .success(let finalVideoURL):
//                    updateProgress(0.99)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        completion(.success(finalVideoURL))
//                        updateProgress(1)
//                        self.tempURLs.append(finalVideoURL)
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
















/*
 currently, the function works so the program goes through all the assts and checks wheter they are images or so. the parts with images are split and combined. I want to make it so that a particular video will be created for a particular UIImage. This approach will help to track slide indexes more effeciently: "func createFinalVideo(from mediaAssets: [MediaAsset], template: Template, outputSize: CGSize, frameRate: Int32 = 30, outputFileName: String, audioURL: URL?, audioStartTime: Double, audioEndTime: Double, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
         var allAssets: [AVAsset] = []
         var allDurations: [Double] = []
         tempURLs = []
         var currentImages: [UIImage] = []
         var currentImageDurations: [Double] = []
         
         let totalSteps = Double(template.slides.count + 1) // +1 for final combination
         var currentStep = 0.0
         
         func updateProgress(_ stepProgress: Double) {
             let overallProgress = (currentStep + stepProgress) / totalSteps
             DispatchQueue.main.async {
                 progressHandler(overallProgress)
             }
         }
         
         for (index, slide) in template.slides.enumerated() {
             if index >= mediaAssets.count {
                 break
             }
             
             let mediaAsset = mediaAssets[index]
             
             if slide.isVideo {
                 if !currentImages.isEmpty {
                     do {
                         let imagesVideoURL = try createVideoFromImages(images: currentImages, durations: currentImageDurations, outputSize: outputSize, frameRate: frameRate, outputFileName: "temp_images_\(allAssets.count)", progressHandler: { imageProgress in
                             updateProgress(imageProgress / Double(totalSteps))
                         })
                         let imagesVideoAsset = AVAsset(url: imagesVideoURL)
                         allAssets.append(imagesVideoAsset)
                         allDurations.append(currentImageDurations.reduce(0, +))
                         tempURLs.append(imagesVideoURL)
                         currentImages = []
                         currentImageDurations = []
                     } catch {
                         completion(.failure(error))
                         return
                     }
                 }
                 
                 if let videoAsset = mediaAsset.videoAsset {
                     allAssets.append(videoAsset)
                     allDurations.append(slide.duration)
                 }
             } else {
                 if let image = mediaAsset.fullSizeImage ?? mediaAsset.thumbnail {
                     currentImages.append(image)
                     currentImageDurations.append(slide.duration)
                 }
             }
             
             currentStep += 1
             updateProgress(0)
         }
         
         if !currentImages.isEmpty {
             do {
                 let imagesVideoURL = try createVideoFromImages(images: currentImages, durations: currentImageDurations, outputSize: outputSize, frameRate: frameRate, outputFileName: "temp_images_\(allAssets.count)", progressHandler: { imageProgress in
                     updateProgress(imageProgress / Double(totalSteps))
                 })
                 let imagesVideoAsset = AVAsset(url: imagesVideoURL)
                 allAssets.append(imagesVideoAsset)
                 allDurations.append(currentImageDurations.reduce(0, +))
                 tempURLs.append(imagesVideoURL)
             } catch {
                 completion(.failure(error))
                 return
             }
         }
         
         combineVideos(template: template, videoAssets: allAssets, durations: allDurations, outputSize: outputSize, outputFileName: outputFileName, audioURL: audioURL, audioStartTime: audioStartTime, audioEndTime: audioEndTime, includeOriginalAudio: audioURL != nil, progressHandler: { combineProgress in
             updateProgress(combineProgress)
         }) { result in
             for url in self.tempURLs {
                 try? FileManager.default.removeItem(at: url)
             }
             
             switch result {
             case .success(let finalVideoURL):
                 updateProgress(0.99)
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                     completion(.success(finalVideoURL))
                     updateProgress(1)
                     self.tempURLs.append(finalVideoURL)
                 }
             case .failure(let error):
                 completion(.failure(error))
             }
         }
     }"
 */



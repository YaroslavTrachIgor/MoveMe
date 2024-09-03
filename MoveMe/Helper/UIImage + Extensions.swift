//
//  UIImage + Extensions.swift
//  MoveMe
//
//  Created by User on 2024-07-29.
//

import Foundation
import SwiftUI

extension UIImage {
    func applyHDEffect() -> UIImage {
        let context = CIContext()
        
        guard let ciImage = CIImage(image: self) else {
            return self
        }
        
        let exposureFilter = CIFilter.exposureAdjust()
        exposureFilter.inputImage = ciImage
        exposureFilter.ev = 0.1
        
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = exposureFilter.outputImage
        contrastFilter.contrast = 1
        
        let saturationFilter = CIFilter.colorControls()
        saturationFilter.inputImage = contrastFilter.outputImage
        saturationFilter.saturation = 1
        
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = saturationFilter.outputImage
        sharpenFilter.sharpness = 0.9
        
        if let outputCIImage = sharpenFilter.outputImage,
           let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return self
    }
}

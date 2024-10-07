//
//  DurationEditView.swift
//  MoveMe
//
//  Created by User on 2024-07-29.
//

import Foundation
import SwiftUI

struct DurationEditView: View {
    
    @Binding var selectedAssetsArray: [MediaAsset]
    @Binding var selectedAsset: MediaAsset?
    @Binding var duration: Double
    
    let asset: MediaAsset
    var template: Template
    
    @Binding var isEditingDuration: Bool
    
    @State var savedDuration: Double = 0.2
    
    var maxDuration: Double {
        if asset.type == .video, let videoAsset = asset.videoAsset {
            return savedDuration
        }
        return 10.0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    withAnimation {
                        isEditingDuration = false
                        duration = savedDuration
                    }
                } label: {
                    Image(systemName: "multiply")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.all, 8)
                        .cornerRadius(10)
                }
                
                Spacer()
                
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
                
                Button {
                    withAnimation {
                        isEditingDuration = false
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.all, 8)
                        .cornerRadius(10)
                }
            }
            
            
            HStack {
                Text("Total: \(String(format: "%.1f", template.duration - savedDuration + duration))S".uppercased())
                    .foregroundColor(.gray.opacity(0.4))
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.leading, 12)
                
                Spacer()
                
                Text("\(String(format: "%.1f", duration))S")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.leading, 18)
                
                Spacer()
                
                Text("Previous: \(String(format: "%.1f", savedDuration))S".uppercased())
                    .foregroundColor(.gray.opacity(0.4))
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.trailing, 12)
            }
            .padding(.bottom, -2)
            
            if let image = asset.thumbnail {
                Group {
                    ZStack {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                ForEach(0..<Int(ceil(min(4, savedDuration * 2))), id: \.self) { _ in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width / CGFloat(ceil(min(4, savedDuration * 2))), height: 60)
                                        .clipped()
                                }
                            }
                        }
                        .frame(width: CGFloat(min(3, savedDuration)) * 100, height: 60)
                        .cornerRadius(12)
                        .overlay { RoundedRectangle(cornerRadius: 12).stroke(foreColor, lineWidth: 2) }
                        .padding(.horizontal, -17)
                        .padding(.trailing, 3)
                        .opacity(0.15)
                    
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                ForEach(0..<Int(ceil(min(4, duration * 2))), id: \.self) { _ in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width / CGFloat(ceil(min(4, duration * 2))), height: 60)
                                        .clipped()
                                }
                            }
                        }
                        .frame(width: CGFloat(min(3, duration)) * 100, height: 60)
                        .cornerRadius(12)
                        .overlay {
                            HStack {
                                Image(systemName: "chevron.backward")
                                    .font(.system(size: 10))
                                    .fontWeight(.black)
                                    .foregroundStyle(Color.black)
                                    .padding(4)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .cornerRadius(5)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .font(.system(size: 10))
                                    .fontWeight(.black)
                                    .foregroundStyle(Color.black)
                                    .padding(4)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            .padding(.horizontal, -17)
                        }
                        .overlay { RoundedRectangle(cornerRadius: 12).stroke(foreColor, lineWidth: 2) }
                    }
                }
                .padding(.trailing, 2)
            }
            
            DurationSlider(duration: $duration, range: 0.1...maxDuration)
                .frame(height: 20)
                .padding(.horizontal)
        }
        .padding()
        .background(backColor.opacity(0.3))
        .cornerRadius(20)
        .onAppear {
            savedDuration = duration
        }
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .cornerRadius(20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
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
}


struct DurationSlider: View {
    
    @Binding var duration: Double
    
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(foreColor)
                    .frame(width: CGFloat((duration - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 4)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat((duration - range.lowerBound) / (range.upperBound - range.lowerBound)) * (geometry.size.width - 20))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = Double(value.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                                duration = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                    )
            }
        }
    }
}

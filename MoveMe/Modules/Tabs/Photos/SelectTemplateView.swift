//
//  SelectTemplateView.swift
//  MoveMe
//
//  Created by User on 2024-07-12.
//

import Foundation
import SwiftUI

struct SelectTemplateView: View {
    
    @State var assets: [MediaAsset] = []
    @State var selectedAssets: [MediaAsset] = []
    @State private var croppedAssets: [MediaAsset] = []
    
    @State private var selectedTemplate: Template = Template(id: UUID(), name: "", iconName: "", items: 0, duration: 0, example: nil, slides: [])
    
    @State private var presentSubscritionsCoverView = false
    @State private var presentVideoEditingView = false
    
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack {
                
                // Top Section
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
                    
                    if !isPremium {
                        Button(action: {
                            presentSubscritionsCoverView.toggle()
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .padding(.leading, 8)
                                    .padding(.trailing, -10)
                                Text("PRO")
                                    .fontWeight(.bold)
                                    .padding(8)
                            }
                            .padding(0)
                            .background(LinearGradient(gradient: Gradient(colors: [.purple, .pink, .orange]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(18)
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                        }
                    }
                }
                .padding(.top, 60)
                
                // Title
                HStack {
                    Text("Select template")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                        .padding(.leading)
                    Spacer()
                }
                
                HStack {
                    Text("Selected photos")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 6)
                        .padding(.leading)
                        .padding(.bottom, -3)
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        
                        ForEach(selectedAssets, id: \.self) { asset in
                            if let image = asset.thumbnail {
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipped()
                                        .cornerRadius(8)
                                        .overlay(content: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(assets.contains(asset) ? foreColor : Color.gray.opacity(0.6), lineWidth: assets.contains(asset) ? 1 : 1)
                                        })
                                    
                                    if asset.type == .video {
                                        Image(systemName: "play.circle")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    
                                    VStack {
                                        HStack {
                                            Spacer()
                                            
                                            Image(systemName: "checkmark")
                                                .padding(.all, 3)
                                                .font(.system(size: 8))
                                                .fontWeight(.bold)
                                                .foregroundStyle(assets.contains(asset) ? Color.white : Color.clear)
                                                .background(assets.contains(asset) ? foreColor : Color.clear)
                                                .cornerRadius(1)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(assets.contains(asset) ? foreColor : Color.gray.opacity(0.8), lineWidth: assets.contains(asset) ? 2 : 1)
                                                }
                                                .padding(.all, 4)
                                                .padding(.trailing, 4)
                                                .padding(.top, 2)
                                        }
                                        Spacer()
                                    }
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if assets.contains(asset) {
                                            assets.removeAll { $0 == asset }
                                        } else {
                                            assets.append(asset)
                                        }
                                    }
                                }
                                .padding(.trailing, 12)
                            }
                        }
                        
                    }
                    .padding()
                }
                .frame(height: 80)
                .padding(.top, -8)
                
                
                
                // Image Grid
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Image("Template1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .frame(width: UIScreen.main.bounds.width - 32)
                            .cornerRadius(16)
                            .overlay(
                                Text("Try Now")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(8)
                                    .background(Color.purple)
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .padding([.top, .trailing], 16)
                                    .padding([.bottom], 16),
                                alignment: .bottomTrailing
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedTemplate = Template.list[0]
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedTemplate == Template.list[0] ? foreColor : Color.clear, lineWidth: 1)
                            }
                            .overlay {
                                detailTemplateOverlayView(with: Template.list[0])
                            }
                            .padding(.top, 3)
                        
                        HStack(spacing: 16) {
                            Image("Template2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTemplate = Template.list[1]
                                    }
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedTemplate == Template.list[1] ? foreColor : Color.clear, lineWidth: 1)
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[1])
                                }
                            
                            Image("Template3")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTemplate = Template.list[2]
                                    }
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedTemplate == Template.list[2] ? foreColor : Color.clear, lineWidth: 1)
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[2])
                                }
                        }
                        
                        HStack(spacing: 16) {
                            Image("Template5")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    selectedTemplate = Template.list[4]
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[4])
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedTemplate == Template.list[4] ? foreColor : Color.clear, lineWidth: 1)
                                }
                            
                            Image("Template4")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .frame(width: UIScreen.main.bounds.width / 2 - 16)
                                .cornerRadius(16)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTemplate = Template.list[3]
                                    }
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedTemplate == Template.list[3] ? foreColor : Color.clear, lineWidth: 1)
                                }
                                .overlay {
                                    detailTemplateOverlayView(with: Template.list[3])
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .onAppear {
                        assets = selectedAssets
                    }
                }
            }
            
            VStack {
                Spacer()
                
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
                        cropSelectedVideos {
                            selectedAssets = orderAssetsAccordingToSlides()
                            presentVideoEditingView.toggle()
                        }
                    }, label: {
                        Text("Create Reel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(assets.count != (selectedTemplate.items) ? Color(.systemGray3) : Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(assets.count != (selectedTemplate.items) ? Color(.systemGray) : foreColor)
                            .cornerRadius(18)
                            .shadow(color: assets.count != (selectedTemplate.items) ? Color.clear : foreColor.opacity(0.2), radius: 10)
                    })
                    .disabled(assets.count != (selectedTemplate.items))
                    .padding(.all, 12)
                    .padding(.bottom, 46)
                    .padding(.top, -8)
                }
                .ignoresSafeArea(.all)
                .padding(.bottom, -60)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            selectedTemplate = Template.list[0]
        }
        .background(backColor)
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $presentVideoEditingView) {
            VideoEditingView(selectedAssetsArray: selectedAssets, template: selectedTemplate)
        }
        .fullScreenCover(isPresented: $presentSubscritionsCoverView) {
            SubscritionsCoverView()
        }
    }
    
    func detailTemplateOverlayView(with template: Template) -> some View {
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
                .frame(width: 40, height: 24)
                .background(Color.white)
                .cornerRadius(8)
                .padding()
                
                Spacer()
            }
        }
    }
    
    func cropSelectedVideos(completion: @escaping () -> Void) {
        if selectedTemplate.slides.count == Template.list[4].slides.count {
            for asset in selectedAssets {
                print(asset.type)
                selectedAssets.append(asset)
            }
        }
        
        let videoAssets = selectedAssets.filter { $0.type == .video }
        let videoSlides = selectedTemplate.slides.filter { $0.isVideo }
        
        guard videoAssets.count == videoSlides.count else {
            print("Error: Mismatch in number of video assets and video slides")
            completion()
            return
        }
        
        let group = DispatchGroup()
        croppedAssets = [] // Clear the array before populating
        
        for (index, asset) in videoAssets.enumerated() {
            group.enter()
            VideoRenderingManager.shared.cropVideo(asset: asset, slide: videoSlides[index]) { result in
                switch result {
                case .success(let croppedAsset):
                    DispatchQueue.main.async {
                        self.croppedAssets.append(croppedAsset)
                    }
                case .failure(let error):
                    print("Error cropping video: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.croppedAssets.sort { (asset1, asset2) -> Bool in
                guard let index1 = videoAssets.firstIndex(where: { $0.id == asset1.id }),
                      let index2 = videoAssets.firstIndex(where: { $0.id == asset2.id }) else {
                    return false
                }
                return index1 < index2
            }
            completion()
        }
    }
    
    func orderAssetsAccordingToSlides() -> [MediaAsset] {
        var orderedAssets: [MediaAsset] = []
        var photoIndex = 0
        var videoIndex = 0

        // Create ordered arrays of video and photo assets
        let orderedSelectedAssets = Array(selectedAssets)
        let orderedVideoAssets = orderedSelectedAssets.filter { $0.type == .video }
        let orderedPhotoAssets = orderedSelectedAssets.filter { $0.type == .photo }

        // Check if the current template is Template.list[4]
        let isTemplate5 = selectedTemplate.id == Template.list[4].id

        for (index, slide) in selectedTemplate.slides.enumerated() {
            if slide.isVideo {
                if !croppedAssets.isEmpty {
                    let assetToAdd = croppedAssets[videoIndex % croppedAssets.count]
                    orderedAssets.append(assetToAdd)
                    if isTemplate5 && index == selectedTemplate.slides.count / 2 {
                        videoIndex = 0 // Reset video index for the second half
                    } else {
                        videoIndex += 1
                    }
                }
            } else {
                if !orderedPhotoAssets.isEmpty {
                    let assetToAdd = orderedPhotoAssets[photoIndex % orderedPhotoAssets.count]
                    orderedAssets.append(assetToAdd)
                    if isTemplate5 && index == selectedTemplate.slides.count / 2 {
                        photoIndex = 0 // Reset photo index for the second half
                    } else {
                        photoIndex += 1
                    }
                }
            }
        }

        return orderedAssets
    }
}

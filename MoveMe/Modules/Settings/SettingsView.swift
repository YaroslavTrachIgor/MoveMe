//
//  SettingsView.swift
//  MoveMe
//
//  Created by User on 2024-09-09.
//

import Foundation
import SwiftUI
import StoreKit
import MessageUI
import Photos

struct SettingsView: View {
    
    @Binding var tabBarVisible: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingMailView = false
    @State private var showMailErrorAlert = false
    
    @State private var showMediaAccessAlert = false
    @State private var mediaAccessAlertTitle = ""
    @State private var mediaAccessAlertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                HStack {
                    Spacer()
                    Text("Settings")
                        .fontWeight(.bold)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                    Spacer()
                }
                
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        tabBarVisible = true
                    } label: {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                            .font(.headline)
                            .padding(.leading, 20)
                            .foregroundStyle(Color.white)
                    }

                    Spacer()
                }
            }
            .padding(.top, 12)
            
            
            
            
            
            
            baseCell(emoji: "📘", title: "Terms & Conditions")
                .padding(.top, 24)
                .onTapGesture {
                    guard let url = URL(string: "https://zhbr282.wixsite.com/website-1") else { return }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            
            baseCell(emoji: "🗝️", title: "Privacy Policy")
                .padding(.top, 8)
                .onTapGesture {
                    guard let url = URL(string: "https://zhbr282.wixsite.com/moveme-privacy-polic") else { return }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            
            baseCell(emoji: "💬", title: "Support")
                .padding(.top, 8)
                .onTapGesture {
                    if !MFMailComposeViewController.canSendMail() {
                        presentMediaAccessAlert(title: "Cannot send email", message: "Please, make sure that the Apple's Mail app is installed on your device, or copy the follwoing email address to reach out: ask.moveme@gmail.com")
                        showMailErrorAlert = true
                    } else {
                        isShowingMailView = true
                    }
                }
            
            baseCell(emoji: "⭐️", title: "Rate on the App Store")
                .padding(.top, 8)
                .onTapGesture {
                    requestAppReview()
                }
            
            baseCell(emoji: "🔓", title: "Give access to all media")
                .padding(.top, 32)
                .onTapGesture {
                    requestMediaAuthorization()
                }
            
            
        
            
            
            Text("Coming soon...")
                .font(.callout)
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.top, 32)
            
            baseRoundedCell(emoji: "🎨", title: "Transition effects")
                .padding(.top, 8)
            
            baseRoundedCell(emoji: "👥", title: "Reel captions")
                .padding(.top, 8)
            
            
            Spacer()
        }
        .background(backColor)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .alert(mediaAccessAlertTitle, isPresented: $showMediaAccessAlert) {
            if showMailErrorAlert {
                Button(action: {
                    UIPasteboard.general.string = "ask.moveme@gmail.com"
                }, label: {
                    Text("Copy Email")
                })
            }
            Button(action: {}, label: {
                Text("Continue")
                    .fontWeight(.semibold)
            })
        } message: {
            Text(mediaAccessAlertMessage)
        }
        .onAppear {
            tabBarVisible = false
        }
    }
    
    
    func baseCell(emoji: String, title: String) -> some View {
        HStack {
            HStack {
                Text(emoji)
                    .padding(.trailing, 4)
                Text(title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .background(Color(#colorLiteral(red: 0.1568616629, green: 0.1568636, blue: 0.1952569187, alpha: 1)))
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }
    
    func baseRoundedCell(emoji: String, title: String) -> some View {
        HStack {
            HStack {
                Text(emoji)
                    .padding(.trailing, 4)
                Text(title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(foreColor.opacity(0.25), lineWidth: 1.2)
        })
        .padding(.horizontal, 12)
        .sheet(isPresented: $isShowingMailView) {
            MailView()
        }
    }
    
    func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func requestMediaAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            var title = ""
            var message = ""
            
            switch status {
            case .notDetermined:
                title = "Not Determined"
                message = "Your Media Access status is not determined. For more advanced settings, please navigate to the MoveMe's page on the Settings app."
                presentMediaAccessAlert(title: title, message: message)
            case .restricted:
                title = "Restriced Access to Media"
                message = "Your Media Access status is restricted. For more advanced settings, please navigate to the MoveMe's page on the Settings app."
                presentMediaAccessAlert(title: title, message: message)
            case .denied:
                title = "Access to media was denied"
                message = "You have denied access to your photo library. For more advanced settings, please navigate to the MoveMe's page on the Settings app."
                presentMediaAccessAlert(title: title, message: message)
            case .authorized:
                title = "Access to media was authorized!"
                message = "You have authorized access to your photo library. For more advanced settings, please navigate to the MoveMe's page on the Settings app."
                presentMediaAccessAlert(title: title, message: message)
            case .limited:
                title = "Access to media was limited"
                message = "You have limited access to your photo library. For more advanced settings, please navigate to the MoveMe's page on the Settings app."
                presentMediaAccessAlert(title: title, message: message)
            @unknown default:
                fatalError()
            }
        }
    }
    
    func presentMediaAccessAlert(title: String, message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            mediaAccessAlertTitle = title
            mediaAccessAlertMessage = message
            showMediaAccessAlert = true
        }
    }
}


struct MailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["support@example.com"]) // Your support email
        vc.setSubject("Support Request")
        vc.setMessageBody("Hi, I need help with...", isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

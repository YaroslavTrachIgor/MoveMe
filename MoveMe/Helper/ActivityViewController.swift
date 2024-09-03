//
//  ActivityViewController.swift
//  MoveMe
//
//  Created by User on 2024-07-31.
//

import Foundation
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareSheet: ViewModifier {
    let activityItems: [Any]
    let completion: () -> ()
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            ActivityViewController(activityItems: activityItems, applicationActivities: nil)
                .onDisappear {
                    completion()
                }
        }
    }
}

extension View {
    func shareSheet(isPresented: Binding<Bool>, activityItems: [Any], completion: @escaping () -> ()) -> some View {
        self.modifier(ShareSheet(activityItems: activityItems, completion: completion, isPresented: isPresented))
    }
}

//
//  VideoCountManager.swift
//  MoveMe
//
//  Created by User on 2024-08-01.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class VideoCountManager {
    
    static let shared = VideoCountManager()
    
    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser?.uid ?? ""
    
    @AppStorage("videoCount") var videoCount = 1
    
    
    func checkDownloadLimit(completion: @escaping (Bool) -> Void) {
        guard !userID.isEmpty else {
            completion(false)
            return
        }
        
        let userDocRef = db.collection("users").document(userID)
        
        userDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let downloadCount = document.data()?["downloadCount"] as? Int ?? 0
                completion(downloadCount < 3)
            } else {
                completion(true)
            }
        }
    }
    
    func incrementDownloadCount() {
        guard !userID.isEmpty else {
            print("Error: User ID is empty")
            return
        }
        
        videoCount += 1
        
        print("Attempting to increment download count for user: \(userID)")
        
        let userDocRef = db.collection("users").document(userID)
        
        userDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                // Document exists, update the count
                let oldCount = document.data()?["downloadCount"] as? Int ?? 0
                let newCount = oldCount + 1
                
                print("Updating download count from \(oldCount) to \(newCount)")
                
                userDocRef.updateData(["downloadCount": newCount]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully updated. New download count: \(newCount)")
                    }
                }
            } else {
                // Document doesn't exist, create it
                print("Document does not exist. Creating new document for user: \(self.userID)")
                
                let newData: [String: Any] = [
                    "downloadCount": 1,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                
                userDocRef.setData(newData) { error in
                    if let error = error {
                        print("Error creating document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully created with initial download count: 1")
                    }
                }
            }
        }
    }
}

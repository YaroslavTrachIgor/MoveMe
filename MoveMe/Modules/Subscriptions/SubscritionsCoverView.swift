//
//  SubscritionsCoverView.swift
//  MoveMe
//
//  Created by User on 2024-08-25.
//

import Foundation
import SwiftUI

struct SubscritionsCoverView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var purchaseManager = PurchaseManager()
    
    var body: some View {
        ZStack {
            Image("SubscriptionsBackCover")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            LinearGradient(colors: [Color.clear, Color.black.opacity(0.8), Color.black], startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Limited Time Offer")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.white)
                                .padding(.all, 6)
                        }
                        .background(foreColor)
                        
                        
                        Text("1 month")
                            .font(.system(size: 46))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                        
                        HStack {
                            Text("for just ")
                                .font(.system(size: 25))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white)
                            Text("$3.35")
                                .font(.system(size: 25))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white)
                                .strikethrough()
                        }
                        
                        Text("$1.79")
                            .font(.system(size: 46))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                        
                        Button {
                            purchaseManager.purchase(purchaseManager.products.first!)
                        } label: {
                            HStack {
                                Text("Subscribe")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                                    .padding(.all, 17)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(colors: [Color.indigo, Color(#colorLiteral(red: 0.8972955346, green: 0.1340430081, blue: 0.9076731801, alpha: 1)), Color.pink], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(24)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1.6)
                                            
                                    }
                                    .shadow(color: Color.white.opacity(0.3), radius: 8)
                                
                            }
                        }
                        .padding(.top, 40)
                        
                        
                        
                        Text("$19.99/year after")
                            .foregroundStyle(Color.white.opacity(0.5))
                            .font(.system(size: 13))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        HStack {
                            Text("Terms of Use")
                                .foregroundStyle(Color.white.opacity(0.5))
                                .font(.system(size: 11, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            
                            Text("Restore Purchase")
                                .foregroundStyle(Color.white.opacity(0.5))
                                .font(.system(size: 11, weight: .medium))
                                .font(.system(size: 11))
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            
                            Text("Privacy Policy")
                                .foregroundStyle(Color.white.opacity(0.5))
                                .font(.system(size: 11, weight: .medium))
                                .font(.system(size: 11))
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                    }
                    
                }
                .padding()
                .padding(.bottom, 40)
            }
            
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "multiply")
                            .foregroundStyle(Color.white.opacity(0.7))
                            .font(.system(size: 22))
                            .fontWeight(.medium)
                    }
                    .padding(.all, 20)
                    .padding(.top, 22)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .onChange(of: purchaseManager.dismissSubcriptionCover) { newValue in
            presentationMode.wrappedValue.dismiss()
        }
    }
}


struct DashedUnderline: ViewModifier {
    let color: Color
    let thickness: CGFloat
    
    func body(content: Content) -> some View {
        return content
            .overlay(
                GeometryReader { geo in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geo.size.height))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    }
                    .stroke(style: StrokeStyle(lineWidth: thickness, dash: [thickness*2, thickness]))
                    .foregroundColor(color)
                }
            )
    }
}

extension View {
    func dashedUnderline(_ color: Color, thickness: CGFloat = 2) -> some View {
        return self.modifier(DashedUnderline(color: color, thickness: thickness))
    }
}

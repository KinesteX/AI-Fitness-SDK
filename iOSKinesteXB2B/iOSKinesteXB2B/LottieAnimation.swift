//
//  LottieAnimation.swift
//  iOSKinesteXB2B
//
//  Created by Vladimir Shetnikov on 1/15/24.
//

import SwiftUI

struct LottieAnimation: View {
    @Binding var showAnimation: Bool
    @Binding var isLoading: Bool
    var body: some View {
        Group {
            if showAnimation {
                LottieView(filename: "yogaAnimation", loopMode: .playOnce)
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fullscreen
                    .background(Color.white) // White background
                    .overlay(
                        Text("Aifying workouts...").foregroundColor(.black).font(.caption).offset(y: 190)
                    )
                    .scaleEffect(showAnimation ? 1 : 3) // Scale up
                    .opacity(showAnimation ? 1 : 0) // Fade out
                    .animation(.easeInOut(duration: 1.5), value: showAnimation)
               
            }
        }.onChange(of: isLoading) { newValue in
            if !newValue {
                withAnimation(.easeInOut(duration: 2.5)) {showAnimation = false}
            } else {
                showAnimation = true
            }
        }
    }
}


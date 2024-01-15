//
//  FeatureButton.swift
//
//  Created by Vladimir Shetnikov on 12/18/23.
//

import SwiftUI

struct FeatureButton: View {
    let iconName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(iconName)
                    .resizable()
                 
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .cornerRadius(20)
                Text(label)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 200, maxHeight: 200)
         
        }
    }
}

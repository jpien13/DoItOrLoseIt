//
//  RecenterButton.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/3/25.
//

import SwiftUI

struct RecenterButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "location")
                .resizable()
                .padding(15)
                .foregroundColor(Color.gray)
                .frame(
                    width: 50,
                    height: 50
                )
                .background(Color.white)
                .cornerRadius(10)
        }
        .padding()
        
    }
}

#Preview {
    RecenterButton {
        print("Location recenter button pressed")
    }
}

//
//  ContentView.swift
//  LongPressButton
//
//  Created by 김건우 on 3/27/24.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    @State private var count: Int = 0
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(count)")
                    .font(.largeTitle)
                    .bold()
                    .contentTransition(.numericText())
                
                LongPressButton(
                    text: "Hold to Increase",
                    tintColor: Color.black,
                    loadingTintColor: Color.white.opacity(0.3)
                ) {
                    count += 1
                }
                .padding(.top, 45)
                .foregroundStyle(Color.white)
            }
            .padding()
            .navigationTitle("Hold Down Button")
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

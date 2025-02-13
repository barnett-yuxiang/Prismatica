//
//  ContentView.swift
//  Prismatica
//
//  Created by yuli.kamakura on 2025/2/13.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()

    var body: some View {
        ParallaxCanvas()
            .environmentObject(motionManager)
            .preferredColorScheme(.dark)
            .ignoresSafeArea()
            .onAppear {
                print("ContentView appeared")
            }
    }
}

#Preview {
    ContentView()
}

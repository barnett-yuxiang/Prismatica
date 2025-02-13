//
//  ContentView.swift
//  Prismatica
//
//  Created by yuxiang on 2025/2/13.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        ParallaxCanvas()
            .environmentObject(motionManager)
            .preferredColorScheme(.dark)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}

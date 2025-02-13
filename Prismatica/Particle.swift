import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var zPosition: Double
    var rotation: Double
    var alpha: Double

    static func random(
        in rect: CGRect,
        minSize: CGFloat = 5,
        maxSize: CGFloat = 15,
        colors: [Color] = [.white, .pink, .blue, .purple, .mint],
        rotation: Double = 0,
        alpha: Double = 1.0,
        zPosition: Double? = nil
    ) -> Particle {
        Particle(
            position: CGPoint(
                x: CGFloat.random(in: 0...rect.width),
                y: CGFloat.random(in: 0...rect.height)
            ),
            size: CGFloat.random(in: minSize...maxSize),
            color: colors.randomElement()!,
            zPosition: zPosition ?? Double.random(in: 0...1),
            rotation: rotation,
            alpha: alpha
        )
    }
}
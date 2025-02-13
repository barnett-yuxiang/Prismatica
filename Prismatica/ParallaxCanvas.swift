import SwiftUI

struct ParallaxCanvas: View {
    @EnvironmentObject private var motionManager: MotionManager
    @State private var particles: [Particle] = []
    @State private var glowParticles: [Particle] = []
    
    var body: some View {
        Canvas { context, size in
            // Draw background glow effects
            for particle in glowParticles {
                var transform = CGAffineTransform.identity
                
                let xOffset = CGFloat(motionManager.roll * 30 * particle.zPosition)
                let yOffset = CGFloat(motionManager.pitch * 30 * particle.zPosition)
                
                transform = transform.translatedBy(
                    x: particle.position.x + xOffset,
                    y: particle.position.y + yOffset
                )
                
                let rect = CGRect(x: -particle.size/2, y: -particle.size/2, 
                                width: particle.size, height: particle.size)
                
                // 使用 ShapeStyle 直接绘制
                context.fill(
                    Circle().path(in: rect),
                    with: .color(particle.color.opacity(0.3))
                )
                context.addFilter(.blur(radius: 8))
            }
            
            // Draw triangle particles
            for particle in particles {
                var transform = CGAffineTransform.identity
                
                let xOffset = CGFloat(motionManager.roll * 80 * particle.zPosition)
                let yOffset = CGFloat(motionManager.pitch * 80 * particle.zPosition)
                let scale = 1 + particle.zPosition * 0.5
                
                transform = transform
                    .translatedBy(x: particle.position.x + xOffset,
                                y: particle.position.y + yOffset)
                    .scaledBy(x: scale, y: scale)
                    .rotated(by: particle.rotation)
                
                let path = Path { path in
                    path.move(to: CGPoint(x: -particle.size/2, y: particle.size/2))
                    path.addLine(to: CGPoint(x: particle.size/2, y: particle.size/2))
                    path.addLine(to: CGPoint(x: 0, y: -particle.size/2))
                    path.closeSubpath()
                }
                
                // 直接使用 ShapeStyle 绘制，避免 CGContext
                context.fill(
                    path.applying(transform),
                    with: .color(particle.color.opacity(0.9))
                )
                context.addFilter(.blur(radius: 0.5))
            }
        }
        .onAppear {
            let screenSize = UIScreen.main.bounds
            particles = (0..<60).map { _ in
                Particle.random(in: screenSize, 
                              minSize: 4, maxSize: 20,
                              colors: [.white], // 先只使用白色测试
                              rotation: .random(in: 0...2*Double.pi))
            }
            
            glowParticles = (0..<40).map { _ in
                Particle.random(in: screenSize,
                              minSize: 2, maxSize: 6,
                              colors: [.blue, .purple, .red, .green],
                              alpha: 0.3)
            }
        }
        .background(Color.black)
    }
} 
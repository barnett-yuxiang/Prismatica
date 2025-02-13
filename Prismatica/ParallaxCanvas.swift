import SwiftUI

struct ParallaxCanvas: View {
    @EnvironmentObject private var motionManager: MotionManager
    @State private var particles: [Particle] = []
    @State private var glowParticles: [Particle] = []

    var body: some View {
        Canvas { context, size in
            let baseContext = context

            // 先绘制背景发光粒子 - 几乎不动
            for particle in glowParticles {
                var transform = CGAffineTransform.identity

                // 背景粒子移动很少，但仍然有轻微移动
                let xOffset = CGFloat(motionManager.roll * 30)
                let yOffset = CGFloat(motionManager.pitch * 30)

                transform = transform.translatedBy(
                    x: particle.position.x + xOffset,
                    y: particle.position.y + yOffset
                )

                let rect = CGRect(x: -particle.size/2, y: -particle.size/2,
                                width: particle.size, height: particle.size)

                // 增加发光效果
                context.addFilter(.blur(radius: 2))
                baseContext.fill(
                    Circle().path(in: rect).applying(transform),
                    with: .color(particle.color.opacity(0.4))  // 稍微增加不透明度
                )
            }

            // Draw triangle particles
            for particle in particles {
                var transform = CGAffineTransform.identity

                // 近处（z值大）移动更快，远处移动更慢
                let zFactor = particle.zPosition * particle.zPosition // 使用平方增加差异
                let xOffset = CGFloat(motionManager.roll * 400 * zFactor)
                let yOffset = CGFloat(motionManager.pitch * 400 * zFactor)

                // 近处更大，远处更小
                let scale = 0.3 + particle.zPosition * 1.7

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

                // 近处更不透明，远处更透明
                let opacity = 0.3 + particle.zPosition * 0.7
                baseContext.fill(
                    path.applying(transform),
                    with: .color(particle.color.opacity(opacity))
                )
            }

            context.addFilter(.blur(radius: 0.5))
        }
        .onAppear {
            let screenSize = UIScreen.main.bounds
            particles = createLayeredParticles(screenSize)

            // 调整背景发光粒子
            glowParticles = (0..<25).map { _ in  // 增加数量
                Particle.random(
                    in: screenSize,
                    minSize: 3,    // 增大最小尺寸
                    maxSize: 6,    // 增大最大尺寸
                    colors: [
                        .blue.opacity(0.8),
                        .purple.opacity(0.8),
                        .pink.opacity(0.8),
                        .mint.opacity(0.8)
                    ],
                    rotation: 0
                )
            }
        }
        .background(Color.black)
    }

    private func createLayeredParticles(_ screenSize: CGRect) -> [Particle] {
        var allParticles: [Particle] = []

        // 远景层 (小粒子，慢速移动)
        allParticles += (0..<15).map { _ in
            Particle.random(
                in: screenSize,
                minSize: 8,
                maxSize: 12,
                colors: [.white],
                rotation: .random(in: 0...2*Double.pi),
                zPosition: Double.random(in: 0...0.3)  // 远景
            )
        }

        // 中景层
        allParticles += (0..<12).map { _ in
            Particle.random(
                in: screenSize,
                minSize: 15,
                maxSize: 22,
                colors: [.white],
                rotation: .random(in: 0...2*Double.pi),
                zPosition: Double.random(in: 0.3...0.7)  // 中景
            )
        }

        // 近景层 (大粒子，快速移动)
        allParticles += (0..<8).map { _ in
            Particle.random(
                in: screenSize,
                minSize: 25,
                maxSize: 35,
                colors: [.white],
                rotation: .random(in: 0...2*Double.pi),
                zPosition: Double.random(in: 0.7...1.0)  // 近景
            )
        }

        return allParticles
    }
}
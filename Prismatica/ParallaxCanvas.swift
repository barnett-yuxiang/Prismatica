import SwiftUI

struct ParallaxCanvas: View {
    @EnvironmentObject private var motionManager: MotionManager
    @State private var particles: [Particle] = []
    @State private var glowParticles: [Particle] = []
    @State private var lastUpdate = Date()

    // 添加一个计时器来更新粒子
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, size in
            let baseContext = context

            // 计算时间差
            let now = Date()
            let deltaTime = now.timeIntervalSince(lastUpdate)
            lastUpdate = now

            // 先绘制背景发光粒子的底层光晕
            for particle in glowParticles {
                var transform = CGAffineTransform.identity

                let xOffset = CGFloat(motionManager.roll * 30)
                let yOffset = CGFloat(motionManager.pitch * 30)

                transform = transform.translatedBy(
                    x: particle.position.x + xOffset,
                    y: particle.position.y + yOffset
                )

                // 先绘制一个较大、更透明的圆形作为光晕
                let glowRect = CGRect(x: -particle.size, y: -particle.size,
                                    width: particle.size * 2, height: particle.size * 2)

                baseContext.fill(
                    Circle().path(in: glowRect).applying(transform),
                    with: .color(particle.color.opacity(0.15))
                )

                // 再绘制核心的小圆点
                let coreRect = CGRect(x: -particle.size/2, y: -particle.size/2,
                                    width: particle.size, height: particle.size)

                baseContext.fill(
                    Circle().path(in: coreRect).applying(transform),
                    with: .color(particle.color.opacity(0.4))
                )
            }

            // Draw triangle particles
            for particle in particles {
                var transform = CGAffineTransform.identity

                let zFactor = particle.zPosition * particle.zPosition * particle.zPosition * particle.zPosition
                let xOffset = CGFloat(motionManager.roll * 800 * zFactor)
                let yOffset = CGFloat(motionManager.pitch * 800 * zFactor)

                let scale = 0.3 + particle.zPosition * 1.7

                // 计算当前旋转角度和三角形的"压缩"效果
                let currentRotation = particle.rotation + particle.rotationSpeed * deltaTime
                // 使用正弦函数来创造"压缩"效果，模拟3D旋转
                let compressionFactor = abs(sin(currentRotation)) * 0.7 + 0.3 // 0.3 到 1.0 之间变化

                transform = transform
                    .translatedBy(x: particle.position.x + xOffset,
                                y: particle.position.y + yOffset)
                    .scaledBy(x: scale, y: scale * compressionFactor) // 在y轴方向上应用压缩
                    .rotated(by: currentRotation)

                let path = Path { path in
                    // 根据旋转角度调整三角形的形状
                    let heightFactor = compressionFactor // 使用相同的压缩因子
                    path.move(to: CGPoint(x: -particle.size/2, y: particle.size/2 * heightFactor))
                    path.addLine(to: CGPoint(x: particle.size/2, y: particle.size/2 * heightFactor))
                    path.addLine(to: CGPoint(x: 0, y: -particle.size/2 * heightFactor))
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
            lastUpdate = Date()
            let screenSize = UIScreen.main.bounds
            particles = createLayeredParticles(screenSize)

            // 调整背景发光粒子
            glowParticles = (0..<25).map { _ in
                Particle.random(
                    in: screenSize,
                    minSize: 4,    // 调整核心大小
                    maxSize: 8,    // 调整核心大小
                    colors: [
                        .blue,
                        .purple,
                        .pink,
                        .mint
                    ],  // 使用原始颜色，通过绘制方式控制透明度
                    rotation: 0
                )
            }
        }
        .onReceive(timer) { currentTime in
            // 在这里更新粒子的旋转
            let deltaTime = currentTime.timeIntervalSince(lastUpdate)
            lastUpdate = currentTime

            // 使用新数组来更新状态
            particles = particles.map { particle in
                var updatedParticle = particle
                updatedParticle.rotation += particle.rotationSpeed * deltaTime
                return updatedParticle
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
                zPosition: Double.random(in: 0...0.3),
                rotationSpeed: Double.random(in: -0.5...0.5)
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
                zPosition: Double.random(in: 0.3...0.7),
                rotationSpeed: Double.random(in: -0.5...0.5)
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
                zPosition: Double.random(in: 0.7...0.9),  // 调整范围，为超近景留空间
                rotationSpeed: Double.random(in: -0.5...0.5)
            )
        }

        // 超近景层 (中等大小粒子，超快移动)
        allParticles += (0..<3).map { _ in  // 减少到3个
            Particle.random(
                in: screenSize,
                minSize: 25,      // 稍微调小一点
                maxSize: 35,
                colors: [.white],
                rotation: .random(in: 0...2*Double.pi),
                zPosition: Double.random(in: 0.97...1.0),  // 更加靠近眼前
                rotationSpeed: Double.random(in: -2.0...2.0)  // 大幅增加旋转速度
            )
        }

        return allParticles
    }
}
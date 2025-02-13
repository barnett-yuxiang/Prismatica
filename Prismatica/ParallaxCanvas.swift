import SwiftUI

struct ParallaxCanvas: View {
    @EnvironmentObject private var motionManager: MotionManager
    @State private var particles: [Particle] = []
    @State private var glowParticles: [Particle] = []
    @State private var lastUpdate = Date()
    @State private var currentRotations: [UUID: Double] = [:]  // Store rotations separately

    // Timer for particle updates
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, size in
            let baseContext = context

            // Draw background glow particles first
            for particle in glowParticles {
                var transform = CGAffineTransform.identity

                let xOffset = CGFloat(motionManager.roll * 30)
                let yOffset = CGFloat(motionManager.pitch * 30)

                transform = transform.translatedBy(
                    x: particle.position.x + xOffset,
                    y: particle.position.y + yOffset
                )

                // Draw larger glow halo
                let glowRect = CGRect(x: -particle.size, y: -particle.size,
                                    width: particle.size * 2, height: particle.size * 2)

                baseContext.fill(
                    Circle().path(in: glowRect).applying(transform),
                    with: .color(particle.color.opacity(0.15))
                )

                // Draw core particle
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

                // Use stored rotation value
                let currentRotation = currentRotations[particle.id] ?? particle.rotation
                let compressionFactor = abs(sin(currentRotation)) * 0.7 + 0.3

                transform = transform
                    .translatedBy(x: particle.position.x + xOffset,
                                y: particle.position.y + yOffset)
                    .scaledBy(x: scale, y: scale * compressionFactor)
                    .rotated(by: currentRotation)

                let path = Path { path in
                    // Adjust triangle shape based on rotation
                    let heightFactor = compressionFactor
                    path.move(to: CGPoint(x: -particle.size/2, y: particle.size/2 * heightFactor))
                    path.addLine(to: CGPoint(x: particle.size/2, y: particle.size/2 * heightFactor))
                    path.addLine(to: CGPoint(x: 0, y: -particle.size/2 * heightFactor))
                    path.closeSubpath()
                }

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

            // Initialize rotations
            for particle in particles {
                currentRotations[particle.id] = particle.rotation
            }

            // Initialize glow particles
            glowParticles = (0..<25).map { _ in
                Particle.random(
                    in: screenSize,
                    minSize: 4,
                    maxSize: 8,
                    colors: [
                        .blue,
                        .purple,
                        .pink,
                        .mint
                    ],
                    rotation: 0
                )
            }
        }
        .onReceive(timer) { currentTime in
            let deltaTime = currentTime.timeIntervalSince(lastUpdate)
            lastUpdate = currentTime

            // Update rotations in the state dictionary
            for particle in particles {
                currentRotations[particle.id] = (currentRotations[particle.id] ?? particle.rotation) + particle.rotationSpeed * deltaTime
            }
        }
        .background(Color.black)
    }

    private func createLayeredParticles(_ screenSize: CGRect) -> [Particle] {
        var allParticles: [Particle] = []

        // Far layer particles
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

        // Mid layer particles
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

        // Near layer particles
        allParticles += (0..<8).map { _ in
            Particle.random(
                in: screenSize,
                minSize: 25,
                maxSize: 35,
                colors: [.white],
                rotation: .random(in: 0...2*Double.pi),
                zPosition: Double.random(in: 0.7...0.9),
                rotationSpeed: Double.random(in: -0.5...0.5)
            )
        }

        // Ultra-near layer particles
        allParticles += (0..<3).map { _ in
            Particle.random(
                in: screenSize,
                minSize: 25,
                maxSize: 35,
                colors: [.white],
                rotation: .random(in: 0...2*Double.pi),
                zPosition: Double.random(in: 0.97...1.0),
                rotationSpeed: Double.random(in: -2.0...2.0)
            )
        }

        return allParticles
    }
}
# Prismatica

A 3D parallax effect implementation using SwiftUI Canvas and device motion.

## Core Components

### Data Model
- `Particle`: Defines particle properties
  - position
  - size
  - color
  - z-position
  - rotation
  - rotation speed
  - alpha

### Motion Management
- `MotionManager`: Handles device motion data
  - Uses CoreMotion for device attitude
  - Provides pitch and roll data
  - Real-time motion state updates

### Rendering System (ParallaxCanvas)
- Layer-based rendering:
  - Background glow particles (colored orbs)
  - Far layer triangles (z: 0...0.3)
  - Mid layer triangles (z: 0.3...0.7)
  - Near layer triangles (z: 0.7...0.9)
  - Ultra-near layer triangles (z: 0.97...1.0)
- 3D effect implementation:
  - Z-position controls movement speed
  - Scale for depth perception
  - Compression factor for 3D rotation simulation

## Key Effects

### Parallax Effect
- Movement amplitude based on z-position
- Faster movement for near objects
- Slower movement for far objects
- Fourth power enhancement for near-field speed difference

### Particle Animation
- Timer-driven animation updates
- Independent rotation speeds
- 3D compression effect simulation

### Glow Effect
- Dual-layer rendering (glow + core)
- Opacity for soft effects
- Minimized movement amplitude

## Performance Optimization

### Layered Particle Management
- Far layer: 15 particles
- Mid layer: 12 particles
- Near layer: 8 particles
- Ultra-near layer: 3 particles

### Render Optimization
- Direct Canvas rendering
- Minimized view hierarchy
- Optimized state update mechanism
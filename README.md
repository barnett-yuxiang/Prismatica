# Prismatica

A 3D parallax effect implementation using SwiftUI Canvas and device motion. The project creates an immersive visual experience with floating triangles that respond to device movement.

## Video
[![Prismatica Demo](assets/demo_thumbnail.png)](assets/IMG_2360.MOV)

## Requirements
- My iPhone 12, not Pro / Max
- iOS 15.0+
- Xcode 13.0+
- Physical device with motion sensors

## Architecture

### Core Files
- `PrismaticaApp.swift`: Main app entry point
- `ContentView.swift`: Root view container
- `MotionManager.swift`: Device motion handling
- `Particle.swift`: Particle data model
- `ParallaxCanvas.swift`: Main rendering system

## Core Components

### Data Model
- `Particle`: Defines particle properties
  - position: 2D position in screen space
  - size: Particle dimension
  - color: Visual appearance
  - z-position: Depth in 3D space (0.0...1.0)
  - rotation: Current rotation angle
  - rotation speed: Angular velocity
  - alpha: Transparency value

### Motion Management
- `MotionManager`: Handles device motion data
  - Uses CoreMotion framework
  - Provides pitch and roll data at 60Hz
  - Real-time motion state updates
  - Memory-safe implementation with weak references

### Rendering System (ParallaxCanvas)
- Layer-based rendering:
  - Background glow particles: Colored orbs with minimal motion
  - Far layer triangles: Small, slow-moving (z: 0...0.3)
  - Mid layer triangles: Medium size and speed (z: 0.3...0.7)
  - Near layer triangles: Larger, faster (z: 0.7...0.9)
  - Ultra-near layer triangles: Fastest, closest to viewer (z: 0.97...1.0)
- 3D effect implementation:
  - Z-position-based movement speed
  - Dynamic scaling for depth perception
  - Compression factor simulation for 3D rotation

## Visual Effects

### Parallax Effect
- Movement amplitude based on z-position
- Fourth-order power scaling for near objects
- Progressive speed reduction with distance
- Independent x and y axis motion

### Particle Animation
- 60Hz timer-driven updates
- Per-particle rotation system
- State-managed animation loop
- 3D rotation simulation through compression

### Glow Effect
- Two-pass rendering technique
- Core + halo layer composition
- Opacity-based soft edges
- Color-based depth enhancement

## Performance Optimization

### Particle Management
- Optimized particle counts per layer:
  - Far layer: 15 particles (minimal impact)
  - Mid layer: 12 particles (balanced)
  - Near layer: 8 particles (moderate impact)
  - Ultra-near layer: 3 particles (high impact)
- Total particle count: 38 triangles + 25 glow orbs

### Render Pipeline
- SwiftUI Canvas for direct rendering
- Minimal view hierarchy
- Efficient state updates
- Optimized transform calculations

### Memory Management
- Struct-based particle system
- Value-type data propagation
- Automatic memory management
- Clean lifecycle management

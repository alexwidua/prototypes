// 20230320 • AmbientLight
//
// Particle snippet by Philip Davis
// @author Philip Davis
// @url https://philipcdavis.com

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var frame = FrameHandler()

    func scale(inputMin: CGFloat, inputMax: CGFloat, outputMin: CGFloat, outputMax: CGFloat, value: CGFloat) -> CGFloat {
        return outputMin + (outputMax - outputMin) * (value - inputMin) / (inputMax - inputMin)
    }
    
    @State private var lightBoundLow: CGFloat = 0.0
    @State private var lightBoundHigh: CGFloat = 50.00

    
    
    var body: some View {
        let luminosity: CGFloat = frame.luminosity

        ZStack {
            Image("Night")
                .resizable()
                .scaledToFit()
                .frame(width: 393).ignoresSafeArea()
                .opacity(1)
            SpriteView(scene: Particles(), options: [.allowsTransparency])
                         .allowsHitTesting(false)
            Image("Day")
                .resizable()
                .scaledToFit()
                .frame(width: 393).ignoresSafeArea()
                .opacity( scale(inputMin: lightBoundLow, inputMax: lightBoundHigh, outputMin: 0, outputMax: 1, value: luminosity)).ignoresSafeArea()
                .animation(.spring(), value: luminosity)
            
        }.statusBarHidden().onTapGesture() {
            // Calibrate luminosity value to current room value
            if(luminosity < (lightBoundHigh / 2))
            {
                print("Set lower bound to:", luminosity)
                lightBoundLow = luminosity
            }
            else {
                print("Set upper light bound to:", luminosity)
                lightBoundHigh = luminosity
            }
        
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Particle code from Philip Davis
// @author Philip Davis
// @url https://philipcdavis.com
class Particles: SKScene {
    override func sceneDidLoad() {
        size = UIScreen.main.bounds.size
        anchorPoint = CGPoint(x: 0.5, y: 0.25)
        scaleMode = .resizeFill
        backgroundColor = .clear
        
        let particles = SKEmitterNode(fileNamed: "Particles.sks")!
        particles.particlePositionRange.dx = UIScreen.main.bounds.width
        particles.particlePositionRange.dy = UIScreen.main.bounds.height
        addChild(particles)
    }
}

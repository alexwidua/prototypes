//
// HourGlass Prototype
//
// @author Alex Widua
// @date Apr 27 2023
//
//

import SwiftUI
import CoreMotion
import SpriteKit

struct ContentView: View {
    // motion data
    let manager = CMMotionManager()
    @State var pitch: Double = 0.0
    @State var roll: Double = 0.0
    @State var yaw: Double = 0.0
    @State var calibratePitch: Double = 0.0
    @State var calibrateRoll: Double = 0.0
    @State var calibrateYaw: Double = 0.0
    @State var accelerationY : Double = 0
    @State var angle: CGFloat = 0
    
    /// We use the timer here as a simple event loop that drives the trickling down logic and animation.
    /// The timer is attached to the parent ZStack
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    /// The timeBuffer variable adds a little delay before the trickle down animation starts/stops – the delay makes it feel more natural if you flip the timer.
    var timeBuffer: CGFloat = 0
    @State var totalTime: CGFloat = 20
    @State var currentTime: CGFloat = 2
    
    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea()
            VStack() {
                HourglassHalf(totalTime: totalTime, currentTime: currentTime, timeBuffer: timeBuffer, angle: angle, accelerationY: accelerationY)
                HourglassHalf(totalTime: totalTime, currentTime: currentTime, timeBuffer: timeBuffer, angle: angle, accelerationY: accelerationY, bottom: true)
            }
        }
        /// Lil event loop that drives the hourglass progression and animation
        .onReceive(timer) { _ in
            withAnimation(.spring()) {
                if(abs(angle) < 90 && currentTime < totalTime) {
                    currentTime += (1 * 0.25)
                }
                else if (abs(angle) > 90 && currentTime > 0) {
                    currentTime -= (1 * 0.25)
                }
            }
        }
        .onShake {
            print("[Device shaken] Reset timer")
            withAnimation(.spring()) {
                
                if(abs(angle) > 90) {
                    currentTime = totalTime
                }
                else {
                    currentTime = 0
                }
            }
        }
        .onAppear {
            manager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                withAnimation(.spring(response: 2, dampingFraction: 0.425, blendDuration:  0)) {
                    pitch = motionData!.attitude.pitch
                    roll = motionData!.attitude.roll
                    yaw = motionData!.attitude.yaw
                    
                    let normalizedYaw = yaw - calibrateYaw
                    angle = normalizedYaw * 180.0/Double.pi
                    accelerationY = motionData!.userAcceleration.x
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .persistentSystemOverlays(.hidden) // request home button indicator to be hidden
    }
}


struct HourglassHalf : View {
    func scale(inputMin: CGFloat, inputMax: CGFloat, outputMin: CGFloat, outputMax: CGFloat, value: CGFloat) -> CGFloat {
        return outputMin + (outputMax - outputMin) * (value - inputMin) / (inputMax - inputMin)
    }
    
    func clamp(value: CGFloat, minValue: CGFloat, maxValue: CGFloat) -> CGFloat {
        return min(max(value, minValue), maxValue)
    }
    
    /// Rotates a 2d vector around a pivot point. This drives the motion-sensitive gradient tilt.
    func rotate(valueX: CGFloat, valueY: CGFloat, angle: CGFloat) -> UnitPoint {
        let rad = (CGFloat.pi / 180) * angle
        let pivotPoint: CGFloat = 0.5 // assume center as pivot point
        let translatedX = valueX - pivotPoint
        let translatedY = valueY - pivotPoint
        let rotatedX = translatedX * cos(rad) - translatedY * sin(rad)
        let rotatedY = translatedX * sin(rad) + translatedY * cos(rad)
        let resultX = rotatedX + pivotPoint
        let resultY = rotatedY + pivotPoint
        return UnitPoint(x: resultX, y: resultY)
    }
    
    var totalTime : CGFloat
    var currentTime : CGFloat
    var timeBuffer : CGFloat
    var angle : CGFloat
    var accelerationY : CGFloat
    var bottom : Bool = false
    
    // computed vars
    /// This drives most of the animations. It's the totalTime - currentTime mapped to 0..1
    var progress : CGFloat {
        let clampAndScale = clamp(value: scale(inputMin: 0 + timeBuffer, inputMax: totalTime - timeBuffer, outputMin: 0.01, outputMax: 0.99, value: currentTime), minValue: 0.1, maxValue: 0.9)
        return bottom ? 1 - clampAndScale : clampAndScale
    }
    
    var radian : CGFloat { (angle * CGFloat.pi) / 180 }
    
    var flowDirection : Double {
        let baseDeg: CGFloat = 90
        let deadZone: CGFloat = 2 // dead zone in which time doesn't progress
        let absAngle: CGFloat = abs(angle)
        
        if(absAngle >= baseDeg - deadZone  && absAngle <= baseDeg + deadZone) {
            return 0
        }
        else if (absAngle >= baseDeg) {
            return 1
        }
        else if (absAngle <= baseDeg) {
            return -1
        }
        else {return 0}
        
    }
    
    /// controls birthRate of particles
    var emitParticles : Bool {
        if (flowDirection == 0) {
            return false
        }
        if(currentTime == 0 || currentTime == totalTime) {
            return false
        }
        return true
    }
    
    // UI
    // For demp only, the shown time doesn't correspond to the actual timer
    @State var showRemainingTime : Bool = false
    var remainingTime : CGFloat {
        let value  = bottom ? 0 + currentTime : totalTime - currentTime
        let clamped = clamp(value: value, minValue: 0, maxValue: 9)
        return clamped
    }
    
    // misc
    var borderGradientColors : [Color] {
        return bottom ? [Color("BorderEnd"), Color("BorderStart")] : [Color("BorderStart"), Color("BorderEnd")]
    }
    var borderThickness : CGFloat = 8.00
    
    var body: some View {
        ZStack {
            // outer border
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: borderGradientColors), startPoint: .top, endPoint: .bottom)
                )
                .hourGlassShape(bottom: bottom)
            // inner container
            ZStack {
                Rectangle()
                    .fill(.black)
                    .hourGlassShape(bottom: bottom)
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [.black, Color("Sand")]), startPoint: rotate(valueX: 0.5, valueY: progress, angle: angle), endPoint: rotate(valueX: 0.5, valueY: 1.0, angle: angle))
                        )
                        .hourGlassShape(bottom: bottom)
                    // extend the shape beyond its container in order to create a blur without edge bleeding. We use the blur as a poor man's gradient easing and remove some gradient banding
                        .frame(width: geometry.size.width + 48, height: geometry.size.height + 48)
                        .blur(radius: 8)
                        .offset(x: -24, y: -24)
                        .opacity(!bottom && currentTime == totalTime ? 0 : bottom && currentTime == 0 ? 0 : 1)
                }
                .mask() {
                    Rectangle()
                        .hourGlassShape(bottom: bottom)
                }
            }
            .padding(.all, borderThickness)
            // details
            ZStack {
                ZStack {
                    GeometryReader { geometry in
                        
                        let gWidth = geometry.size.width
                        let gHeight = geometry.size.height
                        
                        let topPositiveFlow = !bottom && flowDirection <= 0
                        let topNegativeFlow = !bottom && flowDirection >= 0
                        let bottomPositiveFlow = bottom && flowDirection <= 0
                        let bottomNegativeFlow = bottom && flowDirection >= 0
                        
                        /// Bright blur
                        /// We use a bright blur to achieve some kind of "piled-up-sand" effect
                        /// The blur shifts along the x axis and reacts to y acceleration with some y movement, giving the whole container
                        /// a more fluid feel. The bright blur is always only visible in the bottom half.
                        let brightBlurSize : CGFloat = 200
                        let brightBlurTranslateXWithRotation: CGFloat = (gWidth / 2) - (sin(radian) * gWidth)
                        
                        let brightBlurClampTranslateX : CGFloat = clamp(value: brightBlurTranslateXWithRotation, minValue: 0, maxValue: gWidth)
                        
                        let brightBlurCos : CGFloat = cos(radian) * (brightBlurSize * 0.75)
                        let brightBlurTranslateY = scale(inputMin: 0, inputMax: 1, outputMin: brightBlurCos, outputMax: gHeight + brightBlurCos, value: bottom ? progress : 1 - progress)
                        let brightBlurTranslateYWithAcceleration : CGFloat = brightBlurTranslateY * (1 + accelerationY)
                        
                        Ellipse()
                            .fill(Color("Sand"))
                            .frame(width: brightBlurSize, height: brightBlurSize)
                            .position(x: brightBlurClampTranslateX, y: brightBlurTranslateYWithAcceleration)
                            .blur(radius: 48 +  ((1 - progress) * 48))
                            .opacity(bottomPositiveFlow || topNegativeFlow ? 0.85 : 0)
                        
                        /// Dark blur
                        /// We use a dark blur to subtract some of the otherwise very linear gradient shape.
                        /// This creates more dynamic and looks like sand pulling away from the center.
                        /// The dark blur is always only visible in the top half.
                        let darkBlurSize : CGFloat = 400
                        let darkBlurTranslateY = scale(inputMin: 0, inputMax: 1, outputMin: 0, outputMax: gHeight, value: bottom ? 1 - progress : progress)
                        
                        Ellipse()
                            .fill(.black)
                            .frame(width: darkBlurSize, height: darkBlurSize / 1.25)
                            .position(x: gWidth/2, y: darkBlurTranslateY)
                            .blur(radius: 64)
                            .opacity(topPositiveFlow || bottomNegativeFlow ? 0.85 : 0)
                    }
                    /// Particles
                    ParticlesView(emitParticles: emitParticles, angle: angle, progress: progress, bottom: bottom)
                        .rotationEffect(Angle(degrees: bottom ? 180 : 0))
                        .opacity(bottom && flowDirection < 0 ? 1 : !bottom && flowDirection > 0 ? 1 : 0)
                }
                .mask() {
                    Rectangle()
                        .hourGlassShape(bottom: bottom)
                }
                // elapsed time display
                HStack {
                    Text("10:0\(remainingTime, specifier: "%.0f")")
                        .font(.system(size: 76, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .opacity(showRemainingTime ? 1 : 0)
                .blur(radius: showRemainingTime ? 0 : 48)
                .offset(x: 0, y: showRemainingTime ? 0 : 48)
                .rotationEffect(Angle(degrees: bottom ? 180 : 0))
            } .padding(.all, borderThickness)
        }
        /// Show / hide the remaining time on touchStart / touchUp
        /// This is purely for demo purposes and shows an arbitrary time
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    if(bottom && flowDirection < 0) { return }
                    if(!bottom && flowDirection > 0) { return }
                    withAnimation(.spring()) {
                        showRemainingTime = true
                    }
                })
                .onEnded({ _ in
                    withAnimation(.spring()) {
                        showRemainingTime = false
                    }
                })
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
    
    func hourGlassShape(bottom: Bool = false) -> some View {
        self
            .cornerRadius(bottom ? 500 : 50, corners: [.topLeft, .topRight])
            .cornerRadius(bottom ? 50 : 500, corners: [.bottomLeft, .bottomRight])
    }
    
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

// assign individual corner radii
// solution by StackOverflow author @Mojtaba Hosseini
// @url: https://stackoverflow.com/a/58606176
struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}


// MARK: -

class ParticlesScene: SKScene {
    override func sceneDidLoad() {
        size = UIScreen.main.bounds.size
        anchorPoint = CGPoint(x: 0.5, y: 0.0)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }
}

struct ParticlesView: UIViewRepresentable {
    private let view = SKView()
    @State var emitter: SKEmitterNode = SKEmitterNode(fileNamed: "Particles.sks")!
    
    let scene = ParticlesScene()
    var emitParticles : Bool
    var angle : CGFloat
    var progress : CGFloat
    var bottom : Bool
    
    func makeUIView(context: UIViewRepresentableContext<ParticlesView>) -> SKView {
        emitter.particlePositionRange.dx = 48
        scene.addChild(emitter)
        view.presentScene(scene)
        view.allowsTransparency = true
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: UIViewRepresentableContext<ParticlesView>) {
        
        if(!emitParticles) {
            emitter.particleBirthRate = 0
            return
        }
        else {
            let upsideDown = abs(angle) > 90
            let normalizeAngle = bottom ? angle : -angle
            let radian = (normalizeAngle * CGFloat.pi) / 180
            let birthRate: CGFloat = bottom && upsideDown ? 0 : 20
            
            /// The x acceleration drives the angle of the particles.
            /// It creates a more dynamic effect than changing the emission angle
            let accelerationX =  (sin(radian) * 100)
            let accelerationY = bottom && upsideDown ? 200.00 : !bottom && !upsideDown ? 200.00 : 0.00
            
            emitter.xAcceleration = accelerationX
            emitter.particleBirthRate = birthRate
            emitter.yAcceleration = accelerationY
        }
    }
}

// MARK: -
// device shake logic
// @author: HackingWithSwift.com
// @url: https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-shake-gestures

// The notification we'll send when a shake gesture happens.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

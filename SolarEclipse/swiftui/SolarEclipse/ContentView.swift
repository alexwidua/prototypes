//
//  ContentView.swift
//
//  Created by Alex Widua on 2023/02/20.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    
    // constants
    let ellipseWidth: CGFloat = 96
    let ellipseHeight: CGFloat = 96
    let glowLayerCount: CGFloat = 6.00
    let  distanceThreshold = 50.00
    
    // states
    @State private var offsetX = 0.0
    @State private var offsetY = 0.0
    @State private var beadRotation = 0.0
    @State private var beadOpacity = 1.0
    
    // accelerometer
    let manager = CMMotionManager()
    @State var pitch: Double = 0.0
    @State var roll: Double = 0.0
    @State var yaw: Double = 0.0
    @State var calibratePitch: Double = 0.0
    @State var calibrateRoll: Double = 0.0
    
    func scale(inputMin: CGFloat, inputMax: CGFloat, outputMin: CGFloat, outputMax: CGFloat, value: CGFloat) -> CGFloat {
        return outputMin + (outputMax - outputMin) * (value - inputMin) / (inputMax - inputMin)
    }
    
    func calculateDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, factor: CGFloat? = 10.0) -> CGFloat {
        let distance: CGFloat =  (pow(x1-x2, 2) + pow(y1-y2, 2)).squareRoot()
        return scale(inputMin: 0, inputMax: distanceThreshold, outputMin: 0, outputMax: 1, value: distance)
    }
    
    func calculateAngle(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat {
        let dy = y2-y1
        let dx = x2-x1
        var theta = atan2(dy, dx)
        theta *= 180 / .pi
        return theta
    }
    
    func angularOpacity(theta: CGFloat, offset: CGFloat) -> CGFloat {
        let rad: CGFloat = (theta - offset) * (.pi / 180)
        let cos = cos(rad)
        return cos * -1
    }
    
    func BailysBead(theta: CGFloat, offset: CGFloat) -> some View {
        let offsetTheta = theta < offset ? 360 + theta : theta
        return HStack {
            Rectangle()
                .fill(.black.opacity(0))
                .frame(width: 86, height: 24)
            ZStack {
                Ellipse()
                    .fill(.white)
                    .frame(width: 16, height: 32)
                    .opacity(angularOpacity(theta: offsetTheta, offset: offset) * beadOpacity)
                    .blur(radius: 6)
                Ellipse()
                    .fill(.white)
                    .frame(width: 16, height: 24)
                    .opacity(angularOpacity(theta: offsetTheta, offset: offset) * beadOpacity)
                    .blur(radius: 8)
            }
        }.rotationEffect(.degrees(offsetTheta))
    }
    
    var body: some View {
        let normDistance = calculateDistance(x1: offsetX, y1: offsetY, x2: 0, y2: 0)
        ZStack {
            Color(.black).ignoresSafeArea()
            ZStack {
                ForEach((1...Int(glowLayerCount)), id: \.self) { value in
                    let i = Double(value)
                    let blurOffset = CGFloat(value*value)
                    let sizeOffset = CGFloat(value*value) * 1.5
                    Ellipse()
                        .fill(.white.opacity(1 - normDistance))
                        .blur(radius: blurOffset)
                        .frame(width: ellipseWidth + sizeOffset, height: ellipseHeight + sizeOffset)
                        .opacity(1/i)
                }
                Ellipse()
                    .fill(.white)
                    .frame(width: ellipseWidth, height: ellipseHeight)
                Ellipse()
                    .fill(.black)
                    .frame(width: ellipseWidth, height: ellipseHeight)
                    .offset(x: offsetX, y: offsetY)
                    // 'reset' accelerometer on tap
                    .onTapGesture(count: 1) {
                        calibrateRoll = roll
                        calibratePitch = pitch
                    }
                    .gesture( DragGesture()
                        .onChanged { value in
                            withAnimation(.spring()) {
                                offsetX = value.translation.width
                                offsetY = value.translation.height
                                beadRotation = calculateAngle(x1: offsetX, y1: offsetY, x2: 0, y2: 0)
                                beadOpacity = normDistance < 0.2 && normDistance > 0.05 ? 1 : 0
                                
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                offsetX = .zero
                                offsetY = .zero
                                beadRotation = calculateAngle(x1: offsetX, y1: offsetY, x2: 0, y2: 0)
                                beadOpacity = 1
                            }
                        })
                ZStack {
                    BailysBead(theta: beadRotation, offset:0)
                    BailysBead(theta: beadRotation, offset:90)
                    BailysBead(theta: beadRotation, offset:180)
                    BailysBead(theta: beadRotation, offset:270)
                }
            }
            .onAppear {
                manager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                    withAnimation(.spring()) {
                        pitch = motionData!.attitude.pitch
                        roll = motionData!.attitude.roll
                        yaw = motionData!.attitude.yaw
                        let factor: Double = 200
                        offsetY = (pitch * factor) - (calibratePitch * factor)
                        offsetX = (roll * factor) - (calibrateRoll * factor)
                        beadRotation = calculateAngle(x1: offsetX, y1: offsetY, x2: 0, y2: 0)
                        let n = calculateDistance(x1: offsetX, y1: offsetY, x2: 0, y2: 0)
                        
                        beadOpacity = n < 0.2 && n > 0.05 ? 1 : 0
               
                    }
                }
            }.statusBarHidden()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

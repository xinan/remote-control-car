//
//  GyroControlViewController.swift
//  RemoteControlCar
//
//  Created by Liu Xinan on 4/5/15.
//  Copyright (c) 2015 Liu Hongnan. All rights reserved.
//

import UIKit
import CoreMotion

class GyroControlViewController: UIViewController {

    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    let mm : CMMotionManager = CMMotionManager()

    override func viewDidLoad() {
        if mm.deviceMotionAvailable {
            mm.deviceMotionUpdateInterval = 0.1
            mm.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()) {
                [weak self] data, error in
                let xyRotation = atan2(data.gravity.x, data.gravity.y) - M_PI
                let xzRotation = atan2(data.gravity.x, data.gravity.z) - M_PI
                var leftRight: UInt8 = 0b00000000
                var backwardForward: UInt8 = 0b00000000
                var speed: UInt8 = 0b00000000
                if (xyRotation < -5.2) {
                    leftRight = 0b00010000
                } else if (xyRotation > -4.3) {
                    leftRight = 0b00100000
                }
                if (xzRotation < -5.2) {
                    backwardForward = 0b10000000
                    speed = UInt8(Int((-5.2 - xzRotation) * 5) + 1)
                } else if (xzRotation > -4.5) {
                    backwardForward = 0b01000000
                    speed = UInt8(Int((xzRotation + 4.2) * 5) + 1)
                }
                if (speed > 4) {
                    speed = 4
                }
                self?.dispatch(leftRight, backwardForward: backwardForward, speed: speed)
            }
        } else {
            self.actionLabel.text = "Gyroscope not available :("
        }
    }
    
    func dispatch(leftRight: UInt8, backwardForward: UInt8, speed: UInt8) {
        let instruction: UInt8 = 0b00000000 | leftRight | backwardForward | speed
        
        println(Int(instruction)) // This line will be changed to send instruction through bluetooth
        
        let action = Int(instruction >> 4)
        
        // Switch cases, for display as well as references when you set up the car.
        switch action {
        case 0:
            self.actionLabel.text = "Stopped"
        case 1:
            self.actionLabel.text = "Turning right"
        case 2:
            self.actionLabel.text = "Turning left"
        case 4:
            self.actionLabel.text = "Going backward"
        case 5:
            self.actionLabel.text = "Backward right"
        case 6:
            self.actionLabel.text = "Backward left"
        case 8:
            self.actionLabel.text = "Going forward"
        case 9:
            self.actionLabel.text = "Forward right"
        case 10:
            self.actionLabel.text = "Forward left"
        default:
            self.actionLabel.text = "Error"
        }
        self.speedLabel.text = "\(Int(speed))"
    }
    
    override func viewDidDisappear(animated: Bool) {
        mm.stopDeviceMotionUpdates()
    }

}

//
//  GyroControlViewController.swift
//  RemoteControlCar
//
//  Created by Liu Xinan on 4/5/15.
//  Copyright (c) 2015 Liu Hongnan. All rights reserved.
//

import UIKit
import CoreMotion
import CoreBluetooth

class GyroControlViewController: UIViewController {

    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    let mm : CMMotionManager = CMMotionManager()
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!

    override func viewDidLoad() {
        if peripheral == nil || characteristic == nil {
            let alertController = UIAlertController(title: "No car connected", message: "Connect to a car first.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { [weak self] (alertAction) -> (Void) in
                self?.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            if mm.deviceMotionAvailable {
                mm.deviceMotionUpdateInterval = 0.1
                mm.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()) {
                    [weak self] data, error in
                    let xyRotation = atan2(data.gravity.x, data.gravity.y) - M_PI
                    let xzRotation = atan2(data.gravity.x, data.gravity.z) - M_PI
                    var leftRight: UInt8 = Instruction.STOP
                    var backwardForward: UInt8 = Instruction.STOP
                    var speed: UInt8 = Instruction.STOP
                    if (xyRotation < -5.2) {
                        leftRight = Instruction.TURNRIGHT
                    } else if (xyRotation > -4.3) {
                        leftRight = Instruction.TURNLEFT
                    }
                    if (xzRotation < -5.2) {
                        backwardForward = Instruction.FORWARD
                        speed = UInt8(Int((-5.2 - xzRotation) * 5) + 1)
                    } else if (xzRotation > -4.5) {
                        backwardForward = Instruction.BACKWARD
                        speed = UInt8(Int((xzRotation + 4.5) * 5) + 1)
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
    }
    
    func dispatch(leftRight: UInt8, backwardForward: UInt8, speed: UInt8) {
        let instruction: UInt8 = leftRight | backwardForward | speed
        
        self.sendInstruction(instruction)
        
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
    
    func sendInstruction(var instruction: UInt8) {
        let dataValue: NSData! = NSData(bytes: &instruction, length: 1)
        self.peripheral!.writeValue(dataValue, forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithoutResponse)
        println("Instruction sent: \(instruction)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        mm.stopDeviceMotionUpdates()
        if self.peripheral != nil {
            sendInstruction(Instruction.STOP) // Send stop signal before leaving the view
        }
    }

}

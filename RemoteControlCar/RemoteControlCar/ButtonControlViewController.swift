//
//  ButtonControlViewController.swift
//  RemoteControlCar
//
//  Created by Liu Xinan on 2/5/15.
//  Copyright (c) 2015 Liu Hongnan. All rights reserved.
//

import UIKit
import CoreBluetooth

class ButtonControlViewController: UIViewController {

    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    override func viewDidLoad() {
        if peripheral == nil || characteristic == nil {
            let alertController = UIAlertController(title: "No car connected", message: "Connect to a car first.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { [weak self] (alertAction) -> (Void) in
                self?.navigationController?.popViewControllerAnimated(true)
                }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func sendInstruction(var instruction: UInt8) {
        let dataValue: NSData = NSData(bytes: &instruction, length: 1)
        self.peripheral.writeValue(dataValue, forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithoutResponse)
        println("Instruction sent: \(instruction)")
        
    }
    
    @IBAction func forward(sender: UIButton) {
        sendInstruction(Instruction.FORWARD | Instruction.FULLSPEED)
    }
    
    @IBAction func backward(sender: UIButton) {
        sendInstruction(Instruction.BACKWARD | Instruction.FULLSPEED)
    }
    
    @IBAction func turnLeft(sender: UIButton) {
        sendInstruction(Instruction.TURNLEFT | Instruction.FULLSPEED)
    }
    
    @IBAction func turnRight(sender: UIButton) {
        sendInstruction(Instruction.TURNRIGHT | Instruction.FULLSPEED)
    }
    
    @IBAction func rightForward(sender: UIButton) {
        sendInstruction(Instruction.FORWARD | Instruction.TURNRIGHT | Instruction.FULLSPEED)
    }
    
    @IBAction func leftForward(sender: UIButton) {
        sendInstruction(Instruction.FORWARD | Instruction.TURNLEFT | Instruction.FULLSPEED)
    }
    
    @IBAction func rightBackward(sender: UIButton) {
        sendInstruction(Instruction.BACKWARD | Instruction.TURNRIGHT | Instruction.FULLSPEED)
    }
    
    @IBAction func leftBackward(sender: UIButton) {
        sendInstruction(Instruction.BACKWARD | Instruction.TURNLEFT | Instruction.FULLSPEED)
    }
    
    @IBAction func stop(sender: UIButton) {
        sendInstruction(Instruction.STOP)
    }
    
    @IBAction func tranform(sender: UIButton) {
        println("Transforming...")
    }

}

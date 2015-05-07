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
        self.peripheral.writeValue(dataValue, forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithResponse)
        println("Instruction sent: \(instruction)")
        
    }
    
    @IBAction func forward(sender: UIButton) {
        sendInstruction(0b10000100)
    }
    
    @IBAction func backward(sender: UIButton) {
        sendInstruction(0b01000100)
    }
    
    @IBAction func turnLeft(sender: UIButton) {
        sendInstruction(0b10100100)
    }
    
    @IBAction func turnRight(sender: UIButton) {
        sendInstruction(0b10010100)
    }
    
    @IBAction func stop(sender: UIButton) {
        sendInstruction(0b00000000)
    }
    
    @IBAction func specialAction(sender: UIButton) {
        println("Performing special action")
    }

}

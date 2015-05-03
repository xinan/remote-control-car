//
//  ButtonControlViewController.swift
//  RemoteControlCar
//
//  Created by Liu Xinan on 2/5/15.
//  Copyright (c) 2015 Liu Hongnan. All rights reserved.
//

import UIKit

class ButtonControlViewController: UIViewController {

    @IBAction func forward(sender: UIButton) {
        println("Going forward")
    }
    
    @IBAction func backward(sender: UIButton) {
        println("Going backward")
    }
    
    @IBAction func turnLeft(sender: UIButton) {
        println("Turning left")
    }
    
    @IBAction func turnRight(sender: UIButton) {
        println("Turning right")
    }
    
    @IBAction func stop(sender: UIButton) {
        println("Stopped")
    }
    
    @IBAction func specialAction(sender: UIButton) {
        println("Performing special action")
    }

}

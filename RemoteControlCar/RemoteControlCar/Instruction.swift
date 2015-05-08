//
//  Instruction.swift
//  RemoteControlCar
//
//  Created by Liu Xinan on 9/5/15.
//  Copyright (c) 2015 Liu Hongnan. All rights reserved.
//

import Foundation

struct Instruction {
    static let STOP: UInt8 = 0b00000000
    static let FORWARD: UInt8 = 0b10000000
    static let BACKWARD: UInt8 = 0b01000000
    static let TURNLEFT: UInt8 = 0b00100000
    static let TURNRIGHT: UInt8 = 0b00010000
    static let FULLSPEED: UInt8 = 0b00000100
}
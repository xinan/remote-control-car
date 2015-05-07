//
//  PairingViewController.swift
//  RemoteControlCar
//
//  Created by Liu Xinan on 2/5/15.
//  Copyright (c) 2015 Liu Hongnan. All rights reserved.
//

import UIKit
import CoreBluetooth

class PairingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    var devices: NSMutableArray = NSMutableArray()
    let SUUID = [CBUUID(string: "FFE0")]
    let CUUID = [CBUUID(string: "FFE1")]
    
    override func viewDidLoad() {
        manager = CBCentralManager(delegate: self, queue: nil)
        self.manager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    //================================================================
    // Implements CBCentralManagerDelegate
    //================================================================
    
    @objc func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            self.manager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            println("Bluetooth is on, scanning now.")
        case CBCentralManagerState.PoweredOff:
            println("Bluetooth is turned off, please turn it on.")
        case CBCentralManagerState.Unauthorized:
            println("This app does not have permission to use BLE.")
        default:
            println("State has not been changed.")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if self.devices.containsObject(peripheral) {
            self.devices.addObject(peripheral)
            self.tableView.reloadData()
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        self.manager.stopScan()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        println("Peripheral \(peripheral.name) connected.")
        self.peripheral.discoverServices(SUUID)
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.peripheral = nil
        println("Peripheral \(peripheral.name) disconnected.")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Failed to connect to peripheral \(peripheral.name)")
    }
    
    //================================================================
    // Implements CBPeripheralDelegate
    //================================================================
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if error != nil {
            println("Invalid services: \(error.localizedDescription)")
            return
        }
        for service in peripheral.services {
            println("Service found: \(service.UUIDString)")
            if service.UUIDString == SUUID[0] {
                println("Searching characteristic for service \(service.UUIDString)...")
                peripheral.discoverCharacteristics(CUUID, forService: service as! CBService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if error != nil {
            println("Invalid characteristic: \(error.localizedDescription)")
            return
        }
        for characteristic in service.characteristics {
            println("Characteristic found: \(characteristic.UUIDString)")
            if characteristic.UUIDString == CUUID[0] {
                self.characteristic = characteristic as! CBCharacteristic
                println("Everything seems to be ok now. Try to control the car. ")
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if error != nil {
            println("Update characteristic fail! \(characteristic.UUID) -> \(characteristic.value)")
            println("Error message: \(error.localizedDescription)")
        }
    }
    
    //================================================================
    // Implements UITableViewDelegate and UITableViewDataSource
    //================================================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Device"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let device: CBPeripheral = devices.objectAtIndex(indexPath.row) as! CBPeripheral
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = device.identifier.UUIDString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.peripheral = devices.objectAtIndex(indexPath.row) as! CBPeripheral
    }
    
}

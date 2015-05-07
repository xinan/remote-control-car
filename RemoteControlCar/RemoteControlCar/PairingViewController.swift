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
    @IBOutlet weak var statusLabel: UILabel!
    
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    var devices: NSMutableArray = NSMutableArray()
    var connectedIndexPath: NSIndexPath!
    let SUUID = [CBUUID(string: "FFE0")]
    let CUUID = [CBUUID(string: "FFE1")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Storyboard.CellReuseIdentifier)
        manager = CBCentralManager(delegate: self, queue: nil)
        self.manager.scanForPeripheralsWithServices(SUUID, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    //================================================================
    // Implements CBCentralManagerDelegate
    //================================================================
    
    @objc func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            self.manager.scanForPeripheralsWithServices(SUUID, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
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
        println("Discovered peripheral: \(peripheral.name)")
        if !self.devices.containsObject(peripheral) {
            self.devices.addObject(peripheral)
            self.tableView.reloadData()
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        self.manager.stopScan()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        println("Peripheral \(peripheral.name) connected.")
        self.tableView.cellForRowAtIndexPath(self.connectedIndexPath)?.accessoryType = .Checkmark
        self.statusLabel.text = "Connected."
        self.peripheral.discoverServices(SUUID)
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.peripheral = nil
        println("Peripheral \(peripheral.name) disconnected.")
        self.tableView.cellForRowAtIndexPath(self.connectedIndexPath)?.accessoryType = .None
        self.statusLabel.text = "Disconnected. Searching again..."
        self.manager.scanForPeripheralsWithServices(SUUID, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
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
            println("Service found: \(service.UUID)")
            if service.UUID.description == SUUID[0] {
                println("Searching characteristic for service \(service.UUID)...")
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
            println("Characteristic found: \(characteristic.UUID)")
            if characteristic.UUID.description == CUUID[0] {
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
        var device: CBPeripheral = devices.objectAtIndex(indexPath.row) as! CBPeripheral
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = device.description
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let device = devices.objectAtIndex(indexPath.row) as! CBPeripheral
        self.connectedIndexPath = indexPath
        self.manager.connectPeripheral(device, options: nil)
        println("Connecting to peripheral \(device.name)")
    }
    
}

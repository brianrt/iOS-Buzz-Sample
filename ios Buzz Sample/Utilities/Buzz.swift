//
//  Buzz.swift
//  Text to Buzz
//
//  Created by Brian Thompson on 11/22/20.
//

import CoreBluetooth

class Buzz: NSObject {
    
    let MAX_VIBRATION_AMP = 255;
    let MIN_VIBRATION_AMP = 0;

    // UUIDs for Neosensory UART over BLE
    let UART_OVER_BLE_SERVICE_UUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
    let UART_RX_WRITE_UUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
    
    // Central and Peripheral device managers
    var centralManager: CBCentralManager!
    var neoPeripheral: CBPeripheral!
    
    // Buzz characteristics
    var neoWriteCharacteristic: CBCharacteristic!
    
    // Callback function for updating status, provided by client
    var didUpdateStatus: ((_ status: String) -> ())

    init(didUpdateStatus: @escaping (_ status: String) -> ()) {
        self.didUpdateStatus = didUpdateStatus
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func sendCommand(cliCommand: String) {
        let byteArray = Data(Array(cliCommand.utf8))
        neoPeripheral.writeValue(byteArray, for: neoWriteCharacteristic, type: .withoutResponse)
    }
    
    // Buzz interface
    public func takeOverBuzz() {
        sendCommand(cliCommand: "auth as developer\n")
        sendCommand(cliCommand: "accept\n")
        sendCommand(cliCommand: "audio stop\n")
        sendCommand(cliCommand: "motors start\n")
        self.didUpdateStatus("Now in control of buzz motors, audio stopped")
    }
    
    public func releaseBuzz() {
        self.sendCommand(cliCommand: "motors clear_queue\n")
        self.sendCommand(cliCommand: "audio start\n")
        self.didUpdateStatus("Released control of buzz, audio resumed")
    }
    
    public func vibrateMotors(motorValues: [UInt8]) {
        self.sendCommand(cliCommand: "motors vibrate \(Data(motorValues).base64EncodedString())) \n")
    }
    
}

// Bluetooth central manager nad peripheral delegate functions
extension Buzz: CBCentralManagerDelegate, CBPeripheralDelegate {
    // Central Manager delegate functions
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            self.didUpdateStatus("Scanning for Buzz...")
            centralManager.scanForPeripherals(withServices: [UART_OVER_BLE_SERVICE_UUID])
        } else if (central.state == .poweredOff) {
            self.didUpdateStatus("Please turn bluetooth on")
        } else {
            self.didUpdateStatus("Error: \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        neoPeripheral = peripheral
        neoPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(neoPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.didUpdateStatus("Connected to \(String(describing: peripheral.name!))")
        neoPeripheral.discoverServices([UART_OVER_BLE_SERVICE_UUID])
    }
    
    // Peripheral delgate functions
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if (service.uuid == UART_OVER_BLE_SERVICE_UUID) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if (characteristic.uuid == UART_RX_WRITE_UUID) {
                neoWriteCharacteristic = characteristic
            }
        }
    }

}

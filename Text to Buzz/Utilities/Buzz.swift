//
//  Buzz.swift
//  Text to Buzz
//
//  Created by Brian Thompson on 11/22/20.
//

import CoreBluetooth

class Buzz: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let MAX_VIBRATION_AMP = 255;
    let MIN_VIBRATION_AMP = 0;

    // UUIDs for Neosensory UART over BLE
    let UART_OVER_BLE_SERVICE_UUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
    let UART_RX_WRITE_UUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
    let UART_TX_NOTIFY_UUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

    // UUIDs for the Device Information service (DIS)
    let DIS_SERVICE_UUID = CBUUID(string: "0000180A-0000-1000-8000-00805f9b34fb");
    let MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "00002A29-0000-1000-8000-00805f9b34fb");
    
    // Central and Peripheral device managers
    var centralManager: CBCentralManager!
    var neoPeripheral: CBPeripheral!
    
    // Buzz characteristics
    var neoWriteCharacteristic: CBCharacteristic!
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private static var sharedBuzz: Buzz = {
        return Buzz()
    }()
    
    class func shared() -> Buzz {
        return sharedBuzz
    }
    
    private func sendCommand(cliCommand: String) {
        let byteArray = Data(Array(cliCommand.utf8))
        neoPeripheral.writeValue(byteArray, for: neoWriteCharacteristic, type: .withoutResponse)
    }
    
    // Central Manager delegate functions
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      
      if (central.state == .poweredOn) {
          centralManager.scanForPeripherals(withServices: [UART_OVER_BLE_SERVICE_UUID])
      } else if (central.state == .poweredOff) {
          print("Please turn bluetooth on")
      } else {
          print("Error: \(central.state)")
      }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        neoPeripheral = peripheral
        neoPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(neoPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to \(peripheral)")
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
            if (characteristic.uuid == UART_RX_WRITE_UUID){
                neoWriteCharacteristic = characteristic
            }
        }
        
        sendCommand(cliCommand: "auth as developer\n")
        sendCommand(cliCommand: "accept\n")
        sendCommand(cliCommand: "audio stop\n")
        sendCommand(cliCommand: "motors start\n")
        
        delayWithSeconds(1) {
            self.sendCommand(cliCommand: "motors vibrate /wAAAA==\n")
        }
        delayWithSeconds(2) {
            self.sendCommand(cliCommand: "motors vibrate AP8AAA==\n")
        }
        delayWithSeconds(3) {
            self.sendCommand(cliCommand: "motors vibrate AAD/AA==\n")
        }
        delayWithSeconds(4) {
            self.sendCommand(cliCommand: "motors vibrate AAAA/w==\n")
        }
        delayWithSeconds(5) {
            self.sendCommand(cliCommand: "motors clear_queue\n")
            self.sendCommand(cliCommand: "audio start\n")
        }
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            print("hi")
            completion()
        }
    }
}

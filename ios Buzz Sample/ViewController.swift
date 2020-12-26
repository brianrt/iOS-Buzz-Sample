//
//  ViewController.swift
//  Text to Buzz
//
//  Created by Brian Thompson on 11/22/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectToBuzz: UIButton!
    @IBOutlet weak var releaseBuzz: UIButton!
    
    // Motor sliders
    @IBOutlet weak var motor1: UISlider!
    @IBOutlet weak var motor2: UISlider!
    @IBOutlet weak var motor3: UISlider!
    @IBOutlet weak var motor4: UISlider!
    
    // Current motor state
    var motorValues: [UInt8] = [0,0,0,0]
    
    
    var buzz: Buzz!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buzz = Buzz(didUpdateStatus: didUpdateStatus)
        intializeUI()
    }
    
    private func intializeUI() {
        self.connectToBuzz.layer.cornerRadius = 2
        self.releaseBuzz.layer.cornerRadius = 2
        hideInitialElements()
    }
    
    private func initializeMotors() {
        motor1.value = 0
        motor2.value = 0
        motor3.value = 0
        motor4.value = 0
        motorValues = [0,0,0,0]
    }

    @IBAction func didPressConnectToBuzz(_ sender: Any) {
        if (statusLabel.text == "Scanning for Buzz..."){
            return
        }
        initializeMotors()
        buzz.takeOverBuzz()
        showInitialElements()
    }
    
    @IBAction func didPressReleaseBuzz(_ sender: Any) {
        buzz.releaseBuzz()
        hideInitialElements()
    }
    
    // Motor controls
    @IBAction func didUpdateMotor1(_ sender: UISlider) {
        motorValues[0] = UInt8(sender.value)
        buzz.vibrateMotors(motorValues: motorValues)
    }
    
    @IBAction func didUpdateMotor2(_ sender: UISlider) {
        motorValues[1] = UInt8(sender.value)
        buzz.vibrateMotors(motorValues: motorValues)
    }
    
    @IBAction func didUpdateMotor3(_ sender: UISlider) {
        motorValues[2] = UInt8(sender.value)
        buzz.vibrateMotors(motorValues: motorValues)
    }
    
    @IBAction func didUpdateMotor4(_ sender: UISlider) {
        motorValues[3] = UInt8(sender.value)
        buzz.vibrateMotors(motorValues: motorValues)
    }
    
    public func didUpdateStatus(status: String) {
        self.statusLabel.text = status
    }
    
    private func hideInitialElements(){
        // Hide initial elements
        self.connectToBuzz.isHidden = false
        self.releaseBuzz.isHidden = true
        self.motor1.isHidden = true
        self.motor2.isHidden = true
        self.motor3.isHidden = true
        self.motor4.isHidden = true
    }
    
    private func showInitialElements(){
        // Show initial elements
        self.connectToBuzz.isHidden = true
        self.releaseBuzz.isHidden = false
        self.motor1.isHidden = false
        self.motor2.isHidden = false
        self.motor3.isHidden = false
        self.motor4.isHidden = false
    }
    
    
}


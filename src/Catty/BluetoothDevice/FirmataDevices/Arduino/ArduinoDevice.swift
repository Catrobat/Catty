/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import BluetoothHelper
import CoreBluetooth
import Foundation

class ArduinoDevice: FirmataDevice, ArduinoProtocol, ArduinoPropertyProtocol {

    /* unused
     private let pinAnalog0: Int = 0
     private let pinAnalog1: Int = 1
     private let pinAnalog2: Int = 2
     private let pinAnalog3: Int = 3
     private let pinAnalog4: Int = 4
     private let pinAnalog5: Int = 5
     
     private let portDigital0: Int = 0
     private let portDigital1: Int = 1
     
     private let minPWMPinGroup1: Int = 3
     private let maxPWMPinGroup1: Int = 3
     private let minPWMPinGroup2: Int = 5
     private let maxPWMPinGroup2: Int = 6
     private let minPWMPinGroup3: Int = 9
     private let maxPWMPinGroup3: Int = 11*/

    let Arduino_UUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB")
    static let tag: String = "Arduino"
    static let minAnalogSensorPin: Int = 0
    static let maxAnalogSensorPin: Int = 5

    override var rxUUID: CBUUID { return CBUUID.init(string: "713D0002-503E-4C75-BA94-3148F18D941E") }
    override var txUUID: CBUUID { return CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") }

    var digitalValue: Int = 0
    var analogValue: Double = 0
    var isReportingSensorData = false
    internal var totalPins = 0
    internal var analogMapping = NSMutableDictionary()
    internal var pinsArray = [[String: Any]]()

    internal let arduinoHelper = ArduinoHelper()

    // MARK: override

    override internal func getName() -> String {
        return "Arduino"
    }

    override internal func getBluetoothDeviceUUID() -> CBUUID {
        return Arduino_UUID
    }

    // MARK: Arduino Protocol
    func setDigitalArduinoPin(_ digitalPinNumber: Int, pinValue: Int) {
        let pin = UInt8(checkValue(digitalPinNumber))
        if checkDigitalPinCapability(pin, neededMode: .output) {
            if pinValue > 0 {
                firmata.writePinMode(.output, pin: pin)
                firmata.writePinState(PinState.high, pin: pin)
                setPortValue(Int(digitalPinNumber), value: 1)
            } else {
                firmata.writePinMode(.output, pin: pin)
                firmata.writePinState(.low, pin: pin)
                setPortValue(Int(digitalPinNumber), value: 0)
            }
        }
    }

    @objc
    func getDigitalArduinoPin(_ digitalPinNumber: Int) -> Double {
        let pin = UInt8(checkValue(digitalPinNumber))
        if checkDigitalPinCapability(pin, neededMode: .input) {
            reportSensorData(false)
            self.firmata.writePinMode(.input, pin: pin)
            self.firmata.setDigitalStateReportingForPort(pin / 8, enabled: true)
            print("requestValue")
            let semaphore = BluetoothService.swiftSharedInstance.getSemaphore()
            BluetoothService.swiftSharedInstance.setDigitalSemaphore(semaphore)
            _ = semaphore.wait(timeout: DispatchTime.now() + 0.2)
            BluetoothService.swiftSharedInstance.signalDigitalSemaphore(false)
            print(BluetoothService.swiftSharedInstance.digitalSemaphoreArray.count)
            self.firmata.setDigitalStateReportingForPort(pin / 8, enabled: false)
            self.digitalValue = self.getPortValue(Int(pin))
            print("setValue:\(self.digitalValue)")
            reportSensorData(true)
            return Double(self.digitalValue)
        }
        return Double(0)
    }

    func getAnalogArduinoPin(_ analogPinNumber: Int) -> Double {
        let pin = UInt8(checkValue(analogPinNumber))
        if checkAnalogPinCapability(pin, neededMode: .unknown) {
            self.firmata.setAnalogValueReportingforPin(pin, enabled: true)
            let semaphore = BluetoothService.swiftSharedInstance.getSemaphore()
            BluetoothService.swiftSharedInstance.setAnalogSemaphore(semaphore)
            _ = semaphore.wait(timeout: DispatchTime.now() + 0.1)
            self.firmata.setAnalogValueReportingforPin(pin, enabled: false)
            self.analogValue = self.getAnalogPin(analogPinNumber)
            print(self.analogValue)
            return Double(self.analogValue)
        }
        return Double(0)
    }

    func setPWMArduinoPin(_ PWMpin: Int, value: Int) {
        let pin = UInt8(checkValue(PWMpin))
        let checkedValue = UInt8(checkValue(value))
        if checkDigitalPinCapability(pin, neededMode: .pwm) {
            firmata.writePinMode(.pwm, pin: pin)
            firmata.writePWMValue(checkedValue, pin: pin)
            setPortValue(Int(pin), value: Int(checkedValue))
        }
    }

    // MARK: ReportingData

    @objc func reportSensorData(_ report: Bool) {
        if isReportingSensorData == report {
            return
        }

        isReportingSensorData = report

        for i in type(of: self).minAnalogSensorPin ... type(of: self).maxAnalogSensorPin {
            reportAnalogArduinoPin(i, report: report)
        }
    }

    private func reportAnalogArduinoPin(_ analogPinNumber: Int, report: Bool) {
        let pin = UInt8(checkValue(analogPinNumber))
        if checkAnalogPinCapability(pin, neededMode: .unknown) {
            self.firmata.setAnalogValueReportingforPin(pin, enabled: report)
        }
    }

    // MARK: Reset
    func resetArduino() {
        reportSensorData(false)
        if !pinsArray.isEmpty {
            var i: Int = 0
            for _:[String: Any] in pinsArray {
                let pin = checkValue(i)
                if checkDigitalPinCapability(UInt8(pin), neededMode: .output) {
                    if i != 8 {
                        setDigitalArduinoPin(pin, pinValue: 0)
                    }
                }
                i += 1
            }
        } else {
            for i in 2 ... 11 {
                setDigitalArduinoPin(i, pinValue: 0)
            }
        }
        let totalAnalog = analogMapping.count
        var totalDigital = totalPins - totalAnalog
        if totalDigital < 0 {
            totalDigital = 21
        }
        arduinoHelper.digitalValues = [Int](repeating: 0, count: totalDigital)
        var ports = totalPins / 8 + 1
        if ports < 1 {
            ports = 3
        }
        arduinoHelper.portValues = Array(repeating: Array(repeating: 0, count: 8), count: ports)
    }

    // MARK: Helper

    private func checkDigitalPinCapability(_ pinNumber: UInt8, neededMode: PinMode) -> Bool {
        if !pinsArray.isEmpty {
            let pinCheck = "D\(pinNumber)"
            for pin in pinsArray {
                if let pinName = pin["name"] as? String, pinName == pinCheck {
                    if neededMode == .unknown {
                        return true
                    }
                    if let modes = pin["modes"] as? [Int: Int] {
                        for (mode, _) in modes where (mode == neededMode.rawValue) {
                            return true
                        }
                    }
                    return false
                }
            }
            //do not sent if no mapping
            return false
        }
        return true
    }

    private func checkAnalogPinCapability(_ pinNumber: UInt8, neededMode: PinMode) -> Bool {
        if !pinsArray.isEmpty {
            let pinCheck = "A\(pinNumber)"
            for pin in pinsArray {
                if let pinName = pin["name"] as? String, pinName == pinCheck {
                    if neededMode == .unknown {
                        return true
                    }
                    if let modes = pin["modes"] as? [Int: Int] {
                        for (mode, _) in modes where (mode == neededMode.rawValue) {
                            return true
                        }
                    }
                }
            }
            //do not sent if no mapping
            return false
        }
        return true
    }

    @objc
    func getAnalogPin(_ analogPinNumber: Int) -> Double {
        let pin = UInt8(checkValue(analogPinNumber))
        switch pin {
        case 0:
            return Double(getAnalogPin0())
        case 1:
            return Double(getAnalogPin1())
        case 2:
            return Double(getAnalogPin2())
        case 3:
            return Double(getAnalogPin3())
        case 4:
            return Double(getAnalogPin4())
        case 5:
            return Double(getAnalogPin5())
        default:
            return 0
        }
    }

    // MARK: Firmata delegate

    override func didReceiveDigitalMessage(_ pin: Int, value: Int) {
        arduinoHelper.didReceiveDigitalMessage(pin, value: value)
    }

    override func didReceiveDigitalPort(_ port: Int, portData: [Int]) {
        arduinoHelper.didReceiveDigitalPort(port, portData: portData)
        BluetoothService.swiftSharedInstance.signalDigitalSemaphore(true)
    }
    override func didReceiveAnalogMessage(_ pin: Int, value: Int) {
        //print("ANALOG::\(pin):::\(value)")
        var analogPin = 100
        if !pinsArray.isEmpty {
            let totalAnalog = analogMapping.count
            let totalDigital = totalPins - totalAnalog
            analogPin = pin - totalDigital
        } else {
            analogPin = convertAnalogPin(pin)
        }
        arduinoHelper.didReceiveAnalogMessage(analogPin, value: value)
        BluetoothService.swiftSharedInstance.signalAnalogSemaphore()
    }

    override func didUpdateAnalogMapping(_ analogMapping: NSMutableDictionary) {
        self.analogMapping = analogMapping
        firmata.capabilityQuery()
    }

    override func didUpdateCapability(_ pins: [[Int: Int]]) {
        totalPins = pins.count
        let totalAnalog = analogMapping.count
        let totalDigital = totalPins - totalAnalog

        var k = 0
        var pinArray = [[String: Any]]()
        for i in 0 ..< pins.count {
            let modes: [Int: Int] = pins[i]

            var pin: [String: Any] = [String: Any]()

            if i < totalDigital {
                pin["name"] = "D\(i)"
            } else {
                pin["name"] = "A\(k)"
                k += 1
            }
            pin["modes"] = modes
            pin["firmatapin"] = i
            pinArray.append(pin)
        }
        pinsArray = pinArray

        arduinoHelper.digitalValues = [Int](repeating: 0, count: totalDigital)
        let ports = totalPins / 8 + 1
        arduinoHelper.portValues = Array(repeating: Array(repeating: 0, count: 8), count: ports)
    }

    // MARK: setter/getter

    private func getAnalogPin0() -> Int {
        return arduinoHelper.analogPin0
    }

    internal func getAnalogPin1() -> Int {
        return arduinoHelper.analogPin1
    }

    internal func getAnalogPin2() -> Int {
        return arduinoHelper.analogPin2
    }

    internal func getAnalogPin3() -> Int {
        return arduinoHelper.analogPin3
    }

    internal func getAnalogPin4() -> Int {
        return arduinoHelper.analogPin4
    }

    internal func getAnalogPin5() -> Int {
        return arduinoHelper.analogPin5
    }

    internal func getPortValue(_ pin: Int) -> Int {
        let port: Int = pin / 8
        let portPin: Int = pin % 8
        if arduinoHelper.portValues[port][portPin] == arduinoHelper.digitalValues[pin] {
            print("true")
        }
        if arduinoHelper.digitalValues.count > pin {
            return arduinoHelper.digitalValues[pin]
        }
        return 0
    }

    internal func setPortValue(_ pin: Int, value: Int) {
        let port: Int = pin / 8
        let portPin: Int = pin % 8
        if arduinoHelper.digitalValues.count > pin {
            arduinoHelper.digitalValues[pin] = value
        }
        if arduinoHelper.portValues.count > port {
            if arduinoHelper.portValues[port].count > portPin {
                arduinoHelper.portValues[port][portPin] = value
            }
        }

    }

}

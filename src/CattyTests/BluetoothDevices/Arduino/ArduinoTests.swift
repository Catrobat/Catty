/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

import XCTest
import CoreBluetooth
import BluetoothHelper
@testable import Pocket_Code

class peripheralMock: CBPeripheral {
    init(test:Bool){
        //HACK
    }
    
    override func writeValue(data: NSData, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        
    }
}

class ArduinoTestMock: ArduinoPropertyProtocol {
    internal var totalPins = 3
    internal var analogMapping = NSMutableDictionary(objects: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)], forKeys: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)])
    internal var pinsArray = [[String:Any]]()
    
    internal let arduinoHelper:ArduinoHelper = ArduinoHelper()
}

class ArduinoTests: XCTestCase {
    
    var mock = ArduinoTestMock()
    var arduinoTest = ArduinoDevice(peripheral: Peripheral(cbPeripheral: peripheralMock(test: true), advertisements:[String:String](), rssi: 0))
    
    override func setUp( ) {
        super.setUp()
        mock = ArduinoTestMock()
        setPinsArray()
        arduinoTest.firmata = FirmataMock()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func setPinsArray() {
        var pinArray = [[String:Any]]()
        var pin1 : [Int:Int] = [Int:Int]()
        pin1[0] = 1
        pin1[3] = 1
        let pin2 : [Int:Int] = [2:2]
        let pin3 : [Int:Int] = [3:0]
        let pins = [pin1,pin2,pin3]
        var k = 0;
        for (var i = 0; i < 3 ; i++)
        {
            let modes:[Int:Int] = pins[i]
            
            var pin:[String:Any] = [String:Any]()
            
            if(i<2){
                pin["name"] = "D\(i)"
            }else{
                pin["name"] = "A\(k)"
                k++
            }
            pin["modes"] = modes
            pin["firmatapin"] = i
            pinArray.append(pin)
        }
        mock.pinsArray = pinArray
    }
    
    func fakeArduinoHelper() {
    
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK: ArduinoProtocolTests
    
    func testSetDigitalPin() {
        arduinoTest.setDigitalArduinoPin(4, pinValue: 1)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[4], 1 , "Pin is wrong")
        let firmataMock = arduinoTest.firmata as! FirmataMock
        XCTAssertEqual(firmataMock.receivedPin, 4 , "Pin is wrong")
    }
    
    
}

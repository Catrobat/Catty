/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

import Foundation
import CoreBluetooth
import BluetoothHelper


public class ArduinoHelper {
    var analogPin0 = 0;
    var analogPin1 = 0;
    var analogPin2 = 0;
    var analogPin3 = 0;
    var analogPin4 = 0;
    var analogPin5 = 0;
    
    var digitalValues:[Int] = [Int](count: 21, repeatedValue: 0)
    
    var portValues = Array(count: 3, repeatedValue: Array(count: 8, repeatedValue: 0))
    //Helper
    private var previousDigitalPin:UInt8 = 255;
    private var previousAnalogPin:UInt8 = 255;
    
    func didReceiveAnalogMessage(pin:Int,value:Int){
        switch (pin) {
        case 0:
            analogPin0 = value
            break
        case 1:
            analogPin1 = value
            break
        case 2:
            analogPin2 = value
            break
        case 3:
            analogPin3 = value
            break
        case 4:
            analogPin4 = value
            break
        case 5:
            analogPin5 = value
            break
            
        default: break
            //NOT USED SENSOR
        }

    }
    
    func didReceiveDigitalPort(port:Int, portData:[Int]){
        portValues[port] = portData
    }
    
    func didReceiveDigitalMessage(pin:Int,value:Int){
        digitalValues[pin] = value
    }
    
}

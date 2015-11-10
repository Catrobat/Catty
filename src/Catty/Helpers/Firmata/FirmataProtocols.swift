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

import Foundation

protocol FirmataDelegate {
    
    func sendData(newData: NSData)
    func didReceiveAnalogMessage(pin:Int,value:Int)
    func didReceiveDigitalMessage(pin:Int,value:Int)
    func firmwareVersionReceived(name:String)
    func protocolVersionReceived(name:String)
    //    func I2cMessageReceived(message:String)
    func stringDataReceived(message:String)
    func didReceiveDigitalPort(port:Int, portData:[Int])
    func didUpdateAnalogMapping(mapping:NSMutableDictionary)
    func didUpdateCapability(pins:[[Int:Int]])
}

protocol FirmataProtocol {
    func writePinMode(newMode:PinMode, pin:UInt8)
    func reportVersion()
    func reportFirmware()
    func analogMappingQuery()
    func capabilityQuery()
    func pinStateQuery(pin:UInt8)
    func servoConfig(pin:UInt8,minPulse:UInt8,maxPulse:UInt8)
    func stringData(string:String)
    func samplingInterval(intervalMilliseconds:UInt8)
    func writePWMValue(value:UInt8, pin:UInt8)
    func writePinState(newState: PinState, pin:UInt8)
    func setAnalogValueReportingforPin(pin:UInt8, enabled:Bool)
    func setDigitalStateReportingForPin(digitalPin:UInt8, enabled:Bool)
    func setDigitalStateReportingForPort(port:UInt8, enabled:Bool)
    func receiveData(data:NSData)
}

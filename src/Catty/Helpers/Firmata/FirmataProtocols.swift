/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
    
    func sendData(_ newData: Data)
    func didReceiveAnalogMessage(_ pin:Int,value:Int)
    func didReceiveDigitalMessage(_ pin:Int,value:Int)
    func firmwareVersionReceived(_ name:String)
    func protocolVersionReceived(_ name:String)
    //    func I2cMessageReceived(message:String)
    func stringDataReceived(_ message:String)
    func didReceiveDigitalPort(_ port:Int, portData:[Int])
    func didUpdateAnalogMapping(_ mapping:NSMutableDictionary)
    func didUpdateCapability(_ pins:[[Int:Int]])
}

protocol FirmataProtocol {
    func writePinMode(_ newMode:PinMode, pin:UInt8)
    func reportVersion()
    func reportFirmware()
    func analogMappingQuery()
    func capabilityQuery()
    func pinStateQuery(_ pin:UInt8)
    func servoConfig(_ pin:UInt8,minPulse:UInt8,maxPulse:UInt8)
    func stringData(_ string:String)
    func samplingInterval(_ intervalMilliseconds:UInt8)
    func writePWMValue(_ value:UInt8, pin:UInt8)
    func writePinState(_ newState: PinState, pin:UInt8)
    func setAnalogValueReportingforPin(_ pin:UInt8, enabled:Bool)
    func setDigitalStateReportingForPin(_ digitalPin:UInt8, enabled:Bool)
    func setDigitalStateReportingForPort(_ port:UInt8, enabled:Bool)
    func receiveData(_ data:Data)
    
    var delegate : FirmataDelegate! {get set}
}

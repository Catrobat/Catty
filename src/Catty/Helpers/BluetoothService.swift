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


public class BluetoothService:NSObject {
//    class var sharedInstance: BluetoothService {
//        struct Static {
//            static var onceToken: dispatch_once_t = 0
//            static var instance: BluetoothService? = nil
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = BluetoothService()
//        }
//        return Static.instance!
//    }
    class var swiftSharedInstance: BluetoothService {
        struct Singleton {
            static let instance = BluetoothService()
        }
        return Singleton.instance
    }
    
    // the sharedInstance class method can be reached from ObjC
    @objc public class func sharedInstance() -> BluetoothService {
        return BluetoothService.swiftSharedInstance
    }
    
    override init(){
        super.init()
    }

    
    var digitalSemaphoreArray:[dispatch_semaphore_t] = []
    var analogSemaphoreArray:[dispatch_semaphore_t] = []
    
    var phiro:Phiro?
    var arduino:ArduinoDevice?
    
    
    func setDigitalSemaphore(semaphore:dispatch_semaphore_t){
        digitalSemaphoreArray.append(semaphore)
    }
    
    func signalDigitalSemaphore(){
        if(digitalSemaphoreArray.count > 0){
            let sema = digitalSemaphoreArray[0]
            digitalSemaphoreArray.removeAtIndex(0)
            dispatch_semaphore_signal(sema)
        }
        
    }
    
    func setAnalogSemaphore(semaphore:dispatch_semaphore_t){
        analogSemaphoreArray.append(semaphore)
    }
    
    @objc public func signalAnalogSemaphore(){
        if(analogSemaphoreArray.count > 0){
            let sema = analogSemaphoreArray[0]
            analogSemaphoreArray.removeAtIndex(0)
            dispatch_semaphore_signal(sema)
        }
        
    }
    
    func getSemaphore()->dispatch_semaphore_t {
        return dispatch_semaphore_create(0)
    }
    
    @objc public func getSensorPhiro() -> Phiro? {
        guard let senorPhiro = phiro else{
            return nil
        }
        return senorPhiro
    }
    
    @objc public func getSensorArduino() -> ArduinoDevice? {
        guard let senorArduino = arduino else{
            return nil
        }
        return senorArduino
    }
    
}
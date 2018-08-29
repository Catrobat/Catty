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

import CoreMotion
import CoreLocation

@objc class FormulaManager: NSObject, FormulaManagerProtocol, FormulaInterpreterProtocol {
    
    let sensorManager: SensorManagerProtocol
    let functionManager: FunctionManagerProtocol
    
    let motionManager: MotionManager
    let locationManager: LocationManager
    let faceDetectionManager: FaceDetectionManagerProtocol
    let audioManager: AudioManagerProtocol
    let touchManager: TouchManagerProtocol
    let bluetoothService: BluetoothService
    
    override convenience init() {
        // TODO remove Singleton
        self.init(sensorManager: SensorManager.shared, functionManager: FunctionManager.shared)
    }
    
    convenience init(sensorManager: SensorManagerProtocol, functionManager: FunctionManagerProtocol) {
        self.init(sensorManager: sensorManager, functionManager: functionManager, motionManager: CMMotionManager(), locationManager: CLLocationManager(), faceDetectionManager: FaceDetectionManager.shared, audioManager: AudioManager(), touchManager: TouchManager(), bluetoothService: BluetoothService.sharedInstance())
    }
    
    init(sensorManager: SensorManagerProtocol, functionManager: FunctionManagerProtocol, motionManager: MotionManager, locationManager: LocationManager, faceDetectionManager: FaceDetectionManagerProtocol, audioManager: AudioManagerProtocol, touchManager: TouchManagerProtocol, bluetoothService: BluetoothService) {
        
        self.sensorManager = sensorManager
        self.functionManager = functionManager
        
        self.motionManager = motionManager
        self.locationManager = locationManager
        self.faceDetectionManager = faceDetectionManager
        self.audioManager = audioManager
        self.touchManager = touchManager
        self.bluetoothService = bluetoothService
    }
}

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

@objc class FormulaManager: NSObject, FormulaManagerProtocol {
    
    private let sensorManager: SensorManagerProtocol
    private let functionManager: FunctionManagerProtocol
    
    private let motionManager: MotionManager
    private let locationManager: LocationManager
    private let faceDetectionManager: FaceDetectionManagerProtocol
    private let audioManager: AudioManagerProtocol
    private let touchManager: TouchManagerProtocol
    private let bluetoothService: BluetoothService
    
    override convenience init() {
        // TODO remove Singleton
        self.init(sensorManager: SensorManager.shared, functionManager: FunctionManager.shared)
    }
    
    convenience init(sensorManager: SensorManagerProtocol, functionManager: FunctionManagerProtocol) {
        self.init(sensorManager: sensorManager, functionManager: functionManager, motionManager: CMMotionManager(), locationManager: CLLocationManager(), faceDetectionManager: FaceDetectionManager(), audioManager: AudioManager(), touchManager: TouchManager(), bluetoothService: BluetoothService.sharedInstance())
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
    
    @nonobjc func formulaEditorItems(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: true, objectSection: true, deviceSection: true)
    }
    
    @nonobjc func formulaEditorItemsForMathSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: true, objectSection: false, deviceSection: false)
    }
    
    @nonobjc func formulaEditorItemsForObjectSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: false, objectSection: true, deviceSection: false)
    }
    
    @nonobjc func formulaEditorItemsForDeviceSection(spriteObject: SpriteObject) -> [FormulaEditorItem] {
        return formulaEditorItems(for: spriteObject, mathSection: false, objectSection: false, deviceSection: true)
    }
    
    private func formulaEditorItems(for spriteObject: SpriteObject, mathSection: Bool, objectSection: Bool, deviceSection: Bool) -> [FormulaEditorItem] {
        var items = [FormulaEditorItem]()
        let allItems = sensorManager.formulaEditorItems(for: spriteObject) + functionManager.formulaEditorItems()
        
        for item in allItems {
            switch (item.section) {
            case .math(_):
                if (mathSection) {
                    items += item
                }
                
            case .object(_):
                if (objectSection) {
                    items += item
                }
                
            case .device(_):
                if (deviceSection) {
                    items += item
                }
                
            default:
                break;
            }
        }
        return items.sorted(by: { $0.section.position() < $1.section.position() }).map{ $0 }
    }
    
    func unavailableResources(for requiredResources: NSInteger) -> NSInteger {
        var unavailableResource: NSInteger = ResourceType.noResources.rawValue
        
        if requiredResources & ResourceType.accelerometer.rawValue > 0 && !motionManager.isAccelerometerAvailable {
            unavailableResource |= ResourceType.accelerometer.rawValue
        }
        if requiredResources & ResourceType.deviceMotion.rawValue > 0 && !motionManager.isDeviceMotionAvailable {
            unavailableResource |= ResourceType.deviceMotion.rawValue
        }
        if requiredResources & ResourceType.location.rawValue > 0 && !type(of: locationManager).locationServicesEnabled() {
            unavailableResource |= ResourceType.location.rawValue
        }
        if requiredResources & ResourceType.vibration.rawValue > 0 && !Util.isPhone() {
            unavailableResource |= ResourceType.vibration.rawValue
        }
        if requiredResources & ResourceType.compass.rawValue > 0 && !type(of: locationManager).headingAvailable() {
            unavailableResource |= ResourceType.compass.rawValue
        }
        if requiredResources & ResourceType.gyro.rawValue > 0 && !motionManager.isGyroAvailable {
            unavailableResource |= ResourceType.gyro.rawValue
        }
        if requiredResources & ResourceType.magnetometer.rawValue > 0 && !motionManager.isMagnetometerAvailable {
            unavailableResource |= ResourceType.magnetometer.rawValue
        }
        if requiredResources & ResourceType.faceDetection.rawValue > 0 && !faceDetectionManager.available() {
            unavailableResource |= ResourceType.faceDetection.rawValue
        }
        if requiredResources & ResourceType.loudness.rawValue > 0 && !audioManager.loudnessAvailable() {
            unavailableResource |= ResourceType.loudness.rawValue
        }
        
        return unavailableResource
    }
    
    @objc(setupForProgram: andScene:)
    func setup(for program: Program, and scene: CBScene) {
        let requiredResources = program.getRequiredResources()
        setup(for: requiredResources, and: scene)
    }
    
    @objc(setupForFormula:)
    func setup(for formula: Formula) {
        let requiredResources = formula.getRequiredResources()
        setup(for: requiredResources, and: nil)
    }
    
    private func setup(for requiredResources: Int, and scene:CBScene?) {
        let unavailableResource = unavailableResources(for: requiredResources)
        
        if (requiredResources & ResourceType.accelerometer.rawValue > 0) && (unavailableResource & ResourceType.accelerometer.rawValue) == 0  {
            motionManager.startAccelerometerUpdates()
        }
        if (requiredResources & ResourceType.deviceMotion.rawValue > 0) && (unavailableResource & ResourceType.deviceMotion.rawValue) == 0  {
            motionManager.startDeviceMotionUpdates()
        }
        if (requiredResources & ResourceType.magnetometer.rawValue > 0) && (unavailableResource & ResourceType.magnetometer.rawValue) == 0  {
            motionManager.startMagnetometerUpdates()
        }
        if (requiredResources & ResourceType.gyro.rawValue > 0) && (unavailableResource & ResourceType.gyro.rawValue) == 0  {
            motionManager.startGyroUpdates()
        }
        if (requiredResources & ResourceType.compass.rawValue > 0) && (unavailableResource & ResourceType.compass.rawValue) == 0  {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingHeading()
        }
        if (requiredResources & ResourceType.location.rawValue > 0) && (unavailableResource & ResourceType.location.rawValue) == 0  {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        if ((requiredResources & ResourceType.faceDetection.rawValue) > 0) && (unavailableResource & ResourceType.faceDetection.rawValue) == 0 {
            faceDetectionManager.start()
        }
        if ((requiredResources & ResourceType.loudness.rawValue) > 0) && (unavailableResource & ResourceType.loudness.rawValue) == 0 {
            audioManager.startLoudnessRecorder()
        }
        if ((requiredResources & ResourceType.touchHandler.rawValue) > 0) && (unavailableResource & ResourceType.touchHandler.rawValue) == 0 {
            guard let sc = scene else { return }
            touchManager.startTrackingTouches(for: sc)
        }
    }
    
    @objc func stop() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        faceDetectionManager.stop()
        audioManager.stopLoudnessRecorder()
        touchManager.stopTrackingTouches()
    }
}

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

@objc class CBSensorManager: NSObject, SensorManagerProtocol {
    
    @objc public static let shared = CBSensorManager()
    public var defaultValueForUndefinedSensor: Double = 0
    
    private var sensors: [String: CBSensor]
    private var motionManager: CMMotionManager
    private var locationManager: CLLocationManager
    
    override private init() {
        motionManager = CMMotionManager()
        locationManager = CLLocationManager()
        sensors = [String: CBSensor]()
        super.init()
        
        registerSensors()
    }
    
    func registerSensors() {
        let motionManagerGetter: () -> MotionManager? = { [weak self] in self?.motionManager }
        let locationManagerGetter: () -> LocationManager? = { [weak self] in self?.locationManager }
        let sensors: [CBSensor] = [
            InclinationXSensor(motionManagerGetter: motionManagerGetter),
            InclinationYSensor(motionManagerGetter: motionManagerGetter),
            AccelerationXSensor(motionManagerGetter: motionManagerGetter),
            AccelerationYSensor(motionManagerGetter: motionManagerGetter),
            AccelerationZSensor(motionManagerGetter: motionManagerGetter),
            CompassDirectionSensor(locationManagerGetter: locationManagerGetter)
        ]
        sensors.forEach { self.sensors[type(of: $0).tag] = $0 }
    }
    
    func sensor(tag: String) -> CBSensor? {
        return sensors[tag]
    }

//    func value(sensor: CBSensor) -> Double {
//        guard isAvailable(sensor: sensor) else { return sensor.defaultValue }
//        var rawValue: Double
//
//        switch sensor {
//        case let sensor as HeadingSensor:
//            locationManager.startUpdatingLocation()
//            rawValue = sensor.rawValue(heading: locationManager.heading!)
//
//        case let sensor as AccelerationSensor:
//            if (motionManager.isAccelerometerActive == false) {
//                motionManager.startAccelerometerUpdates()
//                Thread.sleep(forTimeInterval: 0.8)
//            }
//            rawValue = sensor.rawValue(acceleration: (motionManager.accelerometerData?.acceleration)!)
//
//        case let sensor as MotionSensor:
//            if (motionManager.isDeviceMotionActive == false) {
//                motionManager.startDeviceMotionUpdates()
//                Thread.sleep(forTimeInterval: 0.8)
//            }
//            rawValue = sensor.rawValue(motion: motionManager.deviceMotion!)
//
//        default:
//            return sensor.defaultValue
//        }
//
//        return sensor.transformToPocketCode(rawValue: rawValue)
//    }

    @objc func value(sensorTag: String, spriteObject: SpriteObject? = nil) -> Double {
        guard let sensor = sensor(tag: sensorTag) else { return defaultValueForUndefinedSensor }
        if let sensor = sensor as? ObjectSensor, let spriteObject = spriteObject {
            return sensor.standardizedValue(for: spriteObject)
        } else if let sensor = sensor as? DeviceSensor {
            return sensor.standardizedValue()
        }
        return type(of: sensor).defaultValue
    }
    
//    func isAvailable(sensor: CBSensor) -> Bool {
//        switch sensor {
//        case is HeadingSensor:
//            return CLLocationManager.headingAvailable()
//            
//        case is AccelerationSensor:
//            return motionManager.isAccelerometerAvailable
//            
//        case is MotionSensor:
//            return motionManager.isDeviceMotionAvailable
//            
//        default:
//            return true;
//        }
//    }
    
    func stopSensors() {
        locationManager.stopUpdatingHeading()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - CoreMotion protocol conformance

extension CMMotionManager: MotionManager {
    var accelerometerData: AccelerometerData? {
        return self.accelerometerData
    }
    var deviceMotion: DeviceMotion? {
        return self.deviceMotion
    }
}
extension CMAccelerometerData: AccelerometerData {
    var acceleration: Acceleration {
        return self.acceleration
    }
}
extension CMAcceleration: Acceleration {}

// MARK: - CoreLocation protocol conformance

extension CLLocationManager: LocationManager {
    var heading: Heading? {
        return self.heading
    }
}
extension CLHeading: Heading {}

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

@objc class CBSensorManager : NSObject, SensorManagerProtocol {
    
    @objc public static let shared = CBSensorManager()
    public var defaultValueForUndefinedSensor : Double = 0
    
    private var sensors : [String : CBSensor]
    private var motionManager : CMMotionManager
    private var locationManager : CLLocationManager
    
    override private init() {
        motionManager = CMMotionManager()
        locationManager = CLLocationManager()
        sensors = [String : CBSensor]()
        super.init()
        
        registerSensors()
    }
    
    func registerSensors() {
        register(sensor: InclinationXSensor())
        register(sensor: InclinationYSensor())
        register(sensor: AccelerationXSensor())
        register(sensor: AccelerationYSensor())
        register(sensor: AccelerationZSensor())
        register(sensor: CompassDirectionSensor())
    }
    
    func register(sensor: CBSensor) {
        sensors[sensor.tagForSerialization] = sensor
    }
    
    func sensor(tag: String) -> CBSensor? {
        return sensors[tag]
    }
    
    func value(sensor: CBSensor) -> Double {
        guard isAvailable(sensor: sensor) else { return sensor.defaultValue }
        var rawValue : Double
        
        switch sensor {
        case let sensor as HeadingSensor:
            locationManager.startUpdatingLocation()
            rawValue = sensor.rawValue(heading: locationManager.heading!)

        case let sensor as AccelerationSensor:
            if (motionManager.isAccelerometerActive == false) {
                motionManager.startAccelerometerUpdates()
                Thread.sleep(forTimeInterval: 0.8)
            }
            rawValue = sensor.rawValue(acceleration: (motionManager.accelerometerData?.acceleration)!)
            
        case let sensor as MotionSensor:
            if (motionManager.isDeviceMotionActive == false) {
                motionManager.startDeviceMotionUpdates()
                Thread.sleep(forTimeInterval: 0.8)
            }
            rawValue = sensor.rawValue(motion: motionManager.deviceMotion!)
            
        default:
            return sensor.defaultValue
        }
        
        return sensor.transformToPocketCode(rawValue: rawValue)
    }
    
    @objc func value(sensorTag: String) -> Double {
        guard let sensor = sensor(tag: sensorTag) else { return defaultValueForUndefinedSensor }
        return value(sensor: sensor)
    }
    
    func isAvailable(sensor: CBSensor) -> Bool {
        switch sensor {
        case _ as HeadingSensor:
            return CLLocationManager.headingAvailable()
            
        case _ as AccelerationSensor:
            return motionManager.isAccelerometerAvailable
            
        case _ as MotionSensor:
            return motionManager.isDeviceMotionAvailable
            
        default:
            return true;
        }
    }
    
    func stopSensors() {
        locationManager.stopUpdatingHeading()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}

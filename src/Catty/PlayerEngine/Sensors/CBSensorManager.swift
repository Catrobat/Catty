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
            BrightnessSensor(),
            LayerSensor(),
            PositionXSensor(),
            PositionYSensor(),
            RotationSensor(),
            SizeSensor(),
            TransparencySensor(),
            InclinationXSensor(motionManagerGetter: motionManagerGetter),
            InclinationYSensor(motionManagerGetter: motionManagerGetter),
            AccelerationXSensor(motionManagerGetter: motionManagerGetter),
            AccelerationYSensor(motionManagerGetter: motionManagerGetter),
            AccelerationZSensor(motionManagerGetter: motionManagerGetter),
            CompassDirectionSensor(locationManagerGetter: locationManagerGetter),
            LongitudeSensor(locationManagerGetter: locationManagerGetter)
        ]
        sensors.forEach { self.sensors[type(of: $0).tag] = $0 }
    }
    
    func sensor(tag: String) -> CBSensor? {
        return sensors[tag]
    }
    
    // TODO write test
    @objc func resource(sensorTag: String) -> ResourceType {
        guard let sensor = self.sensor(tag: sensorTag) else { return .noResources }
        return type(of: sensor).requiredResource
    }

    @objc func value(sensorTag: String, spriteObject: SpriteObject? = nil) -> Double {
        guard let sensor = sensor(tag: sensorTag) else { return defaultValueForUndefinedSensor }
        if let sensor = sensor as? ObjectSensor, let spriteObject = spriteObject {
            return sensor.standardizedValue(for: spriteObject)
        } else if let sensor = sensor as? DeviceSensor {
            return sensor.standardizedValue()
        }
        return type(of: sensor).defaultValue
    }
    
    @objc(setupSensorsForRequiredResources:)
    func setupSensors(for requiredResources: NSInteger) {
        let unavailableResource = getUnavailableResources(for: requiredResources)
        
        if (requiredResources & ResourceType.accelerometer.rawValue > 0) && (unavailableResource & ResourceType.accelerometer.rawValue) == 0  {
            self.motionManager.startDeviceMotionUpdates()
        }
        
        if (requiredResources & ResourceType.compass.rawValue > 0) && (unavailableResource & ResourceType.compass.rawValue) == 0  {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingHeading()
        }
        
        if (requiredResources & ResourceType.location.rawValue > 0) && (unavailableResource & ResourceType.location.rawValue) == 0  {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @objc(getUnavailableResources:)
    func getUnavailableResources(for requiredResources: NSInteger) -> NSInteger {
        var unavailableResource: NSInteger = ResourceType.noResources.rawValue
        
        if requiredResources & ResourceType.accelerometer.rawValue > 0 && !self.motionManager.isAccelerometerAvailable {
            unavailableResource |= ResourceType.accelerometer.rawValue
        }
        
        if requiredResources & ResourceType.location.rawValue > 0 && !type(of: self.locationManager).locationServicesEnabled() {
            unavailableResource |= ResourceType.accelerometer.rawValue
        }
        
        if requiredResources & ResourceType.vibration.rawValue > 0 && !Util.isPhone() {
            unavailableResource |= ResourceType.vibration.rawValue
        }
        
        if requiredResources & ResourceType.compass.rawValue > 0 && !type(of: self.locationManager).headingAvailable() {
            unavailableResource |= ResourceType.compass.rawValue
        }
        
        if requiredResources & ResourceType.gyro.rawValue > 0 && !self.motionManager.isGyroAvailable {
            unavailableResource |= ResourceType.gyro.rawValue
        }
        
        if requiredResources & ResourceType.magnetometer.rawValue > 0 && !self.motionManager.isMagnetometerAvailable {
            unavailableResource |= ResourceType.magnetometer.rawValue
        }
        
        // TODO
        /*if requiredResources & ResourceType.loudness.rawValue > 0 && !self.motionManager.isMagnetometerAvailable {
            unavailableResource |= ResourceType.loudness.rawValue
        }*/
        
        return unavailableResource
    }
    
    func stopSensors() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}

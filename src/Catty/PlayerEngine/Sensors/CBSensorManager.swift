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
    
    private var sensors: [CBSensor]
    private var sensorMap: [String: CBSensor]
    private var motionManager: CMMotionManager
    private var locationManager: CLLocationManager
    private var bluetoothService: BluetoothService
    private var faceDetectionManager: FaceDetection
    
    override private init() {
        motionManager = CMMotionManager()
        locationManager = CLLocationManager()
        bluetoothService = BluetoothService.sharedInstance()
        faceDetectionManager = FaceDetection()
        sensors = [CBSensor]()
        sensorMap = [String: CBSensor]()
        super.init()
        
        registerSensors()
    }
    
    func registerSensors() {
        let motionManagerGetter: () -> MotionManager? = { [weak self] in self?.motionManager }
        let locationManagerGetter: () -> LocationManager? = { [weak self] in self?.locationManager }
        let bluetoothServiceGetter: () -> BluetoothService? = { [weak self] in self?.bluetoothService }
        
        // In the Formula Editor the sensors appear in the same order
        self.sensors = [
            InclinationXSensor(motionManagerGetter: motionManagerGetter),
            InclinationYSensor(motionManagerGetter: motionManagerGetter),
            AccelerationXSensor(motionManagerGetter: motionManagerGetter),
            AccelerationYSensor(motionManagerGetter: motionManagerGetter),
            AccelerationZSensor(motionManagerGetter: motionManagerGetter),
            CompassDirectionSensor(locationManagerGetter: locationManagerGetter),
            LatitudeSensor(locationManagerGetter: locationManagerGetter),
            LongitudeSensor(locationManagerGetter: locationManagerGetter),
            LocationAccuracySensor(locationManagerGetter: locationManagerGetter),
            AltitudeSensor(locationManagerGetter: locationManagerGetter),
            FingerTouchedSensor(),
            FingerXSensor(),
            FingerYSensor(),
            LastFingerIndexSensor(),
            
            DateYearSensor(),
            DateMonthSensor(),
            DateDaySensor(),
            DateWeekdaySensor(),
            TimeHourSensor(),
            TimeMinuteSensor(),
            TimeSecondSensor(),
            
            /*MultiFingerTouchedSensor(),
            MultiFingerXSensor(),
            MultiFingerYSensor(),
            
             
            FaceDetectedSensor(),
            FaceSizeSensor(),
            FacePositionXSensor(),
            FacePositionYSensor(),*/
            
            PhiroFrontLeftSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroFrontRightSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroSideLeftSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroSideRightSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroBottomLeftSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroBottomRightSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            
            /*ArduinoAnalogPinSensor(), // only show if [[NSUserDefaults standardUserDefaults] boolForKey:kUseArduinoBricks]
            ArduinoDigitalPinSensor(),*/
 
            PositionXSensor(),
            PositionYSensor(),
            TransparencySensor(),
            BrightnessSensor(),
            ColorSensor(),
            BackgroundNumberSensor(), // only for background
            BackgroundNameSensor(), // only for background
            LookNumberSensor(), // only for look
            LookNameSensor(), // only for look
            
            SizeSensor(),
            RotationSensor(),
            LayerSensor()
        ]
        self.sensors.forEach { self.sensorMap[type(of: $0).tag] = $0 }
    }
    
    @objc func sensorList() -> [CBSensor] {
        return self.sensors
    }
    
    @objc func deviceSensors() -> [DeviceSensor] {
        return self.sensors.filter{$0 is DeviceSensor}.map{ $0 as! DeviceSensor }
    }
    
    @objc func objectSensors() -> [ObjectSensor] {
        return self.sensors.filter{$0 is ObjectSensor}.map{ $0 as! ObjectSensor }
    }
    
    @objc func phiroSensors() -> [PhiroSensor] {
        return self.sensors.filter{$0 is PhiroSensor}.map{ $0 as! PhiroSensor }
    }
    
    @objc func sensor(tag: String) -> CBSensor? {
        return self.sensorMap[tag]
    }
    
    @objc func tag(sensor: CBSensor) -> String {
        return type(of: sensor).tag
    }
    
    @objc func name(sensor: CBSensor) -> String {
        return type(of: sensor).name
    }
    
    @objc func name(tag: String) -> String? {
        guard let sensor = self.sensor(tag: tag) else { return nil }
        return type(of: sensor).name
    }
    
    // TODO write test
    @objc func requiredResource(sensorTag: String) -> ResourceType {
        guard let sensor = self.sensor(tag: sensorTag) else { return .noResources }
        return type(of: sensor).requiredResource
    }

    @objc func value(sensorTag: String, spriteObject: SpriteObject? = nil) -> AnyObject {
        guard let sensor = sensor(tag: sensorTag) else { return defaultValueForUndefinedSensor as AnyObject }
        
        if let sensor = sensor as? ObjectSensor, let spriteObject = spriteObject {
            return sensor.standardizedValue(for: spriteObject) as AnyObject
        } else if let sensor = sensor as? DeviceSensor {
            return sensor.standardizedValue() as AnyObject
        } else if let sensor = sensor as? StringSensor {
            return sensor.value() as AnyObject
        }
        
        return type(of: sensor).defaultValue as AnyObject
    }
    
    @objc(setupSensorsForRequiredResources:)
    func setupSensors(for requiredResources: NSInteger) {
        let unavailableResource = getUnavailableResources(for: requiredResources)
        
        if (requiredResources & ResourceType.accelerometer.rawValue > 0) && (unavailableResource & ResourceType.accelerometer.rawValue) == 0  {
            motionManager.startDeviceMotionUpdates()
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
    }
    
    @objc(getUnavailableResources:)
    func getUnavailableResources(for requiredResources: NSInteger) -> NSInteger {
        var unavailableResource: NSInteger = ResourceType.noResources.rawValue
        
        if requiredResources & ResourceType.accelerometer.rawValue > 0 && !motionManager.isAccelerometerAvailable {
            unavailableResource |= ResourceType.accelerometer.rawValue
        }
        
        if requiredResources & ResourceType.location.rawValue > 0 && !type(of: locationManager).locationServicesEnabled() {
            unavailableResource |= ResourceType.accelerometer.rawValue
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
        
        // TODO
        /*if requiredResources & ResourceType.loudness.rawValue > 0 && ![[SensorHandler sharedSensorHandler] loudnessAvailable] {
            unavailableResource |= ResourceType.loudness.rawValue
        }*/
        
        return unavailableResource
    }
    
    func stopSensors() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        faceDetectionManager.stop()
    }
}

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
    
    private var deviceSensorList = [DeviceSensor]()
    private var objectSensorList = [ObjectSensor]()
    private var sensorMap = [String: CBSensor]()
    
    private var motionManager: CMMotionManager
    private var locationManager: CLLocationManager
    private var bluetoothService: BluetoothService
    private var faceDetectionManager: FaceDetectionManagerProtocol
    private var audioManager: AudioManagerProtocol
    
    override private init() {
        motionManager = CMMotionManager()
        locationManager = CLLocationManager()
        
        bluetoothService = BluetoothService.sharedInstance()
        faceDetectionManager = FaceDetectionManager()
        audioManager = AudioManager()

        super.init()
        
        registerDeviceSensors()
        registerObjectSensors()
    }
    
    func registerDeviceSensors() {
        let motionManagerGetter: () -> MotionManager? = { [weak self] in self?.motionManager }
        let locationManagerGetter: () -> LocationManager? = { [weak self] in self?.locationManager }
        let bluetoothServiceGetter: () -> BluetoothService? = { [weak self] in self?.bluetoothService }
        let audioManagerGetter: () -> AudioManagerProtocol? = { [weak self] in self?.audioManager }
        let faceDetectionManagerGetter: () -> FaceDetectionManagerProtocol? = { [weak self] in self?.faceDetectionManager }
        
        // In the Formula Editor the sensors appear in the same order
        self.deviceSensorList = [
            LoudnessSensor(audioManagerGetter: audioManagerGetter),
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
            MultiFingerYSensor(),*/
             
            FaceDetectedSensor(faceDetectionManagerGetter: faceDetectionManagerGetter),
            /*FaceSizeSensor(),
            FacePositionXSensor(),
            FacePositionYSensor(),*/
            
            PhiroFrontLeftSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroFrontRightSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroBottomLeftSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroBottomRightSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroSideLeftSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            PhiroSideRightSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            
            ArduinoAnalogPinSensor(bluetoothServiceGetter: bluetoothServiceGetter),
            ArduinoDigitalPinSensor(bluetoothServiceGetter: bluetoothServiceGetter)
        ]
        
        self.deviceSensorList.forEach { self.sensorMap[type(of: $0).tag] = $0 }
    }
    
    func registerObjectSensors() {
        // In the Formula Editor the sensors appear in the same order
        self.objectSensorList = [
            PositionXSensor(),
            PositionYSensor(),
            TransparencySensor(),
            BrightnessSensor(),
            ColorSensor(),
            SizeSensor(),
            RotationSensor(),
            LayerSensor(),
            BackgroundNumberSensor(), // only for background
            BackgroundNameSensor(), // only for background
            LookNumberSensor(), // only for look
            LookNameSensor() // only for look
        ]
        
        self.objectSensorList.forEach { self.sensorMap[type(of: $0).tag] = $0 }
    }
    
    func deviceSensors() -> [DeviceSensor] {
        return self.deviceSensorList.map{ $0 }
    }
    
    func objectSensors() -> [ObjectSensor] {
        return self.objectSensorList.map{ $0 }
    }
    
    func phiroSensors() -> [PhiroSensor] {
        return self.deviceSensorList.filter{$0 is PhiroSensor}.map{ $0 as! PhiroSensor }
    }
    
    func sensor(tag: String) -> CBSensor? {
        return self.sensorMap[tag]
    }
    
    func tag(sensor: CBSensor) -> String {
        return type(of: sensor).tag
    }
    
    func name(sensor: CBSensor) -> String {
        return type(of: sensor).name
    }
    
    @objc func name(tag: String) -> String? {
        guard let sensor = self.sensor(tag: tag) else { return nil }
        return type(of: sensor).name
    }
    
    @objc func exists(tag: String) -> Bool {
        return self.sensor(tag: tag) != nil
    }
    
    // TODO write test
    @objc func requiredResource(sensorTag: String) -> ResourceType {
        guard let sensor = self.sensor(tag: sensorTag) else { return .noResources }
        return type(of: sensor).requiredResource
    }

    @objc func value(sensorTag: String, spriteObject: SpriteObject? = nil) -> AnyObject {
        guard let sensor = sensor(tag: sensorTag) else { return defaultValueForUndefinedSensor as AnyObject }
        var rawValue: AnyObject = type(of: sensor).defaultRawValue as AnyObject
        
        if let sensor = sensor as? ObjectSensor, let spriteObject = spriteObject {
            if let sensor = sensor as? ObjectDoubleSensor {
                rawValue = type(of: sensor).standardizedValue(for: spriteObject) as AnyObject
            }
            if let sensor = sensor as? ObjectStringSensor {
                rawValue = type(of: sensor).standardizedValue(for: spriteObject) as AnyObject
            }
        } else if let sensor = sensor as? DeviceSensor {
            rawValue = sensor.standardizedValue() as AnyObject
        }
        
        return rawValue
    }
    
    @objc(setupSensorsForRequiredResources:)
    func setupSensors(for requiredResources: NSInteger) {
        let unavailableResource = getUnavailableResources(for: requiredResources)
        
        if (requiredResources & ResourceType.accelerometer.rawValue > 0) && (unavailableResource & ResourceType.accelerometer.rawValue) == 0  {
            motionManager.startAccelerometerUpdates()
        }
        
        if (requiredResources & ResourceType.deviceMotion.rawValue > 0) && (unavailableResource & ResourceType.deviceMotion.rawValue) == 0  {
            motionManager.startDeviceMotionUpdates()
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
        
        if requiredResources & ResourceType.faceDetection.rawValue > 0 && !faceDetectionManager.available() {
            unavailableResource |= ResourceType.faceDetection.rawValue
        }
        
        if requiredResources & ResourceType.loudness.rawValue > 0 && !audioManager.loudnessAvailable() {
            unavailableResource |= ResourceType.loudness.rawValue
        }
        
        return unavailableResource
    }
    
    @objc func stopSensors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopGyroUpdates()
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        faceDetectionManager.stop()
        audioManager.stopLoudnessRecorder()
    }
}

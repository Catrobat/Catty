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
    public static var defaultValueForUndefinedSensor: Double = 0
    private var sensorMap = [String: CBSensor]()
    
    private var motionManager: CMMotionManager
    private var locationManager: CLLocationManager
    private var faceDetectionManager: FaceDetectionManagerProtocol
    private var audioManager: AudioManagerProtocol
    private var touchManager: TouchManagerProtocol
    private var bluetoothService: BluetoothService
    
    override private init() {
        motionManager = CMMotionManager()
        locationManager = CLLocationManager()
        faceDetectionManager = FaceDetectionManager()
        audioManager = AudioManager()
        touchManager = TouchManager()
        bluetoothService = BluetoothService.sharedInstance()

        super.init()
        registerSensors()
    }
    
    private func registerSensors() {
        let motionManagerGetter: () -> MotionManager? = { [weak self] in self?.motionManager }
        let locationManagerGetter: () -> LocationManager? = { [weak self] in self?.locationManager }
        let audioManagerGetter: () -> AudioManagerProtocol? = { [weak self] in self?.audioManager }
        let faceDetectionManagerGetter: () -> FaceDetectionManagerProtocol? = { [weak self] in self?.faceDetectionManager }
        let touchManagerGetter: () -> TouchManagerProtocol? = { [weak self] in self?.touchManager }
        let bluetoothServiceGetter: () -> BluetoothService? = { [weak self] in self?.bluetoothService }
        
        let sensorList: [CBSensor] = [
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
            FingerTouchedSensor(touchManagerGetter: touchManagerGetter),
            FingerXSensor(touchManagerGetter: touchManagerGetter),
            FingerYSensor(touchManagerGetter: touchManagerGetter),
            LastFingerIndexSensor(touchManagerGetter: touchManagerGetter),
            
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
            
            ArduinoAnalogPinSensor(bluetoothServiceGetter: bluetoothServiceGetter), // TODO implement as function with one parameter
            ArduinoDigitalPinSensor(bluetoothServiceGetter: bluetoothServiceGetter), // TODO implement as function with one parameter
            
            PositionXSensor(),
            PositionYSensor(),
            TransparencySensor(),
            BrightnessSensor(),
            ColorSensor(),
            SizeSensor(),
            RotationSensor(),
            LayerSensor(),
            BackgroundNumberSensor(),
            BackgroundNameSensor(),
            LookNumberSensor(),
            LookNameSensor()
        ]
        
        sensorList.forEach { self.sensorMap[type(of: $0).tag] = $0 }
    }
    
    func deviceSensors(for spriteObject: SpriteObject) -> [CBSensor] {
        var sensors = [Int: CBSensor]()
        
        for sensor in self.sensorMap.values {
            switch (type(of: sensor).formulaEditorSection(for: spriteObject)) {
            case let .device(position):
                sensors[position] = sensor
            default:
                break;
            }
        }
        return sensors.sorted(by: { $0.0 < $1.0 }).map{ $1}
    }
    
    func objectSensors(for spriteObject: SpriteObject) -> [CBSensor] {
        var sensors = [Int: CBSensor]()
        
        for sensor in self.sensorMap.values {
            switch (type(of: sensor).formulaEditorSection(for: spriteObject)) {
            case let .object(position):
                sensors[position] = sensor
            default:
                break;
            }
        }
        return sensors.sorted(by: { $0.0 < $1.0 }).map{ $1}
    }
    
    func phiroSensors() -> [PhiroSensor] {
        return self.sensorMap.values.filter{$0 is PhiroSensor}.map{ $0 as! PhiroSensor }
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
    @objc func requiredResource(tag: String) -> ResourceType {
        guard let sensor = self.sensor(tag: tag) else { return .noResources }
        return type(of: sensor).requiredResource
    }

    @objc func value(tag: String, spriteObject: SpriteObject? = nil) -> AnyObject {
        guard let sensor = sensor(tag: tag) else { return type(of: self).defaultValueForUndefinedSensor as AnyObject }
        var rawValue: AnyObject = type(of: sensor).defaultRawValue as AnyObject
        
        if let sensor = sensor as? ObjectSensor, let spriteObject = spriteObject {
            if let sensor = sensor as? ObjectDoubleSensor {
                rawValue = type(of: sensor).standardizedValue(for: spriteObject) as AnyObject
            } else if let sensor = sensor as? ObjectStringSensor {
                rawValue = type(of: sensor).standardizedValue(for: spriteObject) as AnyObject
            }
        } else if let sensor = sensor as? TouchSensor, let spriteObject = spriteObject {
            rawValue = sensor.standardizedValue(for: spriteObject) as AnyObject
        } else if let sensor = sensor as? DeviceSensor {
            rawValue = sensor.standardizedValue() as AnyObject
        }
        
        return rawValue
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
    
    @objc(setupSensorsForProgram: andScene:)
    func setup(for program: Program, and scene:CBScene) {
        let requiredResources = program.getRequiredResources()
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
        
        if ((requiredResources & ResourceType.touchHandler.rawValue) > 0) && (unavailableResource & ResourceType.touchHandler.rawValue) == 0 {
            touchManager.startTrackingTouches(for: scene)
        }
    }
    
    @objc func stop() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopGyroUpdates()
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        faceDetectionManager.stop()
        audioManager.stopLoudnessRecorder()
        touchManager.stopTrackingTouches()
    }
}

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
    
    var cachedResults = [FormulaElement: AnyObject]()
    
    override convenience init() {
        let motionManager = CMMotionManager()
        let locationManager = CLLocationManager()
        let faceDetectionManager = FaceDetectionManager.shared
        let audioManager = AudioManager()
        let touchManager = TouchManager()
        let bluetoothService = BluetoothService.sharedInstance()
        
        let sensorManager = FormulaManager.buildSensorManager(motionManager: motionManager, locationManager: locationManager, faceDetectionManager: faceDetectionManager, audioManager: audioManager, touchManager: touchManager, bluetoothService: bluetoothService)
        
        let functionManager = FormulaManager.buildFunctionManager(touchManager: touchManager, bluetoothService: bluetoothService)
        
        self.init(sensorManager: sensorManager, functionManager: functionManager, motionManager: motionManager, locationManager: locationManager, faceDetectionManager: faceDetectionManager, audioManager: audioManager, touchManager: touchManager, bluetoothService: bluetoothService)
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
    
    @objc func functionExists(tag: String) -> Bool {
        return self.functionManager.exists(tag: tag)
    }
    
    @objc func sensorExists(tag: String) -> Bool {
        return self.sensorManager.exists(tag: tag)
    }
    
    private static func buildSensorManager(motionManager: MotionManager, locationManager: LocationManager, faceDetectionManager: FaceDetectionManager, audioManager: AudioManagerProtocol, touchManager: TouchManagerProtocol, bluetoothService: BluetoothService) -> SensorManager {
        
        let sensorList: [Sensor] = [
            LoudnessSensor(audioManagerGetter: { audioManager }),
            InclinationXSensor(motionManagerGetter: { motionManager }),
            InclinationYSensor(motionManagerGetter: { motionManager }),
            AccelerationXSensor(motionManagerGetter: { motionManager }),
            AccelerationYSensor(motionManagerGetter: { motionManager }),
            AccelerationZSensor(motionManagerGetter: { motionManager }),
            CompassDirectionSensor(locationManagerGetter: { locationManager }),
            LatitudeSensor(locationManagerGetter: { locationManager }),
            LongitudeSensor(locationManagerGetter: { locationManager }),
            LocationAccuracySensor(locationManagerGetter: { locationManager }),
            AltitudeSensor(locationManagerGetter: { locationManager }),
            FingerTouchedSensor(touchManagerGetter: { touchManager }),
            FingerXSensor(touchManagerGetter: { touchManager }),
            FingerYSensor(touchManagerGetter: { touchManager }),
            LastFingerIndexSensor(touchManagerGetter: { touchManager }),
            
            DateYearSensor(),
            DateMonthSensor(),
            DateDaySensor(),
            DateWeekdaySensor(),
            TimeHourSensor(),
            TimeMinuteSensor(),
            TimeSecondSensor(),
            
            FaceDetectedSensor(faceDetectionManagerGetter: { faceDetectionManager }),
            FaceSizeSensor(faceDetectionManagerGetter: { faceDetectionManager }),
            FacePositionXSensor(faceDetectionManagerGetter: { faceDetectionManager }),
            FacePositionYSensor(faceDetectionManagerGetter: { faceDetectionManager }),
            
            PhiroFrontLeftSensor(bluetoothServiceGetter: { bluetoothService }),
            PhiroFrontRightSensor(bluetoothServiceGetter: { bluetoothService }),
            PhiroBottomLeftSensor(bluetoothServiceGetter: { bluetoothService }),
            PhiroBottomRightSensor(bluetoothServiceGetter: { bluetoothService }),
            PhiroSideLeftSensor(bluetoothServiceGetter: { bluetoothService }),
            PhiroSideRightSensor(bluetoothServiceGetter: { bluetoothService }),
            
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
        
        return SensorManager(sensors: sensorList)
    }
    
    private static func buildFunctionManager(touchManager: TouchManagerProtocol, bluetoothService: BluetoothService) -> FunctionManager {
        
        let functionManager = FunctionManager(functions: [
            SinFunction(),
            CosFunction(),
            TanFunction(),
            LnFunction(),
            LogFunction(),
            PiFunction(),
            SqrtFunction(),
            RandFunction(),
            AbsFunction(),
            RoundFunction(),
            ModFunction(),
            AsinFunction(),
            AcosFunction(),
            AtanFunction(),
            ExpFunction(),
            PowFunction(),
            FloorFunction(),
            CeilFunction(),
            MaxFunction(),
            MinFunction(),
            TrueFunction(),
            FalseFunction(),
            JoinFunction(),
            LetterFunction(),
            LengthFunction(),
            ElementFunction(),
            NumberOfItemsFunction(),
            ContainsFunction(),
            MultiFingerXFunction(touchManagerGetter: { touchManager }),
            MultiFingerYFunction(touchManagerGetter: { touchManager }),
            MultiFingerTouchedFunction(touchManagerGetter: { touchManager }),
            ArduinoAnalogPinFunction(bluetoothServiceGetter: { bluetoothService }),
            ArduinoDigitalPinFunction(bluetoothServiceGetter: { bluetoothService })
            ])
        
        return functionManager
    }
}

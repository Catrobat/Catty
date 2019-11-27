/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

import CoreLocation
import CoreMotion

@objc class FormulaManager: NSObject, FormulaManagerProtocol, FormulaInterpreterProtocol {

    let sensorManager: SensorManagerProtocol
    let functionManager: FunctionManagerProtocol
    let operatorManager: OperatorManagerProtocol
    let motionManager: MotionManager
    let locationManager: LocationManager
    let faceDetectionManager: FaceDetectionManagerProtocol
    let audioManager: AudioManagerProtocol
    let touchManager: TouchManagerProtocol
    let bluetoothService: BluetoothService
    let formulaCache: FormulaCache

    @objc(initWithSceneSize:)
    convenience init(sceneSize: CGSize) {
        let motionManager = CMMotionManager()
        let locationManager = CLLocationManager()
        let faceDetectionManager = FaceDetectionManager()
        let audioManager = AudioManager.shared()!
        let touchManager = TouchManager()
        let bluetoothService = BluetoothService.sharedInstance()

        let sensorManager =
            FormulaManager.buildSensorManager(sceneSize: sceneSize,
                                              motionManager: motionManager,
                                              locationManager: locationManager,
                                              faceDetectionManager: faceDetectionManager,
                                              audioManager: audioManager,
                                              touchManager: touchManager,
                                              bluetoothService: bluetoothService)

        let functionManager =
            FormulaManager.buildFunctionManager(touchManager: touchManager,
                                                bluetoothService: bluetoothService)

        let operatorManager = FormulaManager.buildOperatorManager()

        self.init(sensorManager: sensorManager,
                  functionManager: functionManager,
                  operatorManager: operatorManager,
                  motionManager: motionManager,
                  locationManager: locationManager,
                  faceDetectionManager: faceDetectionManager,
                  audioManager: audioManager,
                  touchManager: touchManager,
                  bluetoothService: bluetoothService)
    }

    convenience init(sensorManager: SensorManagerProtocol, functionManager: FunctionManagerProtocol, operatorManager: OperatorManagerProtocol) {
        self.init(sensorManager: sensorManager,
                  functionManager: functionManager,
                  operatorManager: operatorManager,
                  motionManager: CMMotionManager(),
                  locationManager: CLLocationManager(),
                  faceDetectionManager: FaceDetectionManager(),
                  audioManager: AudioManager(),
                  touchManager: TouchManager(),
                  bluetoothService: BluetoothService.sharedInstance())
    }

    init(sensorManager: SensorManagerProtocol,
         functionManager: FunctionManagerProtocol,
         operatorManager: OperatorManagerProtocol,
         motionManager: MotionManager,
         locationManager: LocationManager,
         faceDetectionManager: FaceDetectionManagerProtocol,
         audioManager: AudioManagerProtocol,
         touchManager: TouchManagerProtocol,
         bluetoothService: BluetoothService) {

        self.sensorManager = sensorManager
        self.functionManager = functionManager
        self.operatorManager = operatorManager

        self.motionManager = motionManager
        self.locationManager = locationManager
        self.faceDetectionManager = faceDetectionManager
        self.audioManager = audioManager
        self.touchManager = touchManager
        self.bluetoothService = bluetoothService

        self.formulaCache = FormulaCache()
    }

    @objc func functionExists(tag: String) -> Bool {
        return self.functionManager.exists(tag: tag)
    }

    @objc func sensorExists(tag: String) -> Bool {
        return self.sensorManager.exists(tag: tag)
    }

    @objc func operatorExists(tag: String) -> Bool {
        return self.operatorManager.exists(tag: tag)
    }

    func getFunction(tag: String) -> Function? {
        return self.functionManager.function(tag: tag)
    }

    func getSensor(tag: String) -> Sensor? {
        return self.sensorManager.sensor(tag: tag)
    }

    func getOperator(tag: String) -> Operator? {
        return self.operatorManager.getOperator(tag: tag)
    }

    private static func buildSensorManager(sceneSize: CGSize,
                                           motionManager: MotionManager,
                                           locationManager: LocationManager,
                                           faceDetectionManager: FaceDetectionManager,
                                           audioManager: AudioManagerProtocol,
                                           touchManager: TouchManagerProtocol,
                                           bluetoothService: BluetoothService) -> SensorManager {

        let sensors = CatrobatSetup.registeredSensors(sceneSize: sceneSize,
                                                      motionManager: motionManager,
                                                      locationManager: locationManager,
                                                      faceDetectionManager: faceDetectionManager,
                                                      audioManager: audioManager,
                                                      touchManager: touchManager,
                                                      bluetoothService: bluetoothService)

        return SensorManager(sensors: sensors)
    }

    private static func buildFunctionManager(touchManager: TouchManagerProtocol, bluetoothService: BluetoothService) -> FunctionManager {
        return FunctionManager(functions: CatrobatSetup.registeredFunctions(touchManager: touchManager, bluetoothService: bluetoothService))
    }

    private static func buildOperatorManager() -> OperatorManagerProtocol {
        return OperatorManager(operators: CatrobatSetup.registeredOperators())
    }
}

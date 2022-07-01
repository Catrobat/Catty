/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
    let visualDetectionManager: VisualDetectionManagerProtocol
    let audioManager: AudioManagerProtocol
    let touchManager: TouchManagerProtocol
    let bluetoothService: BluetoothService
    let formulaCache: FormulaCache

    @objc(initWithStageSize: andLandscapeMode:)
    convenience init(stageSize: CGSize, landscapeMode: Bool) {
        let motionManager = CMMotionManager()
        let locationManager = CLLocationManager()
        let visualDetectionManager = VisualDetectionManager()
        let audioManager = AudioManager.shared()!
        let touchManager = TouchManager()
        let bluetoothService = BluetoothService.sharedInstance()

        let sensorManager =
            FormulaManager.buildSensorManager(stageSize: stageSize,
                                              motionManager: motionManager,
                                              locationManager: locationManager,
                                              visualDetectionManager: visualDetectionManager,
                                              audioManager: audioManager,
                                              touchManager: touchManager,
                                              bluetoothService: bluetoothService,
                                              landscapeMode: landscapeMode)

        let functionManager =
        FormulaManager.buildFunctionManager(stageSize: stageSize,
                                            touchManager: touchManager,
                                            visualDetectionManager: visualDetectionManager,
                                            bluetoothService: bluetoothService)

        let operatorManager = FormulaManager.buildOperatorManager()

        self.init(sensorManager: sensorManager,
                  functionManager: functionManager,
                  operatorManager: operatorManager,
                  motionManager: motionManager,
                  locationManager: locationManager,
                  visualDetectionManager: visualDetectionManager,
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
                  visualDetectionManager: VisualDetectionManager(),
                  audioManager: AudioManager(),
                  touchManager: TouchManager(),
                  bluetoothService: BluetoothService.sharedInstance())
    }

    init(sensorManager: SensorManagerProtocol,
         functionManager: FunctionManagerProtocol,
         operatorManager: OperatorManagerProtocol,
         motionManager: MotionManager,
         locationManager: LocationManager,
         visualDetectionManager: VisualDetectionManagerProtocol,
         audioManager: AudioManagerProtocol,
         touchManager: TouchManagerProtocol,
         bluetoothService: BluetoothService) {

        self.sensorManager = sensorManager
        self.functionManager = functionManager
        self.operatorManager = operatorManager

        self.motionManager = motionManager
        self.locationManager = locationManager
        self.visualDetectionManager = visualDetectionManager
        self.audioManager = audioManager
        self.touchManager = touchManager
        self.bluetoothService = bluetoothService

        self.formulaCache = FormulaCache()
    }

    @objc func functionExists(tag: String) -> Bool {
        self.functionManager.exists(tag: tag)
    }

    @objc func sensorExists(tag: String) -> Bool {
        self.sensorManager.exists(tag: tag)
    }

    @objc func operatorExists(tag: String) -> Bool {
        self.operatorManager.exists(tag: tag)
    }

    func getFunction(tag: String) -> Function? {
        self.functionManager.function(tag: tag)
    }

    func getSensor(tag: String) -> Sensor? {
        self.sensorManager.sensor(tag: tag)
    }

    func getOperator(tag: String) -> Operator? {
        self.operatorManager.getOperator(tag: tag)
    }

    private static func buildSensorManager(stageSize: CGSize,
                                           motionManager: MotionManager,
                                           locationManager: LocationManager,
                                           visualDetectionManager: VisualDetectionManager,
                                           audioManager: AudioManagerProtocol,
                                           touchManager: TouchManagerProtocol,
                                           bluetoothService: BluetoothService,
                                           landscapeMode: Bool) -> SensorManager {

        let sensors = CatrobatSetup.registeredSensors(stageSize: stageSize,
                                                      motionManager: motionManager,
                                                      locationManager: locationManager,
                                                      visualDetectionManager: visualDetectionManager,
                                                      audioManager: audioManager,
                                                      touchManager: touchManager,
                                                      bluetoothService: bluetoothService)

        return SensorManager(sensors: sensors, landscapeMode: landscapeMode)
    }

    private static func buildFunctionManager(stageSize: CGSize,
                                             touchManager: TouchManagerProtocol,
                                             visualDetectionManager: VisualDetectionManager,
                                             bluetoothService: BluetoothService) -> FunctionManager {

        FunctionManager(functions: CatrobatSetup.registeredFunctions(stageSize: stageSize,
                                                                     touchManager: touchManager,
                                                                     visualDetectionManager: visualDetectionManager,
                                                                     bluetoothService: bluetoothService))
    }

    private static func buildOperatorManager() -> OperatorManagerProtocol {
        OperatorManager(operators: CatrobatSetup.registeredOperators())
    }
}

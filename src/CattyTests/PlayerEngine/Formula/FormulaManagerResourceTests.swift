/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

import XCTest

@testable import Pocket_Code

final class FormulaManagerResourceTests: XCTestCase {

    var manager: FormulaManager!
    var motionManager: MotionManagerMock!
    var locationManager: LocationManagerMock!
    var faceDetectionManager: FaceDetectionManagerMock!
    var audioManager: AudioManagerMock!
    var touchManager: TouchManagerMock!
    var bluetoothService: BluetoothService!

    override func setUp() {
        motionManager = MotionManagerMock()
        locationManager = LocationManagerMock()
        faceDetectionManager = FaceDetectionManagerMock()
        audioManager = AudioManagerMock()
        touchManager = TouchManagerMock()
        bluetoothService = BluetoothService.sharedInstance()

        manager = FormulaManager(sensorManager: SensorManager(sensors: []),
                                 functionManager: FunctionManager(functions: []),
                                 operatorManager: OperatorManager(operators: []),
                                 motionManager: motionManager,
                                 locationManager: locationManager,
                                 faceDetectionManager: faceDetectionManager,
                                 audioManager: audioManager,
                                 touchManager: touchManager,
                                 bluetoothService: bluetoothService)
    }

    func testSetupForFormulaNoResources() {
        manager.setup(for: FormulaMock(requiredResource: .noResources))

        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaLocation() {
        manager.setup(for: FormulaMock(requiredResource: .location))

        XCTAssertTrue(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaCompass() {
        manager.setup(for: FormulaMock(requiredResource: .compass))

        XCTAssertTrue(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaGyro() {
        manager.setup(for: FormulaMock(requiredResource: .gyro))

        XCTAssertTrue(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaDeviceMotion() {
        manager.setup(for: FormulaMock(requiredResource: .deviceMotion))

        XCTAssertTrue(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaMagnetometer() {
        manager.setup(for: FormulaMock(requiredResource: .magnetometer))

        XCTAssertTrue(motionManager.isMagnetometerUpdateStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaFaceDetection() {
        manager.setup(for: FormulaMock(requiredResource: .faceDetection))

        XCTAssertTrue(faceDetectionManager.isStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaLoudness() {
        manager.setup(for: FormulaMock(requiredResource: .loudness))

        XCTAssertTrue(audioManager.isStarted)
        XCTAssertFalse(audioManager.isPaused)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testSetupForFormulaAccelerometer() {
        manager.setup(for: FormulaMock(requiredResource: .accelerometer))

        XCTAssertTrue(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
    }

    func testSetupForFormulaAccelerometerAndDeviceMotion() {
        manager.setup(for: FormulaMock(requiredResource: .accelerometerAndDeviceMotion))

        XCTAssertTrue(motionManager.isAccelerometerUpdateStarted)
        XCTAssertTrue(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
    }

    func testSetupForFormulaTouchNotStarted() {
        manager.setup(for: FormulaMock(requiredResource: .touchHandler))

        XCTAssertFalse(touchManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
    }

    func testSetupForProject() {
        let project = ProjectMock(requiredResources: ResourceType.compass.rawValue | ResourceType.accelerometer.rawValue | ResourceType.deviceMotion.rawValue)
        let scene = SceneBuilder.init(project: project).build()
        manager.setup(for: project, and: scene)

        XCTAssertTrue(touchManager.isStarted)
        XCTAssertTrue(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertTrue(locationManager.isHeadingUpdateStarted)
        XCTAssertTrue(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
    }

    func testSetupForProjectAlwaysStartTouchManager() {
        let project = ProjectMock(requiredResources: ResourceType.noResources.rawValue)
        let scene = SceneBuilder.init(project: project).build()
        manager.setup(for: project, and: scene)

        XCTAssertTrue(touchManager.isStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(motionManager.isGyroUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
    }

    func testUnavailableResourcesAcceleromater() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.accelerometer.rawValue))

        motionManager.isAccelerometerAvailable = false
        XCTAssertEqual(ResourceType.accelerometer.rawValue, manager.unavailableResources(for: ResourceType.accelerometer.rawValue))
    }

    func testUnavailableResourcesAcceleromaterAndDeviceMotion() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.accelerometerAndDeviceMotion.rawValue))

        motionManager.isAccelerometerAvailable = false
        motionManager.isDeviceMotionAvailable = false
        XCTAssertEqual(ResourceType.accelerometer.rawValue | ResourceType.deviceMotion.rawValue, manager.unavailableResources(for: ResourceType.accelerometerAndDeviceMotion.rawValue))
    }

    func testUnavailableResourcesDeviceMotion() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.deviceMotion.rawValue))

        motionManager.isDeviceMotionAvailable = false
        XCTAssertEqual(ResourceType.deviceMotion.rawValue, manager.unavailableResources(for: ResourceType.deviceMotion.rawValue))
    }

    func testUnavailableResourcesLocation() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.location.rawValue))

        type(of: locationManager).isLocationServicesEnabled = false
        XCTAssertEqual(ResourceType.location.rawValue, manager.unavailableResources(for: ResourceType.location.rawValue))
    }

    func testUnavailableResourcesCompass() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.compass.rawValue))

        type(of: locationManager).isHeadingAvailable = false
        XCTAssertEqual(ResourceType.compass.rawValue, manager.unavailableResources(for: ResourceType.compass.rawValue))
    }

    func testUnavailableResourcesGyro() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.gyro.rawValue))

        motionManager.isGyroAvailable = false
        XCTAssertEqual(ResourceType.gyro.rawValue, manager.unavailableResources(for: ResourceType.gyro.rawValue))
    }

    func testUnavailableResourcesMagnetometer() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.magnetometer.rawValue))

        motionManager.isMagnetometerAvailable = false
        XCTAssertEqual(ResourceType.magnetometer.rawValue, manager.unavailableResources(for: ResourceType.magnetometer.rawValue))
    }

    func testUnavailableResourcesFaceDetection() {
        XCTAssertEqual(ResourceType.noResources.rawValue, manager.unavailableResources(for: ResourceType.faceDetection.rawValue))

        faceDetectionManager.isAvailable = false
        XCTAssertEqual(ResourceType.faceDetection.rawValue, manager.unavailableResources(for: ResourceType.faceDetection.rawValue))
    }

    func testStop() {
        motionManager.isAccelerometerUpdateStarted = true
        motionManager.isDeviceMotionUpdateStarted = true
        motionManager.isMagnetometerUpdateStarted = true
        locationManager.isHeadingUpdateStarted = true
        locationManager.isLocationUpdateStarted = true
        faceDetectionManager.isStarted = true
        audioManager.isStarted = true
        touchManager.isStarted = true

        manager.stop()

        XCTAssertFalse(motionManager.isAccelerometerUpdateStarted)
        XCTAssertFalse(motionManager.isDeviceMotionUpdateStarted)
        XCTAssertFalse(motionManager.isMagnetometerUpdateStarted)
        XCTAssertFalse(locationManager.isHeadingUpdateStarted)
        XCTAssertFalse(locationManager.isLocationUpdateStarted)
        XCTAssertFalse(faceDetectionManager.isStarted)
        XCTAssertFalse(audioManager.isStarted)
        XCTAssertFalse(audioManager.isPaused)
        XCTAssertFalse(touchManager.isStarted)
    }

    func testPause() {
        audioManager.isPaused = false
        manager.pause()
        XCTAssertTrue(audioManager.isPaused)
    }

    func testResume() {
        audioManager.isPaused = true
        manager.resume()
        XCTAssertFalse(audioManager.isPaused)
    }
}

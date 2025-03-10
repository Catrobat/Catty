/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

extension FormulaManager {

    func unavailableResources(for requiredResources: NSInteger) -> NSInteger {
        var unavailableResource: NSInteger = ResourceType.noResources.rawValue

        if requiredResources & ResourceType.accelerometer.rawValue > 0 && !motionManager.isAccelerometerAvailable {
            unavailableResource |= ResourceType.accelerometer.rawValue
        }
        if requiredResources & ResourceType.deviceMotion.rawValue > 0 && !motionManager.isDeviceMotionAvailable {
            unavailableResource |= ResourceType.deviceMotion.rawValue
        }
        if requiredResources & ResourceType.location.rawValue > 0 && !type(of: locationManager).locationServicesEnabled() {
            unavailableResource |= ResourceType.location.rawValue
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
        if requiredResources & ResourceType.visualDetection.rawValue > 0 && !visualDetectionManager.available() {
            unavailableResource |= ResourceType.visualDetection.rawValue
        }
        if requiredResources & ResourceType.loudness.rawValue > 0 && !audioManager.loudnessAvailable() {
            unavailableResource |= ResourceType.loudness.rawValue
        }

        return unavailableResource
    }

    @objc(setupForProject: andStage:)
    func setup(for project: Project, and stage: Stage) {
        let requiredResources = project.getRequiredResources()
        setup(for: requiredResources, and: stage, startTrackingTouches: true)
    }

    @objc(setupForFormula:)
    func setup(for formula: Formula) {
        let requiredResources = formula.getRequiredResources()
        setup(for: requiredResources, and: nil, startTrackingTouches: false)
    }

    private func setup(for requiredResources: Int, and stage: Stage?, startTrackingTouches: Bool) {
        let unavailableResource = unavailableResources(for: requiredResources)

        if (requiredResources & ResourceType.accelerometer.rawValue > 0) && (unavailableResource & ResourceType.accelerometer.rawValue) == 0 {
            motionManager.startAccelerometerUpdates()
        }
        if (requiredResources & ResourceType.deviceMotion.rawValue > 0) && (unavailableResource & ResourceType.deviceMotion.rawValue) == 0 {
            motionManager.startDeviceMotionUpdates()
        }
        if (requiredResources & ResourceType.magnetometer.rawValue > 0) && (unavailableResource & ResourceType.magnetometer.rawValue) == 0 {
            motionManager.startMagnetometerUpdates()
        }
        if (requiredResources & ResourceType.gyro.rawValue > 0) && (unavailableResource & ResourceType.gyro.rawValue) == 0 {
            motionManager.startGyroUpdates()
        }
        if (requiredResources & ResourceType.compass.rawValue > 0) && (unavailableResource & ResourceType.compass.rawValue) == 0 {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingHeading()
        }
        if (requiredResources & ResourceType.location.rawValue > 0) && (unavailableResource & ResourceType.location.rawValue) == 0 {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        if (requiredResources & ResourceType.visualDetection.rawValue > 0) && (unavailableResource & ResourceType.visualDetection.rawValue) == 0 {
            if requiredResources & ResourceType.faceDetection.rawValue > 0 {
                visualDetectionManager.startFaceDetection()
            }
            if requiredResources & ResourceType.handPoseDetection.rawValue > 0 {
                visualDetectionManager.startHandPoseDetection()
            }
            if requiredResources & ResourceType.bodyPoseDetection.rawValue > 0 {
                visualDetectionManager.startBodyPoseDetection()
            }
            if requiredResources & ResourceType.textRecognition.rawValue > 0 {
                visualDetectionManager.startTextRecognition()
            }
            if requiredResources & ResourceType.objectRecognition.rawValue > 0 {
                visualDetectionManager.startObjectRecognition()
            }
            visualDetectionManager.setStage(stage)
            visualDetectionManager.start()
        }
        if (requiredResources & ResourceType.loudness.rawValue > 0) && (unavailableResource & ResourceType.loudness.rawValue) == 0 {
            audioManager.startLoudnessRecorder()
        }

        if startTrackingTouches {
            guard let stage = stage else { return }
            touchManager.startTrackingTouches(for: stage)
        }
    }

    @objc func stop() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        visualDetectionManager.stop()
        audioManager.stopLoudnessRecorder()
        touchManager.stopTrackingTouches()

        invalidateCache()
    }

    func pause() {
        audioManager.pauseLoudnessRecorder()
    }

    func resume() {
        audioManager.resumeLoudnessRecorder()
    }
}

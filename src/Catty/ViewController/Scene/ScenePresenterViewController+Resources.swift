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

import BluetoothHelper
import CoreBluetooth

@objc extension ScenePresenterViewController {

    @objc(checkResourcesAndPushViewControllerTo:)
    func checkResourcesAndPushViewControllerTo(navigationController: UINavigationController) {
        self.formulaManager = FormulaManager()

        navigationController.view.addSubview(self.loadingView)
        self.showLoadingView()

        DispatchQueue.global(qos: .userInitiated).async {
            self.program = Program.init(loadingInfo: Util.lastUsedProgramLoadingInfo())!
            let readyToStart = self.notifyUserAboutUnavailableResources(navigationController: navigationController)

            DispatchQueue.main.async {
                if readyToStart && !(Util.topmostViewController() is ScenePresenterViewController) {
                    navigationController.pushViewController(self, animated: true)
                } else {
                    self.hideLoadingView()
                }
            }
        }
    }

    @nonobjc private func notifyUserAboutUnavailableResources(navigationController: UINavigationController) -> Bool {
        let requiredResources = program.getRequiredResources()

        // Bluetooth
        var unconnectedBluetoothDevices = [BluetoothDeviceID]()
        if (requiredResources & ResourceType.bluetoothPhiro.rawValue) > 0 && Util.isPhiroActivated() {
            if BluetoothService.sharedInstance().phiro?.state != CBPeripheralState.connected {
                unconnectedBluetoothDevices.append(.phiro)
            }
        }
        if (requiredResources & ResourceType.bluetoothArduino.rawValue) > 0 && Util.isArduinoActivated() {
            if BluetoothService.sharedInstance().arduino?.state != CBPeripheralState.connected {
                unconnectedBluetoothDevices.append(.arduino)
            }
        }

        if !unconnectedBluetoothDevices.isEmpty {
            bluetoothDevicesUnconnected(navigationController: navigationController, bluetoothDevices: unconnectedBluetoothDevices)
            return false
        }

        // All other resources
        let unavailableSensorResources = formulaManager.unavailableResources(for: requiredResources)
        var unavailableResourceNames = [String]()

        if (unavailableSensorResources & ResourceType.vibration.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedVibration)
        }
        if (unavailableSensorResources & ResourceType.deviceMotion.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedSensorDeviceMotion)
        }
        if (unavailableSensorResources & ResourceType.location.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedSensorLocation)
        }
        if (unavailableSensorResources & ResourceType.compass.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedSensorCompass)
        }
        if (unavailableSensorResources & ResourceType.accelerometer.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedSensorAcceleration)
        }
        if (unavailableSensorResources & ResourceType.gyro.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedSensorRotation)
        }
        if (unavailableSensorResources & ResourceType.magnetometer.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedSensorMagnetic)
        }
        if (unavailableSensorResources & ResourceType.loudness.rawValue) > 0 {
            unavailableResourceNames.append(kLocalizedSensorLoudness)
        }
        if ((requiredResources & ResourceType.LED.rawValue) > 0) && !FlashHelper.sharedFlashHandler().isAvailable() {
            unavailableResourceNames.append(kLocalizedSensorLED)
        }

        if !unavailableResourceNames.isEmpty {
            AlertControllerBuilder.alert(title: kLocalizedPocketCode, message: unavailableResourceNames.joined(separator: ", ") + " " + kLocalizedNotAvailable)
                .addCancelAction(title: kLocalizedCancel, handler: nil)
                .addDefaultAction(title: kLocalizedYes) {
                    self.continueWithoutRequiredResources(navigationController: navigationController)
                }
                .build()
                .showWithController(navigationController)

            return false
        }

        return true
    }

    @nonobjc private func bluetoothDevicesUnconnected(navigationController: UINavigationController, bluetoothDevices: [BluetoothDeviceID]) {
        let intDevices = bluetoothDevices.map { $0.rawValue }

        if CentralManager.sharedInstance.state == ManagerState.poweredOn || CentralManager.sharedInstance.state == ManagerState.unknown {
            let storyboard = UIStoryboard(name: "iPhone", bundle: nil)
            let bvc: BluetoothPopupVC = storyboard.instantiateViewController(withIdentifier: "bluetoothPopupVC") as! BluetoothPopupVC
            bvc.deviceArray = intDevices

            let navController = UINavigationController(rootViewController: bvc)
            self.present(navController, animated: true)

        } else if CentralManager.sharedInstance.state == ManagerState.poweredOff {
            Util.alert(withText: kLocalizedBluetoothPoweredOff)
        } else {
            Util.alert(withText: kLocalizedBluetoothNotAvailable)
        }
    }

    @nonobjc private func continueWithoutRequiredResources(navigationController: UINavigationController) {
        navigationController.pushViewController(self, animated: true)
    }
}

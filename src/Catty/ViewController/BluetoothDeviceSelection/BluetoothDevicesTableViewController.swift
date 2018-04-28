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

import Foundation
import BluetoothHelper
import CoreBluetooth

class BluetoothDevicesTableViewController: UITableViewController {

    weak var delegate : BluetoothPopupVC?
    weak var loadingView: LoadingView!

    override func viewDidLoad() {
        let loadingView = LoadingView() // helper variable due to self.loadingView being a weak property
        self.view.addSubview(loadingView)
        self.loadingView = loadingView
        self.tableView.backgroundColor = UIColor.background()
    }
    
    func updateWhenActive() {
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var peri = CentralManager.sharedInstance.peripherals[indexPath.row]
        if type(of: self) == SearchDevicesTableViewController.self {
            peri = CentralManager.sharedInstance.peripherals[indexPath.row]
        } else if type(of: self) == KnownDevicesTableViewController.self, let knownController = self as? KnownDevicesTableViewController {
            peri = knownController.knownDevices[indexPath.row]
            var found = false
            for peripheral in CentralManager.sharedInstance.peripherals {
                if peripheral.id == peri.id {
                    peri = peripheral
                    found = true
                }
            }
            if !found {
                return
            }
        }
        
        BluetoothService.swiftSharedInstance.selectionManager = self
        if peri.state == CBPeripheralState.connected {
            self.deviceConnected(peri)
            return
        }
        DispatchQueue.main.async(execute: {
            self.loadingView.show()
        })
        BluetoothService.swiftSharedInstance.connectDevice(peri)
    }
    
    func deviceConnected(_ peripheral:Peripheral) {
        if let delegate = self.delegate, let deviceArray = delegate.deviceArray, deviceArray.count > 0 {
            if deviceArray[0] == BluetoothDeviceID.phiro.rawValue {
                guard let _ = BluetoothService.sharedInstance().selectionManager else {
                    DispatchQueue.main.async {
                        Util.alert(withTitle: klocalizedBluetoothConnectionNotPossible, andText: klocalizedBluetoothConnectionTryResetting )
                        delegate.dismissView()
                    }
                    return
                }
                BluetoothService.swiftSharedInstance.setBLEDevice(peripheral, type: .phiro)
            } else if deviceArray[0] == BluetoothDeviceID.arduino.rawValue {
                guard let _ = BluetoothService.sharedInstance().selectionManager else {
                    DispatchQueue.main.async {
                        Util.alert(withTitle: klocalizedBluetoothConnectionNotPossible, andText:  klocalizedBluetoothConnectionTryResetting)
                        self.delegate?.dismissView()
                    }
                    return
                }
                BluetoothService.swiftSharedInstance.setBLEDevice(peripheral, type: .arduino)
            }
        }
    }
    
    func initScan() {
        let central = CentralManager.sharedInstance
        if central.isScanning {
            central.stopScanning()
            central.disconnectAllPeripherals()
            central.removeAllPeripherals()
            self.updateWhenActive()
        } else {
            central.disconnectAllPeripherals()
            central.removeAllPeripherals()
            CentralManager.sharedInstance.start().onSuccess {
                self.startScan()
            }
        }
    }
    
    func startScan(){
        
        let afterPeripheralDiscovered = {(peripheral:Peripheral) -> Void in
            self.updateWhenActive()
        }
        let afterTimeout = {(error:NSError) -> Void in
        }
        let future : FutureStream<Peripheral> = CentralManager.sharedInstance.startScan()
        future.onSuccess(afterPeripheralDiscovered)
        future.onFailure(afterTimeout)
    }
    
    func deviceFailedConnection(){
        DispatchQueue.main.async(execute: {
            self.loadingView.hide()
            CentralManager.sharedInstance.stopScanning()
            self.initScan()
        })
    }
    
    func deviceNotResponding(){
        DispatchQueue.main.async(execute: {
            self.loadingView.hide()
            CentralManager.sharedInstance.stopScanning()
            self.initScan()
        })
    }
    
    func giveUpConnectionToDevice(){
        DispatchQueue.main.async(execute: {
            self.loadingView.hide()
            CentralManager.sharedInstance.stopScanning()
            self.initScan()
        })
    }
    
    func checkStart(){
        delegate?.deviceArray?.remove(at: 0)
        if let count = delegate?.deviceArray?.count, count > 0 {
            delegate?.setHeader()
            return
        }
        tableView.isUserInteractionEnabled = false
        startScene()
    }

    func startScene(){
        let central = CentralManager.sharedInstance
        if central.isScanning {
            central.stopScanning()
        }
        delegate?.rightButton.isEnabled = false
//        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
//        dispatch_after(time, dispatch_get_main_queue()) {
        DispatchQueue.main.async {
            self.delegate?.startScene()
            self.loadingView?.hide()
        }
    }

}

/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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


class BluetoothDevicesTableViewController:UITableViewController{
    override func viewDidLoad() {
        self.tableView.backgroundColor = UIColor.backgroundColor()
    }
    
    
    func updateWhenActive() {
        dispatch_async(dispatch_get_main_queue()){
            self.tableView.reloadData()
        }
    }
    
    weak var delegate : BluetoothPopupVC?
    private let loadingView = LoadingView()
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let peri :Peripheral = CentralManager.sharedInstance.peripherals[indexPath.row];
        BluetoothService.swiftSharedInstance.selectionManager = self
        if peri.state == CBPeripheralState.Connected {
            self.deviceConnected(peri)
            return
        }
        BluetoothService.swiftSharedInstance.connectDevice(peri)
    }
    
    func deviceConnected(peripheral:Peripheral){
        if(delegate!.deviceArray!.count > 0){
            if(delegate!.deviceArray![0] == BluetoothDeviceID.phiro.rawValue){
                guard let _ = BluetoothService.sharedInstance().selectionManager else {
                    dispatch_async(dispatch_get_main_queue(), {
                        Util.alertWithTitle("Connection not possible", andText:  "Please try resetting the device and try again.")
                        self.delegate?.dismissView()
                    })
                    return
                }
                BluetoothService.swiftSharedInstance.setPhiroDevice(peripheral)
            } else if (delegate!.deviceArray![0] == BluetoothDeviceID.arduino.rawValue){
                guard let _ = BluetoothService.sharedInstance().selectionManager else {
                    dispatch_async(dispatch_get_main_queue(), {
                        Util.alertWithTitle("Connection not possible", andText:  "Please try resetting the device and try again.")
                        self.delegate?.dismissView()
                    })
                    return
                }
                BluetoothService.swiftSharedInstance.setArduinoDevice(peripheral)
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.view.addSubview(self.loadingView)
            self.loadingView.show()
        })
        
    }
    
    func deviceFailedConnection(){
        dispatch_async(dispatch_get_main_queue(), {
            self.loadingView.hide()
            Util.alertWithTitle("Connection failed", andText:  "Cannot connect to device, please try resetting the device and try again.")
            self.updateWhenActive()
        })
    }
    
    func giveUpConnectionToDevice(){
        dispatch_async(dispatch_get_main_queue(), {
            self.loadingView.hide()
            Util.alertWithTitle("Connection failed", andText:  "Cannot connect to device. The device is not responding.")
            self.updateWhenActive()
        })
    }
    
    
    func checkStart(){
        delegate!.deviceArray!.removeAtIndex(0)
        if(delegate!.deviceArray!.count > 0){
            delegate!.setHeader()
            return
        }
        tableView.userInteractionEnabled = false
        delegate!.rightButton.enabled = false
        startScene()
    }
    
    
    func startScene(){
        let central = CentralManager.sharedInstance
        if central.isScanning {
            central.stopScanning()
        }
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 2 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.loadingView.hide()
            self.delegate!.startScene()
        }
    }

}
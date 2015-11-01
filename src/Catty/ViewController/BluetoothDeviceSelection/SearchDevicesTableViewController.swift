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

import UIKit
import CoreBluetooth
import BluetoothHelper

class SearchDevicesTableViewController: BluetoothDevicesTableViewController {
    
    var debugData:UInt8 = 0x01
     override func viewDidLoad() {
        super.viewDidLoad()
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func startScan(){
        //    let afterPeripheralDiscovered = {(peripheral:Peripheral) -> Void in
        //       dispatch_async(dispatch_get_main_queue()){
        //      self.updateWhenActive()
        //      }
        //
        //      peripheral.connect(10, timeoutRetries: 10, disconnectRetries: 5, connectionTimeout: Double(10))
        //
        //      let connectionPromise = {(peripheral:Peripheral, connectionEvent:ConnectionEvent) -> Void in
        //        switch connectionEvent {
        //        case .Connect:
        //          self.updateWhenActive()
        //        case .Timeout:
        //          peripheral.reconnect()
        //          self.updateWhenActive()
        //        case .Disconnect:
        //          peripheral.reconnect()
        //          self.updateWhenActive()
        //        case .ForceDisconnect:
        //          self.updateWhenActive()
        //        case .Failed:
        //            NSLog("Fail")
        //        case .GiveUp:
        //          peripheral.disconnect()
        //          self.updateWhenActive()
        //        }
        //      }
        //      BluetoothCommunication.sharedInstance.afterConnection = connectionPromise;
        //      NSLog("NAME:\(peripheral.name)")
        //    }
        //    BluetoothCommunication.sharedInstance.afterPeripheralDiscovered = afterPeripheralDiscovered
        //  CentralManager.sharedInstance.startScanning()
        
        let afterPeripheralDiscovered = {(peripheral:Peripheral) -> Void in
            
            
            //        self.connect(peripheral)
            self.updateWhenActive()
        }
        let afterTimeout = {(error:NSError) -> Void in
            
        }
        let future : FutureStream<Peripheral> = CentralManager.sharedInstance.startScan()
        future.onSuccess(afterPeripheralDiscovered)
        future.onFailure(afterTimeout)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return CentralManager.sharedInstance.peripherals.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let peripheral = CentralManager.sharedInstance.peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        cell.accessoryType = .None
        if peripheral.state == .Connected {
            cell.textLabel?.textColor = UIColor.globalTintColor()
            cell.textLabel?.text = peripheral.name
            cell.userInteractionEnabled = false
        } else {
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }

        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
import MXSegmentedPager
import BluetoothHelper


class BluetoothPopupVC: MXSegmentedPagerController {
    
    weak var delegate : BaseTableViewController?
    var vc : ScenePresenterViewController?

    var deviceArray:[Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedPager.backgroundColor = UIColor.backgroundColor()
        
        // Segmented Control customization
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.backgroundColor()
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.lightTextTintColor(), NSFontAttributeName: UIFont.systemFontOfSize(12)];
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.globalTintColor()]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.globalTintColor()
        self.segmentedPager.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed
    
        
        setHeader()
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "dismissView")
        self.navigationItem.rightBarButtonItem = rightButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        return ["Known Devices", "Connected Devices", "Search"][index];
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, viewControllerForPageAtIndex index: Int) -> UIViewController {
        let vc:BluetoothDevicesTableViewController = super.segmentedPager(segmentedPager, viewControllerForPageAtIndex: index) as! BluetoothDevicesTableViewController
        vc.delegate = self
        return vc
    }
    
    func dismissView(){
        self .dismissViewControllerAnimated(true, completion: {
            let central = CentralManager.sharedInstance
            if central.isScanning {
                central.stopScanning()
                central.disconnectAllPeripherals()
                central.removeAllPeripherals()
            }
        })
        
    }
    
    func setHeader() {
        if(deviceArray!.count > 0){
            if(deviceArray![0] == BluetoothDeviceID.phiro.rawValue){
                self.navigationController!.title = "Select Phiro"
                self.title = "Select Phiro"
            } else if (deviceArray![0] == BluetoothDeviceID.arduino.rawValue){
                self.navigationController!.title = "Select Arduino"
                self.title = "Select Arduino"
            }
        }
        view.setNeedsDisplay()
    }
    
    func startScene(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
             self.delegate!.startSceneWithVC(self.vc!)
            }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


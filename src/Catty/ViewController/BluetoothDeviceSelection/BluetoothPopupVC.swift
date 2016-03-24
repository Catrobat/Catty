/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

@objc protocol BluetoothSelection {
    func startSceneWithVC(scenePresenter:ScenePresenterViewController)
    func showLoadingView()
}

class BluetoothPopupVC: MXSegmentedPagerController {
    
    weak var delegate : BluetoothSelection?
    var vc : ScenePresenterViewController?

    var deviceArray:[Int]?
    var rightButton:UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedPager.backgroundColor = UIColor.navBarColor()
        self.navigationController?.navigationBar.tintColor = UIColor.navTintColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.navTextColor()]
        // Segmented Control customization
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.globalTintColor()
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.backgroundColor(), NSFontAttributeName: UIFont.systemFontOfSize(12)];
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.navTintColor()]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.globalTintColor()
        self.segmentedPager.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed

        setHeader()
        
        rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(BluetoothPopupVC.dismissView))
        self.navigationItem.rightBarButtonItem = rightButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        return [klocalizedBluetoothKnown,klocalizedBluetoothSearch][index];//
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
                self.navigationController!.title = klocalizedBluetoothSelectPhiro
                self.title = klocalizedBluetoothSelectPhiro
            } else if (deviceArray![0] == BluetoothDeviceID.arduino.rawValue){
                self.navigationController!.title = klocalizedBluetoothSelectArduino
                self.title = klocalizedBluetoothSelectArduino
            }
        }
        view.setNeedsDisplay()
    }
    
    func startScene(){
        dispatch_async(dispatch_get_main_queue()){
            self.delegate!.showLoadingView()
            self.delegate!.startSceneWithVC(self.vc!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


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

import BluetoothHelper
import MXSegmentedPager
import UIKit

@objc class BluetoothPopupVC: MXSegmentedPagerController {

    @objc var deviceArray: [Int]?
    @objc var rightButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedPager.backgroundColor = UIColor.navBar()
        self.navigationController?.navigationBar.tintColor = UIColor.navTint()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.navText()!]
        // Segmented Control customization
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.down
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.globalTint()
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.background()!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.navTint()!]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyle.box
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.globalTint()
        self.segmentedPager.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyle.fixed

        setHeader()

        rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(BluetoothPopupVC.dismissAndDisconnect))
        self.navigationItem.rightBarButtonItem = rightButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return [klocalizedBluetoothKnown, klocalizedBluetoothSearch][index];//
    }

    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        let vc: BluetoothDevicesTableViewController = super.segmentedPager(segmentedPager, viewControllerForPageAt: index) as! BluetoothDevicesTableViewController
        vc.delegate = self
        return vc
    }

    @objc func dismissAndDisconnect() {
        self .dismiss(animated: true, completion: {
            let central = CentralManager.sharedInstance
            if central.isScanning {
                central.stopScanning()
                central.disconnectAllPeripherals()
                central.removeAllPeripherals()
            }
        })
    }

    @objc func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    func setHeader() {
        if !deviceArray!.isEmpty {
            if deviceArray![0] == BluetoothDeviceID.phiro.rawValue {
                self.navigationController!.title = klocalizedBluetoothSelectPhiro
                self.title = klocalizedBluetoothSelectPhiro
            } else if deviceArray![0] == BluetoothDeviceID.arduino.rawValue {
                self.navigationController!.title = klocalizedBluetoothSelectArduino
                self.title = klocalizedBluetoothSelectArduino
            }
        }
        view.setNeedsDisplay()
    }
}

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

import BluetoothHelper
import UIKit

@objc class BluetoothPopupVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    @objc var deviceArray: [Int]?
    @objc var rightButton = UIBarButtonItem()

    var segementedControl = UISegmentedControl()
    var pageViewController: UIPageViewController?
    var bluetoothDevicesTableViewControllers = [BluetoothDevicesTableViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationTitleColor = UIColor.navText
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationTitleColor]
        setHeader()

        rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(BluetoothPopupVC.dismissAndDisconnect))
        self.navigationItem.rightBarButtonItem = rightButton

        // Segmented Control
        self.segementedControl = UISegmentedControl(items: [klocalizedBluetoothKnown, klocalizedBluetoothSearch])
        self.segementedControl.frame = CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 40))
        self.segementedControl.selectedSegmentIndex = 0

        self.view.addSubview(self.segementedControl)
        self.segementedControl.translatesAutoresizingMaskIntoConstraints = false

        self.segementedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5).isActive = true
        self.segementedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5).isActive = true
        self.segementedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5).isActive = true
        self.segementedControl.addTarget(self, action: #selector(self.segmentedControllerValueChanged(_:)), for: .valueChanged)

        //Page view controller
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController?.dataSource = self
        self.pageViewController?.delegate = self

        if let pageVC = self.pageViewController {
            self.addChild(pageVC)
            self.view.addSubview(pageVC.view)
            pageVC.view.frame = CGRect(x: 0, y: self.segementedControl.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - 40)
            pageVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        let knownDevicesVC = KnownDevicesTableViewController()
        knownDevicesVC.delegate = self
        knownDevicesVC.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.bluetoothDevicesTableViewControllers.append(knownDevicesVC)

        let searchDevicesVC = SearchDevicesTableViewController()
        searchDevicesVC.delegate = self
        searchDevicesVC.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.bluetoothDevicesTableViewControllers.append(searchDevicesVC)

        self.pageViewController?.setViewControllers([self.bluetoothDevicesTableViewControllers[0]], direction: .forward, animated: false)

    }

    @objc func segmentedControllerValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.pageViewController?.setViewControllers([self.bluetoothDevicesTableViewControllers[0]], direction: .reverse, animated: true)
        } else if sender.selectedSegmentIndex == 1 {
            self.pageViewController?.setViewControllers([self.bluetoothDevicesTableViewControllers[1]], direction: .forward, animated: true)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.bluetoothDevicesTableViewControllers.firstIndex(of: viewController as! BluetoothDevicesTableViewController) {
            if index == 1 {
                let vc = bluetoothDevicesTableViewControllers[0] as! KnownDevicesTableViewController
                return vc
            } else {
                return nil
            }
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.bluetoothDevicesTableViewControllers.firstIndex(of: viewController as! BluetoothDevicesTableViewController) {
            if index == 0 {
                let vc = bluetoothDevicesTableViewControllers[1] as! SearchDevicesTableViewController
                return vc
            } else {
                return nil
            }
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = self.bluetoothDevicesTableViewControllers.firstIndex(of: previousViewControllers[0] as! BluetoothDevicesTableViewController) {
            if index == 0 {
                self.segementedControl.selectedSegmentIndex = 1
            } else if index == 1 {
                self.segementedControl.selectedSegmentIndex = 0
            }
        }
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

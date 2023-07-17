/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class ObjectSwiftTableViewController: UIViewController {

    @IBOutlet private weak var objectSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var soundContainerView: UIView!
    @IBOutlet private weak var scriptsContainerView: UIView!
    @IBOutlet private weak var looksContainerView: UIView!
    public var object: SpriteObject?

    var soundViewController: SoundsTableViewController?
    var looksViewController: LooksTableViewController?
    var scriptsViewController: ScriptCollectionViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControll()
        scriptsContainerView.isHidden = true

        if let object = object {
            self.title = object.name
            self.navigationItem.title = object.name
        }
        navigationController?.setToolbarHidden(false, animated: true)
        showScripts()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLooks" {
            let destVC = segue.destination as! LooksTableViewController
            destVC.object = object
            destVC.parentNavigationController = self
            looksViewController = destVC
        } else if segue.identifier == "toSounds" {
            let destVC = segue.destination as! SoundsTableViewController
            destVC.object = object
            soundViewController = destVC
        } else if segue.identifier == "toScripts" {
            let destVC = segue.destination as! ScriptCollectionViewController
            destVC.object = object
            destVC.parentNavigationController = self
            scriptsViewController = destVC
        }
    }

    func configureSegmentedControll() {

        self.objectSegmentedControl.setTitle(kLocalizedScripts, forSegmentAt: 0)
        self.objectSegmentedControl.setTitle(kLocalizedBackgrounds, forSegmentAt: 1)
        self.objectSegmentedControl.setTitle(kLocalizedSounds, forSegmentAt: 2)
    }

    @IBAction private func segmentTapped(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            showScripts()
        case 1:
          showBackgrounds()
        case 2:
           showSounds()
        default:
            break
        }
    }

    @objc func setObject(_ object: SpriteObject) {
        self.object = object
    }

    func showBackgrounds() {
        scriptsContainerView.isHidden = true
        looksContainerView.isHidden = false
        soundContainerView.isHidden = true
        //setUpToolBarForLooks()
        looksViewController?.initNavigationBar()
        looksViewController?.setupToolBar()
    }

    func showScripts() {
        scriptsContainerView.isHidden = false
        looksContainerView.isHidden = true
        soundContainerView.isHidden = true
        //setupToolBarForScripts()
        scriptsViewController?.setupToolBar()
        scriptsViewController?.changeDeleteBarButtonState()
    }

    func showSounds() {
        scriptsContainerView.isHidden = true
        looksContainerView.isHidden = true
        soundContainerView.isHidden = false
        //setupToolBarForSound()
    }

    func setupToolBarForScripts() {

        guard let scriptsViewController = scriptsViewController else {
            return
        }
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: scriptsViewController, action: #selector(scriptsViewController.showBrickPickerAction))
        let play = PlayButton(target: self, action: #selector(scriptPlayButtonPressed))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flex, add, flex, flex, play, flex]
    }

    func setupToolBarForSound() {
        guard let soundViewController = soundViewController else {
            return
        }
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: soundViewController, action: #selector(soundViewController.addSoundAction(_:)))
        let play = PlayButton(target: self, action: #selector(soundPlayButtonPressed))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flex, add, flex, flex, play, flex]
    }

    func setUpToolBarForLooks() {
        guard let looksViewController = looksViewController else {
            return
        }
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: looksViewController, action: #selector(looksViewController.addLookAction(_:)))
        let play = PlayButton(target: self, action: #selector(looksPlayButtonPressed))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flex, add, flex, flex, play, flex]
    }

    @objc func scriptPlayButtonPressed() {
        if let scriptsViewController = scriptsViewController {
            playScriptsSceneAction(scriptsViewController)
        }

    }

    @objc func soundPlayButtonPressed() {
        guard let soundViewController = soundViewController else {
            return
        }
        soundViewController.playSceneAction(nil)
        playBaseTableViewSceneAction(soundViewController)
    }

    @objc func looksPlayButtonPressed() {
        if let looksViewController {
            playBaseTableViewSceneAction(looksViewController)
        }
    }

    func playBaseTableViewSceneAction(_ sender: BaseTableViewController) {
        sender.showLoadingView()

        (UIApplication.shared.delegate as? AppDelegate)?.enabledOrientation = true
        let lastProjectQueue = DispatchQueue(label: "lastProjectQueue")
        lastProjectQueue.async {
            let landscapeMode = Project.lastUsed().header.landscapeMode
            DispatchQueue.main.async { [self] in
                if !landscapeMode {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }

                sender.stagePresenterViewController.checkResourcesAndPushViewController(to: self.navigationController!) {
                    sender.hideLoadingView()
                }
            }
        }
    }

    func playScriptsSceneAction(_ sender: ScriptCollectionViewController) {
        sender.showLoadingView()
        (UIApplication.shared.delegate as? AppDelegate)?.enabledOrientation = true
        let lastProjectQueue = DispatchQueue(label: "lastProjectQueue")
        lastProjectQueue.async {
            let landscapeMode = Project.lastUsed().header.landscapeMode
            DispatchQueue.main.async { [self] in
                if !landscapeMode {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                sender.stagePresenterViewController.checkResourcesAndPushViewController(to: self.navigationController!) {
                    sender.hideLoadingView()
                }
            }
        }
    }

}

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

    @IBOutlet private weak var scriptsContainerView: UIView!
    public var object: SpriteObject?

    var soundViewController = SoundsTableViewController()
    //var looksViewController = LooksTableViewController()
    var scriptsViewController = ScriptCollectionViewController(collectionViewLayout: type(of: UICollectionViewFlowLayout()).init())

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControll()

        if let object = object {
            self.title = object.name
            self.navigationItem.title = object.name
        }
        navigationController?.setToolbarHidden(false, animated: true)
        configureViewControllers()
        setupToolBarForScripts()
    }

    func configureViewControllers() {
        scriptsViewController.object = object
        soundViewController.object = object

        scriptsContainerView.addSubview(scriptsViewController.view)
        //scriptsContainerView.addSubview(looksViewController.view)
        scriptsContainerView.addSubview(soundViewController.view)
        //scriptsViewController.didMove(toParent: self)
        scriptsViewController.view.frame = scriptsContainerView.bounds

        //soundViewController.didMove(toParent: self)
        soundViewController.view.frame = scriptsContainerView.bounds

//        looksViewController.didMove(toParent: self)
//        looksViewController.view.frame = scriptsContainerView.bounds

       
        //looksViewController.object = object

        scriptsViewController.view.isHidden = false
        //looksViewController.view.isHidden = true
        soundViewController.view.isHidden = true

        //looksViewController.setupToolBar()
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
            scriptsViewController.view.isHidden = true
            //looksViewController.view.isHidden = false
            soundViewController.view.isHidden = true
        case 2:
           showSounds()
        default:
            break
        }

    }
    @objc func setObject(_ object: SpriteObject) {
        self.object = object
    }

    func showScripts() {
        scriptsViewController.view.isHidden = false
        //looksViewController.view.isHidden = true
        soundViewController.view.isHidden = true
        setupToolBarForScripts()
    }

    func showSounds() {
        scriptsViewController.view.isHidden = true
        //looksViewController.view.isHidden = true
        soundViewController.view.isHidden = false
        setupToolBarForSound()
    }

    func setupToolBarForScripts() {
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: scriptsViewController, action: #selector(scriptsViewController.showBrickPickerAction))
        let play = PlayButton(target: self, action: #selector(scriptPlayButtonPressed))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flex, add, flex, flex, play, flex]
    }

    func setupToolBarForSound() {
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: soundViewController, action: #selector(soundViewController.addSoundAction(_:)))
        let play = PlayButton(target: soundViewController, action: #selector(soundViewController.playSceneAction(_:)))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flex, add, flex, flex, play, flex]
    }

    @objc func scriptPlayButtonPressed() {
        playSceneAction(UIBarButtonItem())
    }

    func playSceneAction(_ sender: Any) {
        scriptsViewController.showLoadingView()

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

                scriptsViewController.stagePresenterViewController.checkResourcesAndPushViewController(to: self.navigationController!) {
                    self.scriptsViewController.hideLoadingView()
                }
            }
        }
    }

}

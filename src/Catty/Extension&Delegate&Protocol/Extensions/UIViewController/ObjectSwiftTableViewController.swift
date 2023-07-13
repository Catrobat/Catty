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
        setupToolBar()
    }

    func configureViewControllers() {

        scriptsContainerView.addSubview(scriptsViewController.view)
        //scriptsContainerView.addSubview(looksViewController.view)
        scriptsContainerView.addSubview(soundViewController.view)
        //scriptsViewController.didMove(toParent: self)
        scriptsViewController.view.frame = scriptsContainerView.bounds

        //soundViewController.didMove(toParent: self)
        soundViewController.view.frame = scriptsContainerView.bounds

//        looksViewController.didMove(toParent: self)
//        looksViewController.view.frame = scriptsContainerView.bounds

        soundViewController.object = object
        //looksViewController.object = object
        scriptsViewController.object = object

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
            //scriptsViewController.setEditing(true, animated: true)
            scriptsViewController.view.isHidden = false
            //looksViewController.view.isHidden = true
            soundViewController.view.isHidden = true
            setupToolBar()
        case 1:
            scriptsViewController.view.isHidden = true
            //looksViewController.view.isHidden = false
            soundViewController.view.isHidden = true
        case 2:
            scriptsViewController.view.isHidden = true
            //looksViewController.view.isHidden = true
            soundViewController.view.isHidden = false
            setupToolBarForSound()
        default:
            break
        }

    }
    @objc func setObject(_ object: SpriteObject) {
        self.object = object
    }

    func setupToolBar() {

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: scriptsViewController, action: #selector(ScriptCollectionViewController.showBrickPickerAction))
        let play = PlayButton(target: scriptsViewController, action: #selector(ScriptCollectionViewController.playSceneAction(_:)))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flex, add, flex, flex, play, flex]
    }
    
    func setupToolBarForSound() {

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: soundViewController, action: #selector(soundViewController.addSoundAction(_:)))
        let play = PlayButton(target: soundViewController, action: #selector(soundViewController.playSceneAction(_:)))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flex, add, flex, flex, play, flex]
    }
}

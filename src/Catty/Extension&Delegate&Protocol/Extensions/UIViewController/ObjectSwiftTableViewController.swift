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

    public var object: SpriteObject?

    var SoundViewController = SoundsTableViewController()
    var LooksViewController = LooksTableViewController()
    var ScriptsViewController = ScriptCollectionViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControll()

        if let object = object {
            self.title = object.name
            self.navigationItem.title = object.name
        }

    }

    func configureSegmentedControll() {

        self.objectSegmentedControl.setTitle(kLocalizedScripts, forSegmentAt: 0)
        self.objectSegmentedControl.setTitle(kLocalizedBackgrounds, forSegmentAt: 1)
        self.objectSegmentedControl.setTitle(kLocalizedSounds, forSegmentAt: 2)
    }

    @objc func setObject(_ object: SpriteObject) {
        self.object = object
    }

}

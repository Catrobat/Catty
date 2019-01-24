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

import Bohr

class AboutPocketCodeOptionTableViewController: BOTableViewController {

    override func setup() {
        title = kLocalizedAboutPocketCode
        view.backgroundColor = UIColor.background()
        view.tintColor = UIColor.globalTint()
        addSection(BOTableViewSection(headerTitle: "", handler: { section in
            section?.addCell(BOTableViewCell(title: kLocalizedAboutPocketCodeDescription, key: nil, handler: { cell in
                let sectionCell = cell as! BOTableViewCell?
                sectionCell?.backgroundColor = UIColor.background()
            }))
            section?.addCell(BOButtonTableViewCell(title: kLocalizedSourceCodeLicenseButtonLabel, key: nil, handler: { cell in
                let sectionCell = cell as! BOButtonTableViewCell?
                sectionCell?.backgroundColor = UIColor.background()
                sectionCell?.mainColor = UIColor.globalTint()
                sectionCell?.actionBlock = {
                    self.openSourceCodeLicenseURL()
                }
            }))
            section?.addCell(BOButtonTableViewCell(title: kLocalizedAboutPocketCode, key: nil, handler: { cell in
                let sectionCell = cell as! BOButtonTableViewCell?
                sectionCell?.backgroundColor = UIColor.background()
                sectionCell?.mainColor = UIColor.globalTint()
                sectionCell?.actionBlock = {
                    self.openAboutURL()
                }
            }))
        }))
    }

    func openAboutURL() {
        Util.openUrlExternal(URL(string: kAboutCatrobatURL))
    }

    func openSourceCodeLicenseURL() {
        Util.openUrlExternal(URL(string: kSourceCodeLicenseURL))
    }
}

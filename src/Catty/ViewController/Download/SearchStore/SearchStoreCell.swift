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

import UIKit

protocol SearchStoreCellProtocol: AnyObject {
    func selectedCell(dataSource datasource: SearchStoreDataSource, didSelectCellWith cell: SearchStoreCell)
}

class SearchStoreCell: UITableViewCell {

    weak var delegete: SearchStoreCellProtocol?
    var project: StoreProject?

    @IBOutlet private weak var searchProjectImage: UIImageView!
    @IBOutlet private weak var searchProjectTitle: UILabel!

    var searchImage: UIImage? {
        didSet {
            self.updateTable()
        }
    }

    var searchTitle: String? {
        didSet {
            self.updateTable()
        }
    }

    func updateTable() {
        searchProjectImage?.image = searchImage
        searchProjectTitle?.text = searchTitle
        searchProjectTitle.textColor = UIColor.globalTint
    }
}

/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

enum MediaType: String {
    case backgrounds
    case looks
    case sounds
}

extension MediaType {
    var indexURL: URL {
        switch self {
        case .backgrounds:
            guard let indexURL = URL(string: kMediaLibraryBackgroundsIndex) else { fatalError("Media Library backgrounds URL constant misconfiguration") }
            return indexURL
        case .looks:
            guard let indexURL = URL(string: kMediaLibraryLooksIndex) else { fatalError("Media Library looks URL constant misconfiguration") }
            return indexURL
        case .sounds:
            guard let indexURL = URL(string: kMediaLibrarySoundsIndex) else { fatalError("Media Library sounds URL constant misconfiguration") }
            return indexURL
        }
    }
}

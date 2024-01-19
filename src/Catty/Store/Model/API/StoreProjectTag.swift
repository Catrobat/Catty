/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

struct StoreProjectTag: Codable {
    let id: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case id
        case text
    }

    init(id: String, text: String) {
        self.id = id
        self.text = text
    }

    static func indices(with idString: String, from tags: [StoreProjectTag]) -> [Int] {
        var indices = [Int]()
        for id in idString.components(separatedBy: ",") {
            if let index = tags.firstIndex(where: { $0.id == id }) {
                indices.append(index)
            }
        }
        return indices
    }
}

extension [StoreProjectTag] {
    var idString: String {
        self.map { $0.id }.joined(separator: ",")
    }

    var textString: String {
        self.map { $0.text }.joined(separator: ", ")
    }

    init(with idString: String, from tags: [StoreProjectTag]) {
        self.init()
        for id in idString.components(separatedBy: ",") {
            if let tag = tags.first(where: { $0.id == id }) {
                self.append(tag)
            }
        }
    }
}

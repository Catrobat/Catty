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

struct MediaItem: Codable {
    let name: String
    let fileExtension: String
    let category: String
    let relativePath: String

    /// Since the API doesn't offer previews of items it would
    /// be a waste to not keep the already downloaded data
    /// in case the user decides to import the item.
    var cachedData: Data? = nil

    private enum CodingKeys: String, CodingKey {
        case name
        case fileExtension = "extension"
        case category
        case relativePath = "download_url"
    }
}

extension MediaItem {
    var downloadURL: URL {
        guard let baseURL = URL(string: kMediaLibraryDownloadBaseURL) else { fatalError("Media Library base URL constant misconfiguration") }
        return baseURL.appendingPathComponent(self.relativePath)
    }
}

extension Sequence where Iterator.Element == MediaItem {

    var groupedByCategories: [[MediaItem]] {

        // a two dimensional list of categories and their items
        var groupedItems = [[MediaItem]]()

        // a dictionary of categories mapped to their order of appearance
        var categories = [String: Int]()

        for item in self {
            if let categoryIndex = categories[item.category] {
                // category exists, add the item to the list
                groupedItems[categoryIndex].append(item)
            } else {
                // add the category with a list containing the current item
                let categoryIndex = categories.count
                categories[item.category] = categoryIndex
                groupedItems.append([item])
            }
        }
        return groupedItems
    }
}

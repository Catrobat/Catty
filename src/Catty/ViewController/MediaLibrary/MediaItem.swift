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

struct MediaItem: Codable {
    let id: Int
    let name: String?
    let flavours: [String]?
    let packages: [String]?
    let category: String?
    let author: String?
    let fileExtension: String?
    let downloadURLString: String?
    let size: Int?
    let fileType: String?

    /// Since the API doesn't offer previews of items it would
    /// be a waste to not keep the already downloaded data
    /// in case the user decides to import the item.
    var cachedData: Data?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case flavours = "flavours"
        case packages = "packages"
        case category = "category"
        case author = "author"
        case fileExtension = "extension"
        case downloadURLString = "download_url"
        case size = "size"
        case fileType = "file_type"
    }

    static var defaultQueryParameters: [String] {
        [CodingKeys.id.rawValue,
         CodingKeys.name.rawValue,
         CodingKeys.category.rawValue,
         CodingKeys.fileExtension.rawValue,
         CodingKeys.downloadURLString.rawValue]
    }

    init(id: Int, name: String? = nil, flavours: [String]? = nil, packages: [String]? = nil,
         category: String? = nil, author: String? = nil, fileExtension: String? = nil,
         downloadURLString: String? = nil, size: Int? = nil, fileType: String? = nil, cachedData: Data? = nil) {
        self.id = id
        self.name = name
        self.flavours = flavours
        self.packages = packages
        self.category = category
        self.author = author
        self.fileExtension = fileExtension
        self.downloadURLString = downloadURLString
        self.size = size
        self.fileType = fileType
        self.cachedData = cachedData
    }
}

extension MediaItem {
    var downloadURL: URL? {
        guard let downloadPath = self.downloadURLString else { return nil }
        return URL(string: downloadPath)
    }
}

extension Sequence where Iterator.Element == MediaItem {

    // The following categories should be shown on top of the list (IOS-677).
    // TODO fetch ordering information from API
    var prioritizedCategories: [String] {
        ["Pocket Family"]
    }

    var groupedByCategories: [[MediaItem]] {

        // a two dimensional list of categories and their items
        var groupedItems = [[MediaItem]]()

        // a dictionary of categories mapped to their order of appearance
        var categories = [String: Int]()
        prioritizedCategories.forEach { category in
            categories[category] = categories.count
            groupedItems.append([])
        }

        for item in self {
            guard let itemCategory = item.category else {
                continue
            }
            if let categoryIndex = categories[itemCategory] {
                // category exists, add the item to the list
                groupedItems[categoryIndex].append(item)
            } else {
                // add the category with a list containing the current item
                let categoryIndex = categories.count
                categories[itemCategory] = categoryIndex
                groupedItems.append([item])
            }
        }
        return groupedItems.filter { !$0.isEmpty } // do not show empty categories
    }
}

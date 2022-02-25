/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

struct StoreFeaturedProject: Codable {
    let id: String
    let url: String
    let name: String
    let author: String
    let featuredImage: String

    private enum CodingKeys: String, CodingKey {
        case id = "project_id"
        case url = "project_url"
        case name = "name"
        case author = "author"
        case featuredImage = "featured_image"
    }

    init(id: String, url: String, name: String, author: String, featuredImage: String) {
        self.id = id
        self.url = url
        self.name = name
        self.author = author
        self.featuredImage = featuredImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(Int.self, forKey: .id) {
            id = String(value)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        url = try container.decode(String.self, forKey: .url)
        name = try container.decode(String.self, forKey: .name)
        author = try container.decode(String.self, forKey: .author)
        featuredImage = try container.decode(String.self, forKey: .featuredImage)
    }
}

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

struct StoreProject: Codable {
    let projectId: Int
    let projectName: String
    let projectNameShort: String?
    let author: String
    let description: String?
    let version: String?
    let views: Int?
    let downloads: Int?
    let uploaded: Int?
    let uploadedString: String?
    let screenshotBig: String?
    let screenshotSmall: String?
    let projectUrl: String?
    let downloadUrl: String?
    let fileSize: Float?
    let featuredImage: String?
    let isPrivate: Bool! = false

    private enum CodingKeys: String, CodingKey {
        case projectId = "ProjectId"
        case projectName = "ProjectName"
        case projectNameShort = "ProjectNameShort"
        case author = "Author"
        case description = "Description"
        case version = "Version"
        case views = "Views"
        case downloads = "Downloads"
        case uploaded = "Uploaded"
        case uploadedString = "UploadedString"
        case screenshotBig = "ScreenshotBig"
        case screenshotSmall = "ScreenshotSmall"
        case projectUrl = "ProjectUrl"
        case downloadUrl = "DownloadUrl"
        case fileSize = "FileSize"
        case featuredImage = "FeaturedImage"
        case isPrivate = "Private"
    }
}

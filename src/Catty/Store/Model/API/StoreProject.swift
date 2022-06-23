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

struct StoreProject: Codable {
    let id: String
    let name: String?
    let author: String?
    let description: String?
    let credits: String?
    let version: String?
    let views: Int?
    let downloads: Int?
    let reactions: Int?
    let comments: Int?
    let isPrivate: Bool
    let flavor: String?
    let tags: [String]?
    let uploaded: Int?
    let uploadedString: String?
    let screenshotBig: String?
    let screenshotSmall: String?
    let projectUrl: String?
    let downloadUrl: String?
    let fileSize: Float?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case author = "author"
        case description = "description"
        case credits = "credits"
        case version = "version"
        case views = "views"
        case downloads = "downloads"
        case reactions = "reactions"
        case comments = "comments"
        case isPrivate = "private"
        case flavor = "flavor"
        case tags = "tags"
        case uploaded = "uploaded"
        case uploadedString = "uploaded_string"
        case screenshotBig = "screenshot_large"
        case screenshotSmall = "screenshot_small"
        case projectUrl = "project_url"
        case downloadUrl = "download_url"
        case fileSize = "filesize"
    }

    static var defaultQueryParameters: [String] {
        [CodingKeys.id.rawValue, CodingKeys.name.rawValue, CodingKeys.screenshotSmall.rawValue]
    }

    init(id: String, name: String? = nil, author: String? = nil, description: String? = nil,
         credits: String? = nil, version: String? = nil, views: Int? = nil, downloads: Int? = nil,
         reactions: Int? = nil, comments: Int? = nil, isPrivate: Bool = false, flavor: String? = nil,
         tags: [String]? = nil, uploaded: Int? = nil, uploadedString: String? = nil,
         screenshotBig: String? = nil, screenshotSmall: String? = nil, projectUrl: String? = nil,
         downloadUrl: String? = nil, fileSize: Float? = nil) {

        self.id = id
        self.name = name
        self.author = author
        self.description = description
        self.credits = credits
        self.version = version
        self.views = views
        self.downloads = downloads
        self.reactions = reactions
        self.comments = comments
        self.isPrivate = isPrivate
        self.flavor = flavor
        self.tags = tags
        self.uploaded = uploaded
        self.uploadedString = uploadedString
        self.screenshotBig = screenshotBig
        self.screenshotSmall = screenshotSmall
        self.projectUrl = projectUrl
        self.downloadUrl = downloadUrl
        self.fileSize = fileSize
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        credits = try container.decodeIfPresent(String.self, forKey: .credits)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        views = try container.decodeIfPresent(Int.self, forKey: .views)
        downloads = try container.decodeIfPresent(Int.self, forKey: .downloads)
        reactions = try container.decodeIfPresent(Int.self, forKey: .reactions)
        comments = try container.decodeIfPresent(Int.self, forKey: .comments)
        isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
        flavor = try container.decodeIfPresent(String.self, forKey: .flavor)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        uploaded = try container.decodeIfPresent(Int.self, forKey: .uploaded)
        uploadedString = try container.decodeIfPresent(String.self, forKey: .uploadedString)
        screenshotBig = try container.decodeIfPresent(String.self, forKey: .screenshotBig)
        screenshotSmall = try container.decodeIfPresent(String.self, forKey: .screenshotSmall)
        projectUrl = try container.decodeIfPresent(String.self, forKey: .projectUrl)
        downloadUrl = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
        fileSize = try container.decodeIfPresent(Float.self, forKey: .fileSize)
    }

    func toCatrobatProject() -> CatrobatProject {
        var projectDictionary = [String: Any]()

        projectDictionary["ProjectId"] = self.id
        projectDictionary["ProjectName"] = self.name ?? ""
        projectDictionary["Author"] = self.author ?? ""
        projectDictionary["Description"] = self.description ?? ""
        projectDictionary["Version"] = self.version ?? ""
        projectDictionary["Views"] = self.views ?? 0
        projectDictionary["Downloads"] = self.downloads ?? 0
        projectDictionary["Tags"] = self.tags ?? [String]()
        projectDictionary["Uploaded"] = self.uploaded ?? 0
        projectDictionary["ScreenshotBig"] = self.screenshotBig ?? ""
        projectDictionary["ScreenshotSmall"] = self.screenshotSmall ?? ""
        projectDictionary["ProjectUrl"] = self.projectUrl ?? ""
        projectDictionary["DownloadUrl"] = self.downloadUrl ?? ""
        projectDictionary["FileSize"] = self.fileSize ?? 0.0

        return CatrobatProject(dict: projectDictionary)
    }
}

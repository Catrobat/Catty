/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
    let projectId: String
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

    init(projectId: String, projectName: String, projectNameShort: String?, author: String, description: String?, version: String?,
         views: Int?, downloads: Int?, uploaded: Int?, uploadedString: String?, screenshotBig: String?, screenshotSmall: String?,
         projectUrl: String?, downloadUrl: String?, fileSize: Float?, featuredImage: String?) {
        self.projectId = projectId
        self.projectName = projectName
        self.projectNameShort = projectNameShort
        self.author = author
        self.description = description
        self.version = version
        self.views = views
        self.downloads = downloads
        self.uploaded = uploaded
        self.uploadedString = uploadedString
        self.screenshotBig = screenshotBig
        self.screenshotSmall = screenshotSmall
        self.projectUrl = projectUrl
        self.downloadUrl = downloadUrl
        self.fileSize = fileSize
        self.featuredImage = featuredImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try? container.decode(Int.self, forKey: .projectId) {
            projectId = String(value)
        } else {
            projectId = try container.decode(String.self, forKey: .projectId)
        }

        projectName = try container.decode(String.self, forKey: .projectName)
        projectNameShort = try container.decodeIfPresent(String.self, forKey: .projectNameShort)
        author = try container.decode(String.self, forKey: .author)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        views = try container.decodeIfPresent(Int.self, forKey: .views)
        downloads = try container.decodeIfPresent(Int.self, forKey: .downloads)
        uploaded = try container.decodeIfPresent(Int.self, forKey: .uploaded)
        uploadedString = try container.decodeIfPresent(String.self, forKey: .uploadedString)
        screenshotBig = try container.decodeIfPresent(String.self, forKey: .screenshotBig)
        screenshotSmall = try container.decodeIfPresent(String.self, forKey: .screenshotSmall)
        projectUrl = try container.decodeIfPresent(String.self, forKey: .projectUrl)
        downloadUrl = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
        fileSize = try container.decodeIfPresent(Float.self, forKey: .fileSize)
        featuredImage = try container.decodeIfPresent(String.self, forKey: .featuredImage)
    }

    func toCatrobatProject() -> CatrobatProject {
        var projectDictionary = [String: Any]()
        projectDictionary["ProjectName"] = self.projectName
        projectDictionary["Author"] =  self.author
        projectDictionary["Description"] = self.description ?? ""
        projectDictionary["DownloadUrl"] = self.downloadUrl ?? ""
        projectDictionary["Downloads"] = self.downloads ?? 0
        projectDictionary["ProjectId"] = self.projectId
        projectDictionary["ProjectName"] = self.projectName
        projectDictionary["ProjectUrl"] = self.projectUrl ?? ""
        projectDictionary["ScreenshotBig"] = self.screenshotBig ?? ""
        projectDictionary["ScreenshotSmall"] = self.screenshotSmall ?? ""
        projectDictionary["FeaturedImage"] = self.featuredImage ?? ""
        projectDictionary["Uploaded"] = self.uploaded ?? 0
        projectDictionary["Version"] = self.version ?? ""
        projectDictionary["Views"] = self.views ?? 0
        projectDictionary["FileSize"] = self.fileSize ?? 0.0

        return CatrobatProject(dict: projectDictionary, andBaseUrl: NetworkDefines.featuredImageBaseUrl)
    }
}

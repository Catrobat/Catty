/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc
class NetworkDefines: NSObject {

    // MARK: Base
    static let shareUrlProduction = "https://share.catrob.at/"
    static let shareUrlTesting = "https://web-test.catrob.at/"

    static var shareUrl: String {
        #if DEBUG
        return shareUrlTesting
        #else
        return shareUrlProduction
        #endif
    }

    static let baseUrl = shareUrl.appending("pocketcode/")
    static let newApiEndpoint = shareUrl.appending("api/")

    // MARK: AppStore

    static let appStoreIdentifier = "1117935892"
    @objc static let appStoreUrl = "itms-apps://itunes.apple.com/app/".appending(appStoreIdentifier)

    // MARK: Static content

    @objc static let sourceCodeLicenseUrl = "http://developer.catrobat.org/licenses"
    @objc static let aboutCatrobatUrl = "http://www.catrobat.org"
    @objc static let unsupportedElementsUrl = "https://catrob.at/ibuf"

    // MARK: API

    @objc static let connectionTimeout = 15

    @objc static var loginUrl: String { baseUrl.appending("api/login/Login.json") }
    @objc static var registerUrl: String { baseUrl.appending("api/register/Register.json") }
    @objc static var reportProjectUrl: String { baseUrl.appending("api/reportProject/reportProject.json") }
    @objc static var termsOfUseUrl: String { baseUrl.appending("termsOfUse") }
    @objc static var recoverPassword: String { baseUrl.appending("resetting/request") }
    static var uploadUrl: String { baseUrl.appending("api/upload") }
    static var downloadUrl: String { baseUrl.appending("download") }
    static var tagUrl: String { baseUrl.appending("api/tags/getTags.json") }
    static var helpUrl: String { "https://catrob.at/help" }

    static let connectionUpload = "upload.json"
    static let connectionIDQuery = "getInfoById.json"

    static let projectsOffset = "offset"
    static let projectsLimit = "limit"
    static let maxVersion = "max_version"
    static let tagLanguage = "language"
    static let projectQuery = "query"
    static let projectCategory = "category"
    static let featuredPlatform = "platform"

    // MARK: MediaLibrary

    static var mediaLibraryBackgroundsIndex: String { baseUrl.appending("/api/media/package/Backgrounds/json") }
    static var mediaLibraryLooksIndex: String { baseUrl.appending("/api/media/package/Looks/json") }
    static var mediaLibrarySoundsIndex: String { baseUrl.appending("/api/media/package/Sounds/json") }
    static var mediaLibraryDownloadBaseUrl: String { baseUrl.replacingOccurrences(of: "/pocketcode/", with: "") }

    // MARK: Share

    static var projectDetailsBaseUrl: String { baseUrl.appending("project/") }

    // MARK: FeaturedProjectStoreViewController

    static var apiEndpointProjects = newApiEndpoint.appending("projects")
    static var apiEndpointProjectDetails = newApiEndpoint.appending("project")
    static var apiEndpointFeatured = apiEndpointProjects.appending("/featured")
    static var apiEndpointSearch = apiEndpointProjects.appending("/search")

    static let chartProjectsMaxResults = 10
    static let recentProjectsMaxResults = 20
    static let searchStoreMaxResults = 50

    static let searchLookupDelayInSeconds = 0.3

    static let currentPlatform = "ios"

    @objc static let reportProjectNoteMaxLength = 100
    @objc static let reportProjectNoteMinLength = 3

    @objc static let kUserIsLoggedIn = "userIsLoggedIn"
    @objc static let kUserLoginToken = "userLoginToken"

    // MARK: WebRequestDownloader

    static let kWebRequestMaxDownloadSizeInBytes = 1000000 // = 1MB
    static let kNumberOfConcurrentDownloads = 10

    // MARK: Wiki
    static let kWebRequestWikiURL = "https://wiki.catrobat.org/bin/view/Documentation/Web%20requests/"
}

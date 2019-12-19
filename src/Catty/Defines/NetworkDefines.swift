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

@objc
class NetworkDefines: NSObject {

    // MARK: Base

    static let baseUrlProduction = "https://share.catrob.at/pocketcode/"
    static let baseUrlTesting = "https://web-test.catrob.at/pocketcode/"
    static var baseUrl: String {
        #if DEBUG
        return baseUrlTesting
        #else
        return baseUrlProduction
        #endif
    }

    // MARK: AppStore

    static let appStoreIdentifier = "1117935892"
    @objc static let appStoreUrl = "itms-apps://itunes.apple.com/app/".appending(appStoreIdentifier)

    // MARK: Static content

    @objc static let sourceCodeLicenseUrl = "http://developer.catrobat.org/licenses"
    @objc static let aboutCatrobatUrl = "http://www.catrobat.org"
    @objc static let unsupportedElementsUrl = "https://catrob.at/ibuf"

    // MARK: API

    @objc static let connectionTimeout = 15

    @objc static var loginUrl: String { return baseUrl.appending("api/login/Login.json") }
    @objc static var registerUrl: String { return baseUrl.appending("api/register/Register.json") }
    @objc static var reportProjectUrl: String { return baseUrl.appending("api/reportProject/reportProject.json") }
    @objc static var termsOfUseUrl: String { return baseUrl.appending("termsOfUse") }
    @objc static var recoverPassword: String { return baseUrl.appending("resetting/request") }
    static var uploadUrl: String { return baseUrl.appending("api/upload") }
    static var downloadUrl: String { return baseUrl.appending("download") }
    static var helpUrl: String { return baseUrl.appending("help") }

    static let connectionSearch = "search.json"
    static let connectionUpload = "upload.json"
    static let connectionIDQuery = "getInfoById.json"
    static let connectionMostViewed = "mostViewed.json"
    static let connectionMostDownloaded = "mostDownloaded.json"
    static let connectionFeatured = "ios-featured.json"
    static let connectionRecent = "recent.json"

    static let projectsOffset = "offset="
    static let projectsLimit = "limit="
    static let maxVersion = "max_version="

    // MARK: MediaLibrary

    static var mediaLibraryBackgroundsIndex: String { return baseUrl.appending("/api/media/package/Backgrounds/json") }
    static var mediaLibraryLooksIndex: String { return baseUrl.appending("/api/media/package/Looks/json") }
    static var mediaLibrarySoundsIndex: String { return baseUrl.appending("/api/media/package/Sounds/json") }
    static var mediaLibraryDownloadBaseUrl: String { return baseUrl.replacingOccurrences(of: "/pocketcode/", with: "") }

    // MARK: FeaturedProjectStoreViewController

    static var connectionHost: String { return baseUrl.appending("api/projects") }
    static var featuredImageBaseUrl: String { return baseUrl.replacingOccurrences(of: "/pocketcode/", with: "/") }
    static let chartProjectsMaxResults = 10
    static let recentProjectsMaxResults = 20
    static let searchStoreMaxResults = 50
    @objc static let reportProjectNoteMaxLength = 100
    @objc static let reportProjectNoteMinLength = 3
}

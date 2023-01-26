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
    static let apiBaseUrl = shareUrl.appending("api/")

    // MARK: AppStore

    static let appStoreIdentifier = "1117935892"
    @objc static let appStoreUrl = "itms-apps://itunes.apple.com/app/".appending(appStoreIdentifier)

    // MARK: Static content

    static let aboutCatrobatUrl = "https://catrobat.org"
    static let helpUrl = "https://catrob.at/help"
    static let sourceCodeLicenseUrl = "https://developer.catrobat.org/licenses"
    @objc static let termsOfUseUrl = shareUrl.appending("app/termsOfUse")
    @objc static let unsupportedElementsUrl = "https://catrob.at/ibuf"

    // MARK: Old API

    @objc static var loginUrl: String { baseUrl.appending("api/login/Login.json") }
    @objc static var registerUrl: String { baseUrl.appending("api/register/Register.json") }
    @objc static var reportProjectUrl: String { baseUrl.appending("api/reportProject/reportProject.json") }
    @objc static var recoverPassword: String { baseUrl.appending("resetting/request") }
    static var uploadUrl: String { baseUrl.appending("api/upload") }
    static var tagUrl: String { baseUrl.appending("api/tags/getTags.json") }

    static let connectionUpload = "upload.json"

    static let tagLanguage = "language"

    // MARK: API

    static var apiEndpointMediaPackage = apiBaseUrl.appending("media/package")
    static var apiEndpointMediaPackageBackgrounds = apiEndpointMediaPackage.appending("/Backgrounds")
    static var apiEndpointMediaPackageLooks = apiEndpointMediaPackage.appending("/Looks")
    static var apiEndpointMediaPackageSounds = apiEndpointMediaPackage.appending("/Sounds")

    static var apiEndpointProject = apiBaseUrl.appending("project")
    static var apiEndpointProjects = apiBaseUrl.appending("projects")
    static var apiEndpointProjectsFeatured = apiEndpointProjects.appending("/featured")
    static var apiEndpointProjectsSearch = apiEndpointProjects.appending("/search")

    static let apiParameterOffset = "offset"
    static let apiParameterLimit = "limit"
    static let apiParameterMaxVersion = "max_version"
    static let apiParameterQuery = "query"
    static let apiParameterCategory = "category"
    static let apiParameterPlatform = "platform"
    static let apiParameterAttributes = "attributes"

    static var apiActionDownload = "catrobat"

    // MARK: API Configuration

    @objc static let connectionTimeout = 15

    static let featuredProjectsBatchSize = 20
    static let chartProjectsBatchSize = 20
    static let searchProjectsBatchSize = 20

    static let searchLookupDelayInSeconds = 0.3

    static let mediaPackageMaxItems = 10000

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

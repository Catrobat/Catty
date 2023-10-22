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

    // MARK: AppStore

    static let appStoreIdentifier = "1117935892"
    static let appStoreUrl = "itms-apps://itunes.apple.com/app/".appending(appStoreIdentifier)

    // MARK: Static content

    @objc static let unsupportedElementsUrl = "https://catrob.at/ibuf"
    static let aboutCatrobatUrl = "https://catrobat.org"
    static let helpUrl = "https://catrob.at/help"
    static let sourceCodeLicenseUrl = "https://developer.catrobat.org/licenses"
    static let termsOfUseUrl = shareUrl.appending("app/termsOfUse")
    static let resetPasswordUrl = shareUrl.appending("app/reset-password")

    // MARK: API

    static let apiBaseUrl = shareUrl.appending("api/")

    static let apiEndpointAuthentication = apiBaseUrl.appending("authentication")
    static let apiEndpointAuthenticationRefresh = apiEndpointAuthentication.appending("/refresh")
    static let apiEndpointAuthenticationUpgrade = apiEndpointAuthentication.appending("/upgrade")
    static let apiEndpointUser = apiBaseUrl.appending("user")
    static let apiEndpointUserResetPassword = apiEndpointUser.appending("/reset-password")

    static let apiEndpointMediaPackage = apiBaseUrl.appending("media/package")
    static let apiEndpointMediaPackageBackgrounds = apiEndpointMediaPackage.appending("/Backgrounds")
    static let apiEndpointMediaPackageLooks = apiEndpointMediaPackage.appending("/Looks")
    static let apiEndpointMediaPackageSounds = apiEndpointMediaPackage.appending("/Sounds")

    static let apiEndpointProject = apiBaseUrl.appending("project")
    static let apiEndpointProjects = apiBaseUrl.appending("projects")
    static let apiEndpointProjectsFeatured = apiEndpointProjects.appending("/featured")
    static let apiEndpointProjectsSearch = apiEndpointProjects.appending("/search")
    static let apiEndpointProjectsTags = apiEndpointProjects.appending("/tags")

    static let apiParameterOffset = "offset"
    static let apiParameterLimit = "limit"
    static let apiParameterMaxVersion = "max_version"
    static let apiParameterQuery = "query"
    static let apiParameterCategory = "category"
    static let apiParameterPlatform = "platform"
    static let apiParameterAttributes = "attributes"

    static let apiActionDownload = "catrobat"

    // MARK: API Configuration

    static let connectionTimeout = 15

    static let featuredProjectsBatchSize = 20
    static let chartProjectsBatchSize = 20
    static let searchProjectsBatchSize = 20

    static let searchLookupDelayInSeconds = 0.3

    static let mediaPackageMaxItems = 10000

    static let currentPlatform = "ios"

    static let kUsername = "username"
    static let kAuthenticationToken = "authenticationToken"
    static let kRefreshToken = "refreshToken"
    static let kLegacyToken = "userLoginToken"

    static let tokenExpirationTolerance = 600 // = 10 min

    // MARK: WebRequestDownloader

    static let kWebRequestMaxDownloadSizeInBytes = 1000000 // = 1MB
    static let kNumberOfConcurrentDownloads = 10

    // MARK: Wiki
    static let kWebRequestWikiURL = "https://wiki.catrobat.org/bin/view/Documentation/Web%20requests/"
}

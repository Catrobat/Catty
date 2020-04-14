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

import SWXMLHash

struct CBHeader: XMLIndexerDeserializable, Equatable {
    var applicationBuildName: String?
    var applicationBuildNumber: String?
    var applicationName: String?
    var applicationVersion: String?
    var catrobatLanguageVersion: String?
    var dateTimeUpload: String?
    var description: String?
    var deviceName: String?
    var isCastProject: String?
    var landscapeMode: String?
    var mediaLicense: String?
    var platform: String?
    var platformVersion: String?
    var programLicense: String?
    var programName: String?
    var remixOf: String?
    var scenesEnabled: String?
    var screenHeight: String?
    var screenMode: String?
    var screenWidth: String?
    var tags: String?
    var url: String?
    var userHandle: String?
    var programID: String?

    init (applicationBuildName: String? = nil,
          applicationBuildNumber: String? = nil,
          applicationName: String? = nil,
          applicationVersion: String? = nil,
          catrobatLanguageVersion: String? = nil,
          dateTimeUpload: String? = nil,
          description: String? = nil,
          deviceName: String? = nil,
          isCastProject: String? = nil,
          landscapeMode: String? = nil,
          mediaLicense: String? = nil,
          platform: String? = nil,
          platformVersion: String? = nil,
          programLicense: String? = nil,
          programName: String? = nil,
          remixOf: String? = nil,
          scenesEnabled: String? = nil,
          screenHeight: String? = nil,
          screenMode: String? = nil,
          screenWidth: String? = nil,
          tags: String? = nil,
          url: String? = nil,
          userHandle: String? = nil,
          programID: String? = nil) {
        self.applicationBuildName = applicationBuildName
        self.applicationBuildNumber = applicationBuildNumber
        self.applicationName = applicationName
        self.applicationVersion = applicationVersion
        self.catrobatLanguageVersion = catrobatLanguageVersion
        self.dateTimeUpload = dateTimeUpload
        self.description = description
        self.deviceName = deviceName
        self.isCastProject = isCastProject
        self.landscapeMode = landscapeMode
        self.mediaLicense = mediaLicense
        self.platform = platform
        self.platformVersion = platformVersion
        self.programLicense = programLicense
        self.programName = programName
        self.remixOf = remixOf
        self.scenesEnabled = scenesEnabled
        self.screenHeight = screenHeight
        self.screenMode = screenMode
        self.screenWidth = screenWidth
        self.tags = tags
        self.url = url
        self.userHandle = userHandle
        self.programID = programID
    }

    static func deserialize(_ node: XMLIndexer) throws -> CBHeader {
        return try CBHeader(
            applicationBuildName: node["applicationBuildName"].value(),
            applicationBuildNumber: node["applicationBuildNumber"].value(),
            applicationName: node["applicationName"].value(),
            applicationVersion: node["applicationVersion"].value(),
            catrobatLanguageVersion: node["catrobatLanguageVersion"].value(),
            dateTimeUpload: node["dateTimeUpload"].value(),
            description: node["description"].value(),
            deviceName: node["deviceName"].value(),
            isCastProject: node["isCastProject"].value(),
            landscapeMode: node["landscapeMode"].value(),
            mediaLicense: node["mediaLicense"].value(),
            platform: node["platform"].value(),
            platformVersion: node["platformVersion"].value(),
            programLicense: node["programLicense"].value(),
            programName: node["programName"].value(),
            remixOf: node["remixOf"].value(),
            scenesEnabled: node["scenesEnabled"].value(),
            screenHeight: node["screenHeight"].value(),
            screenMode: node["screenMode"].value(),
            screenWidth: node["screenWidth"].value(),
            tags: node["tags"].value(),
            url: node["url"].value(),
            userHandle: node["userHandle"].value(),
            programID: nil
        )
    }

    static func == (lhs: CBHeader, rhs: CBHeader) -> Bool {
        let lhsDescriptionComponents = lhs.description?.components(separatedBy: .whitespacesAndNewlines)
        let lhsDescriptionShort = lhsDescriptionComponents?.filter { !$0.isEmpty }.joined(separator: " ")
        let rhsDescriptionComponents = rhs.description?.components(separatedBy: .whitespacesAndNewlines)
        let rhsDescriptionShort = rhsDescriptionComponents?.filter { !$0.isEmpty }.joined(separator: " ")

        let lhsLicenseWithoutHttps = lhs.programLicense?.split(separator: "/").last
        let rhsLicenseWithoutHttps = rhs.programLicense?.split(separator: "/").last

        let lhsRemixWithoutHttps = lhs.remixOf?.split(separator: ":").last
        let rhsRemixWithoutHttps = rhs.remixOf?.split(separator: ":").last

        let lhsUrlWithoutHttps = lhs.url?.split(separator: "/").last
        let rhsUrlWithoutHttps = rhs.url?.split(separator: "/").last

        return
            lhs.applicationName == rhs.applicationName &&
            lhsDescriptionShort == rhsDescriptionShort &&
            lhsLicenseWithoutHttps == rhsLicenseWithoutHttps &&
            lhs.programName == rhs.programName &&
            lhsRemixWithoutHttps == rhsRemixWithoutHttps &&
            lhs.screenHeight == rhs.screenHeight &&
            lhs.screenWidth == rhs.screenWidth &&
            lhsUrlWithoutHttps == rhsUrlWithoutHttps &&
            lhs.userHandle == rhs.userHandle
    }
}

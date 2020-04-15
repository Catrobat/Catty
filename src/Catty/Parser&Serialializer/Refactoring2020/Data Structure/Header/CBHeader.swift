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

struct CBHeader: Codable, Equatable {
    var applicationBuildName: String
    var applicationBuildNumber: String
    var applicationName: String
    var applicationVersion: String
    var catrobatLanguageVersion: String
    var dateTimeUpload: String?
    var description: String
    var deviceName: String
    var isCastProject: String?
    var landscapeMode: String
    var mediaLicense: String
    var platform: String
    var platformVersion: String
    var programLicense: String
    var programName: String
    var remixOf: String?
    var scenesEnabled: String?
    var screenHeight: String?
    var screenMode: String?
    var screenWidth: String?
    var tags: String?
    var url: String?
    var userHandle: String?
    var programID: String?

    init(_ header: Header) {
        self.applicationBuildName = header.applicationBuildName
        self.applicationBuildNumber = header.applicationBuildNumber
        self.applicationName = header.applicationName
        self.applicationVersion = header.applicationVersion
        self.catrobatLanguageVersion = header.catrobatLanguageVersion

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kCatrobatHeaderDateTimeFormat
        if let dateTime = header.dateTimeUpload {
            self.dateTimeUpload = dateFormatter.string(from: dateTime)
        }

        self.description = header.programDescription
        self.deviceName = header.deviceName
        self.landscapeMode = String(header.landscapeMode)
        self.mediaLicense = header.mediaLicense
        self.platform = header.platform
        self.platformVersion = header.platformVersion
        self.programLicense = header.programLicense
        self.programName = header.programName
        self.remixOf = header.remixOf
        self.screenHeight = header.screenHeight.stringValue
        self.screenMode = header.screenMode
        self.screenWidth = header.screenWidth.stringValue
        self.tags = header.tags
        self.url = header.url
        self.userHandle = header.userHandle
        self.programID = header.programID
    }

    func transform() -> Header {
        let header = Header()
        header.applicationBuildName = self.applicationBuildName
        header.applicationBuildNumber = self.applicationBuildNumber
        header.applicationName = self.applicationName
        header.applicationVersion = self.applicationVersion
        header.catrobatLanguageVersion = self.catrobatLanguageVersion

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kCatrobatHeaderDateTimeFormat
        header.dateTimeUpload = dateFormatter.date(from: self.dateTimeUpload ?? "")

        header.programDescription = self.description
        header.deviceName = self.deviceName
        header.landscapeMode = self.landscapeMode.bool
        header.mediaLicense = self.mediaLicense
        header.platform = self.platform
        header.platformVersion = self.platformVersion
        header.programLicense = self.programLicense
        header.programName = self.programName
        header.remixOf = self.remixOf

        var screenHeight: NSNumber?
        if let tmp = Int(self.screenHeight ?? "") {
            screenHeight = NSNumber(value: tmp)
        }
        header.screenHeight = screenHeight

        header.screenMode = self.screenMode

        var screenWidth: NSNumber?
        if let tmp = Int(self.screenWidth ?? "") {
            screenWidth = NSNumber(value: tmp)
        }
        header.screenWidth = screenWidth

        header.tags = self.tags.isEmptyButNotNil() ? nil : self.tags
        header.url = self.url
        header.userHandle = self.userHandle
        header.programID = self.programID

        return header
    }

    static func == (lhs: CBHeader, rhs: CBHeader) -> Bool {
        let lhsDescriptionComponents = lhs.description.components(separatedBy: .whitespacesAndNewlines)
        let lhsDescriptionShort = lhsDescriptionComponents.filter { !$0.isEmpty }.joined(separator: " ")
        let rhsDescriptionComponents = rhs.description.components(separatedBy: .whitespacesAndNewlines)
        let rhsDescriptionShort = rhsDescriptionComponents.filter { !$0.isEmpty }.joined(separator: " ")

        let lhsLicenseWithoutHttps = lhs.programLicense.split(separator: "/").last
        let rhsLicenseWithoutHttps = rhs.programLicense.split(separator: "/").last

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

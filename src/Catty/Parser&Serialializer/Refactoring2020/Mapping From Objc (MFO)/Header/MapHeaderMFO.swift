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

extension CBXMLMappingFromObjc {

    static func mapHeader(project: Project) -> CBHeader {
        let header = project.header

        var mappedHeader = CBHeader()
        mappedHeader.applicationBuildName = header.applicationBuildName
        mappedHeader.applicationBuildNumber = header.applicationBuildNumber
        mappedHeader.applicationName = header.applicationName
        mappedHeader.applicationVersion = header.applicationVersion

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kCatrobatHeaderDateTimeFormat
        if let dateTime = header.dateTimeUpload {
            mappedHeader.dateTimeUpload = dateFormatter.string(from: dateTime)
        }

        mappedHeader.description = header.programDescription
        mappedHeader.deviceName = header.deviceName
        mappedHeader.landscapeMode = String(header.landscapeMode)
        mappedHeader.mediaLicense = header.mediaLicense
        mappedHeader.platform = header.platform
        mappedHeader.platformVersion = header.platformVersion
        mappedHeader.programLicense = header.programLicense
        mappedHeader.programName = header.programName
        mappedHeader.remixOf = header.remixOf
        mappedHeader.screenHeight = header.screenHeight.stringValue
        mappedHeader.screenMode = header.screenMode
        mappedHeader.screenWidth = header.screenWidth.stringValue
        mappedHeader.tags = header.tags
        mappedHeader.url = header.url
        mappedHeader.userHandle = header.userHandle
        mappedHeader.programID = header.programID

        return mappedHeader
    }
}

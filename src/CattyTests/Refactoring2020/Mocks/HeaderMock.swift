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

@testable import Pocket_Code

class HeaderMock {
    
    var applicationBuildName = "Catty"
    var applicationBuildNumber = "0"
    var applicationName = "Mock"
    var applicationVersion = "0.01"
    var catrobatLanguageVersion = "0.80"
    var dateTimeUpload = "2020-01-0203:04:05"
    var programDescription = "test description"
    var deviceName = "iPhone X"
    var landscapeMode = false
    var mediaLicense = "http://developer.catrobat.org/ccbysa_v3"
    var platform = "iOS"
    var platformVersion = "13.1"
    var programLicense = "http://developer.catrobat.org/agpl_v3"
    var programName = "Test Project"
    var remixOf = "https://pocketcode.org/details/719"
    var screenHeight = NSNumber(integerLiteral: 1000)
    var screenWidth = NSNumber(integerLiteral: 400)
    var screenMode = ""
    var tags = "one, two, three"
    var url = "http://pocketcode.org/details/719"
    var userHandle = "Catrobat"
    var programID = "123"
        
    func getCBProject() -> CBProject {
        var header = CBHeader()
        header.applicationBuildName = applicationBuildName
        header.applicationBuildNumber = applicationBuildNumber
        header.applicationName = applicationName
        header.applicationVersion = applicationVersion
        header.catrobatLanguageVersion = catrobatLanguageVersion
        header.dateTimeUpload = dateTimeUpload
        header.description = programDescription
        header.deviceName = deviceName
        header.landscapeMode = String(landscapeMode)
        header.mediaLicense = mediaLicense
        header.platform = platform
        header.platformVersion = platformVersion
        header.programLicense = programLicense
        header.programName = programName
        header.remixOf = remixOf
        header.screenHeight = screenHeight.stringValue
        header.screenWidth = screenWidth.stringValue
        header.screenMode = screenMode
        header.tags = tags
        header.url = url
        header.userHandle = userHandle
        header.programID = programID
        
        return CBProject(header: header)
    }
    
    func getProject() -> Project {
        let header = Header()
        header.applicationBuildName = applicationBuildName
        header.applicationBuildNumber = applicationBuildNumber
        header.applicationName = applicationName
        header.applicationVersion = applicationVersion
        header.catrobatLanguageVersion = catrobatLanguageVersion
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kCatrobatHeaderDateTimeFormat
        header.dateTimeUpload = dateFormatter.date(from: dateTimeUpload)
        
        header.programDescription = programDescription
        header.deviceName = deviceName
        header.landscapeMode = landscapeMode
        header.mediaLicense = mediaLicense
        header.platform = platform
        header.platformVersion = platformVersion
        header.programLicense = programLicense
        header.programName = programName
        header.remixOf = remixOf
        header.screenHeight = screenHeight
        header.screenWidth = screenWidth
        header.screenMode = screenMode
        header.tags = tags
        header.url = url
        header.userHandle = userHandle
        header.programID = programID
        
        let project = Project()
        project.header = header
        
        return project
    }
}

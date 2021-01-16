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

import Foundation

func synchronized(lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

@objc extension Util {

    class func appName() -> String? {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        return appName
    }

    class func appVersion() -> String? {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion
    }

    class func appBuildName() -> String? {
        let appBuildName = Bundle.main.infoDictionary?["CatrobatBuildName"] as? String
        return appBuildName
    }

    class func appBuildVersion() -> String? {
        let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return appBuildVersion
    }

    class func catrobatLanguageVersion() -> String {
        let catrobatLanguageVersion = Bundle.main.infoDictionary?["CatrobatLanguageVersion"] as! String
        return catrobatLanguageVersion
    }

    class func catrobatMediaLicense() -> String? {
        let catrobatMediaLicense = Bundle.main.infoDictionary?["CatrobatMediaLicense"] as? String
        return catrobatMediaLicense
    }

    class func catrobatProgramLicense() -> String? {
        let catrobatProgramLicense = Bundle.main.infoDictionary?["CatrobatProgramLicense"] as? String
        return catrobatProgramLicense
    }

    class func deviceName() -> String {
        let deviceName = UIDevice.current.modelName as String
        return deviceName
    }

    class func platformName() -> String? {
        let platformName = Bundle.main.infoDictionary?["CatrobatPlatformName"] as? String
        return platformName
    }

    class func platformVersion() -> OperatingSystemVersion {
        let platformVersion = ProcessInfo.processInfo.operatingSystemVersion
        return platformVersion
    }

    class func platformVersionWithPatch() -> String {
        let os = self.platformVersion()
        let major = String(format: "%ld", os.majorVersion)
        let minor = String(format: "%ld", os.minorVersion)
        let patch = String(format: "%ld", os.patchVersion)
        let platformVersionWithPatch = "\(major).\(minor).\(patch)" as String
        return platformVersionWithPatch
    }
    class func platformVersionWithoutPatch() -> String {
        let os = self.platformVersion()
        let major = String(format: "%ld", os.majorVersion)
        let minor = String(format: "%ld", os.minorVersion)
        let platformVersionWithoutPatch = "\(major).\(minor)" as String
        return platformVersionWithoutPatch
    }
}

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

import Firebase

final class CrashlyticsMock: Crashlytics {

    private static var logStorage = [CrashlyticsMock: [String]]()
    private static var recordStorage = [CrashlyticsMock: [Error]]()
    private static var collectionEnabled = [CrashlyticsMock: Bool]()

    static func create(collectionEnabled: Bool) -> CrashlyticsMock {
        let crashlytics = ForceInit.createInstance(ofClass: "FIRCrashlytics") as! Crashlytics
        object_setClass(crashlytics, CrashlyticsMock.self)
        let crashlyticsMock = crashlytics as! CrashlyticsMock
        CrashlyticsMock.collectionEnabled[crashlyticsMock] = collectionEnabled
        CrashlyticsMock.logStorage[crashlyticsMock] = [String]()
        CrashlyticsMock.recordStorage[crashlyticsMock] = [Error]()
        return crashlyticsMock
    }

    override func isCrashlyticsCollectionEnabled() -> Bool { CrashlyticsMock.collectionEnabled[self]! }

    override func setCrashlyticsCollectionEnabled(_ enabled: Bool) {
        CrashlyticsMock.collectionEnabled[self] = enabled
    }

    override func log(_ msg: String) {
        CrashlyticsMock.logStorage[self]!.append(msg)
    }

    override func record(error: Error) {
        CrashlyticsMock.recordStorage[self]!.append(error)
    }

    var logs: [String] {
        CrashlyticsMock.logStorage[self]!
    }

    var records: [Error] {
        CrashlyticsMock.recordStorage[self]!
    }
}

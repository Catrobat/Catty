#!/usr/bin/env xcrun swift -I .
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

import Foundation

//============================================================================================================
//
//                                 SCRIPT CONFIGURATION
//
//============================================================================================================

//------------------------------------------------------------------------------------------------------------
//                                 CHECKS
//------------------------------------------------------------------------------------------------------------

let licenseSearchStringTemplate = "/**\n *  Copyright (C) 2010-%d The Catrobat Team\n"
    + " *  (http://developer.catrobat.org/credits)\n *\n"
    + " *  This program is free software: you can redistribute it and/or modify\n"
    + " *  it under the terms of the GNU Affero General Public License as\n"
    + " *  published by the Free Software Foundation, either version 3 of the\n"
    + " *  License, or (at your option) any later version.\n"
    + " *\n"
    + " *  An additional term exception under section 7 of the GNU Affero\n"
    + " *  General Public License, version 3, is available at\n"
    + " *  (http://developer.catrobat.org/license_additional_term)\n"
    + " *\n"
    + " *  This program is distributed in the hope that it will be useful,\n"
    + " *  but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
    + " *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n"
    + " *  GNU Affero General Public License for more details.\n"
    + " *\n"
    + " *  You should have received a copy of the GNU Affero General Public License\n"
    + " *  along with this program.  If not, see http://www.gnu.org/licenses/.\n */"

let year = Calendar.current.component(.year, from: Date())
let licenseSearchStringCurrentYear = String(format: licenseSearchStringTemplate, year)

let kErrorSuccess: Int32 = 0
let kErrorFailed: Int32 = 1
let fileManager = FileManager.default

enum License: String {
    case GNUAfferoGeneralPublicLicense
    case MIT
    case zlib
    case Apache2
    case Apple
    case BSD
    case Unknown
}

let license3rdPartyDict: [String: License] = [
    "LLNode": .MIT,
    "CBStack": .MIT,
    "OrderedDictionary": .zlib,
    "NSString+FastImageSize": .MIT,
    "UIViewController+CWPopup": .MIT,
    "GDataXMLNode": .Apache2,
    "JNKeychain": .MIT,
    "SwellAll": .Apache2,
    "minizip": .zlib,
    "crypt": .BSD,
    "ioapi": .zlib,
    "mztools": .zlib,
    "unzip": .zlib,
    "zip": .zlib,
    "ImageHelper": .MIT,
    "Reachability": .Apple,
    "SharkfoodMuteSwitchDetector": .MIT,
    "Siren": .MIT,
    "SSZipArchive": .MIT,
    "LCTableViewPickerControl": .MIT,
    "LinkedListStack": .MIT,
    "NKOColorPickerView": .MIT,
    "SPUserResizableView": .MIT,
    "UIImage+FloodFill": .MIT,
    "UIViewController+KNSemiModal": .MIT,
    "YKImageCropperOverlayView": .MIT,
    "YKImageCropperView": .MIT,
    "AHKActionSheet": .MIT,
    "AHKActionSheetViewController": .MIT,
    "UIImage+AHKAdditions": .MIT,
    "UIWindow+AHKAdditions": .MIT,
    "BDKNotifyHUD": .MIT,
    "EVCircularProgressView": .MIT,
    "FXBlurView": .zlib,
    "IBActionSheet": .MIT,
    "LXReorderableCollectionViewFlowLayout": .MIT,
    "MYIntroductionPanel": .MIT,
    "TTTAttributedLabel": .MIT,
    "MXPagerView": .MIT,
    "MXPagerViewController": .MIT,
    "MXParallaxHeader": .MIT,
    "MXScrollView": .MIT,
    "MXScrollViewController": .MIT,
    "AudioKit": .MIT
]

let licenseCheckDirs: [String: License] = [
    "Bohr": .MIT,
    "HMSegmentedControl": .MIT,
    "PureLayout": .MIT,
    "M13ProgressSuite": .MIT,
    "MXSegmentedPager": .MIT,
    "Target Support Files": .MIT,
    "VGParallaxHeader": .MIT,
    "TOCropViewController": .MIT
]

let checkDirs: [String] = [
    "Bohr",
    "HMSegmentedControl",
    "PureLayout",
    "M13ProgressSuite",
    "MXSegmentedPager",
    "Target Support Files",
    "VGParallaxHeader",
    "TOCropViewController"
]

let compatibleLicenses: [License] = [
    .MIT, .zlib, .Apache2, .Apple, .BSD
]

func printErrorAndExitIfFailed(_ errorMessage: String) {
    print("\(errorMessage)")
    exit(kErrorFailed)
}

func printErrorAndExitIfFailed(_ erorMessage: String, withFilePath filePath: String) {
    printErrorAndExitIfFailed("\(filePath):1:  error: \(erorMessage)")
}

func printWarning(_ warning: String, withFilePath filePath: String) {
    print("\(filePath):1:  warning: \(warning)")
}

func isValidLicense(_ license: License) -> Bool {

    return compatibleLicenses.contains(license)

}

func checkLicenseOfFile(_ filePath: String) {

    var isExternalLibrary = false
    var libraryName = ""
    do {
        let content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        let range = content.range(of: licenseSearchStringCurrentYear)
        if range == nil {
            isExternalLibrary = true
            //let removedFileName = (filePath as NSString).stringByDeletingLastPathComponent
            //libraryName = (removedFileName as NSString).lastPathComponent
            libraryName = (filePath as NSString).lastPathComponent
            libraryName = (libraryName as NSString).deletingPathExtension
        }
    } catch let error as NSError {
        printErrorAndExitIfFailed("Could not open file \(error)")
    }

    if isExternalLibrary {
        for excludeDir in checkDirs {
            let range = filePath.range(of: excludeDir)
            if range != nil {
                libraryName = excludeDir
                guard let license = licenseCheckDirs[libraryName] else {
                    printErrorAndExitIfFailed("No license specified for library: \(libraryName). Please add the license also to our license folder", withFilePath: filePath)
                    return
                }

                if license == .Unknown {
                    printWarning("Unknown License found. Not sure if compatible with PocketCode", withFilePath: filePath)
                } else {
                    if !isValidLicense(license) {
                        printErrorAndExitIfFailed("License (\(license)) is not compatible with PockedCode.", withFilePath: filePath)
                    }
                }
                return
            }
        }

        guard let license = license3rdPartyDict[libraryName] else {
            printErrorAndExitIfFailed("No license specified for library: \(libraryName).Please add the license also to our license folder", withFilePath: filePath)
            return
        }

        if license == .Unknown {
            printWarning("Unknown License found. Not sure if compatible with PocketCode", withFilePath: filePath)
        } else {
            if !isValidLicense(license) {
                printErrorAndExitIfFailed("License (\(license)) is not compatible with PockedCode.", withFilePath: filePath)
            }
        }
    }
}

func checkLicenses() {

    let filePaths = getFilePaths()
    while let filePath = filePaths.nextObject() as? String {

        // skip Build and DerivedData directories
        if filePath.hasPrefix("Build") || filePath.hasPrefix("DerivedData") || filePath.hasPrefix("Carthage") {
            continue
        }

        // only check source files
        if filePath.hasSuffix(".h") == false && filePath.hasSuffix(".m") == false && filePath.hasSuffix(".swift") == false {
            continue
        }

        checkLicenseOfFile(filePath)
    }

    exit(kErrorSuccess)
}

func getFilePaths() -> FileManager.DirectoryEnumerator {

    guard let enumerator = fileManager.enumerator(atPath: ".") else {
        print("Could not get enumerator")
        exit(kErrorFailed)
    }

    return enumerator
}

func getFileNameOfScript() -> String {

    guard let firstArgument = CommandLine.arguments.first else {
        print("\(#file):\(#line - 1): error: WTH is going on here!! "
            + "Unable to determine the file name of this script!\n")
        exit(kErrorFailed)
    }

    var fileNameOfThisScript = (firstArgument as NSString).lastPathComponent
    if fileNameOfThisScript.hasSuffix(".swift") == false {
        fileNameOfThisScript += ".swift"
    }

    return fileNameOfThisScript
}

// main
checkLicenses()

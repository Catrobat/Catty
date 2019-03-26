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

// CAVE: NEVER separate these two statements by adding a new line
let pathToReadmeFile = "../README.md"; let pathToReadmeFileLine = #line

let localizedStringCheckExcludeFiles = [
    "LanguageTranslationDefines.h",
    "LanguageTranslationDefinesSwift.swift",
    "LanguageTranslationDefinesUI.swift",
    "Functions.[hm]",
    "Operators.m",
    "BSKeyboardControls.m"
]; let localizedStringCheckExcludeFilesLine = #line; // CAVE: NEVER separate these two statements by adding a new line
let localizedStringCheckSeparatedExcludeDirs = [
    "Pods",
    "Carthage",
    "Build",
    "DerivedData"
]; let localizedStringCheckSeparatedExcludeDirsLine = #line; // CAVE: NEVER separate these two statements by adding a new line

let licenseCheckExcludeDirs = [
    "TTTAttributedLabel",
    "minizip",
    "SSZipArchive",
    "GDataXMLNode",
    "LXReorderableCollectionViewFlowLayout",
    "AHKActionSheetViewController",
    "AHKAdditions",
    "IBActionSheet",
    "SWCellScrollView",
    "SWLongPressGestureRecognizer",
    "SWTableViewCell",
    "FXBlurView",
    "BDKNotifyHUD",
    "EVCircularProgressView",
    "NSString+FastImageSize",
    "UIViewController+CWPopup",
    "OrderedDictionary",
    "3rdParty",
    "PocketPaint",
    "Carthage",
    "Build",
    "DerivedData",
    "Siren",
    "Pods",
    "PodSource"
]; let licenseCheckExcludeDirsLine = #line; // CAVE: NEVER separate these two statements by adding a new line

let licenseCheckExcludeFiles = [
    "AHKActionSheet.[mh]",
    "AHKActionSheetViewController.[mh]",
    "LXReorderableCollectionViewFlowLayout.[mh]",
    "IBActionSheet.[mh]",
    "Reachability.[mh]",
    "SharkfoodMuteSwitchDetector.[mh]",
    "SWCellScrollView.[mh]",
    "SWUtilityButtonView.[mh]",
    "UIImage+AHKAdditions.[mh]",
    "UIWindow+AHKAdditions.[mh]",
    "SWLongPressGestureRecognizer.[mh]",
    "SWTableViewCell.[mh]",
    "SWUtilityButtonTapGestureRecognizer.[mh]",
    "SMPageControl.[mh]",
    "EAIntroPage.[mh]",
    "MYIntroductionPanel.[mh]",
    "FBKVOController.[mh]",
    "JNKeychain.[mh]",
    "BOButtonTableViewCell.[mh]",
    "MXPagerView-umbrella.[mh]",
    "SwellAll.swift",
    "license-validator.swift"
]; let licenseCheckExcludeFilesLine = #line; // CAVE: NEVER separate these two statements by adding a new line

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

//============================================================================================================
//
//                                 SCRIPT IMPLEMENTATION
//
//============================================================================================================

let ERR_SUCCESS: Int32 = 0
let ERR_FAILED: Int32 = 1

let year = Calendar.current.component(.year, from: Date())
let licenseSearchStringCurrentYear = String(format: licenseSearchStringTemplate, year)
let licenseSearchStringPreviousYear = String(format: licenseSearchStringTemplate, year - 1)

//------------------------------------------------------------------------------------------------------------
//                                 FUNCTIONS
//------------------------------------------------------------------------------------------------------------
// helper functions
func printResultErrorAndExitIfFailed(_ failed: Bool, errorMessage: String?) {
    if failed {
        printErrorAndExitIfFailed(errorMessage!)
    }
}

func printErrorAndExitIfFailed(_ errorMessage: String) {
    stderr.write(errorMessage.data(using: String.Encoding.utf8)!)
    exit(ERR_FAILED)
}

// helper extensions
extension String {
    func removeCharsFromEnd(_ count: Int) -> String {
        let temp = self as NSString
        let stringLength = temp.length
        let substringIndex = (stringLength < count) ? 0 : stringLength - count
        return String(self[..<self.index(self.startIndex, offsetBy: substringIndex)])
    }
}

// checking functions
func localizedStringCheck(_ filePath: String, fileContent: String) -> (failed: Bool, errorMessage: String?) {
    let range = fileContent.range(of: "NSLocalizedString")
    if range == nil {
        return (false, nil)
    }

    let newRange: Range<String.Index> = fileContent.startIndex ..< range!.lowerBound
    let substring: String = String(fileContent[newRange])
    var lineNumber: Int = substring.components(separatedBy: "\n").count
    if lineNumber == 0 {
        lineNumber = 1
    }
    let errorMessage: String = "\(filePath):\(lineNumber): error : NSLocalizedString HAS TO BE moved to LanguageTranslationDefines.h or LanguageTranslationDefines.swift!\n"
    return (true, errorMessage)
}

func licenseCheck(_ filePath: String, fileContent: String, lineNumberOffset: Int = 0)
    -> (failed: Bool, errorMessage: String?) {
    let range = fileContent.range(of: licenseSearchStringCurrentYear)
    if range != nil {
        let index: Int = fileContent.distance(from: fileContent.startIndex, to: range!.lowerBound)
        if index != 0 {
            let newRange: Range<String.Index> = fileContent.startIndex ..< range!.lowerBound
            let substring: String = String(fileContent[newRange])
            var lineNumber: Int = substring.components(separatedBy: "\n").count
            if lineNumber == 0 {
                lineNumber = 1
            }
            let errorMessage: String = "\(filePath):\(lineNumber + lineNumberOffset): error : License header is valid but must always be placed at the very top of the file!\n"
            return (true, errorMessage)
        } else {
            return (false, nil)
        }
    }

    let rangePreviousYear = fileContent.range(of: licenseSearchStringPreviousYear)
    if rangePreviousYear != nil {
        let index: Int = fileContent.distance(from: fileContent.startIndex, to: rangePreviousYear!.lowerBound)
        var lineNumber: Int = 1
        if index != 0 {
            let newRange: Range<String.Index> = fileContent.startIndex ..< rangePreviousYear!.lowerBound
            let substring: String = String(fileContent[newRange])
            lineNumber = substring.components(separatedBy: "\n").count
            if lineNumber == 0 {
                lineNumber = 1
            }
        }
        return (true, "\(filePath):\(lineNumber + lineNumberOffset): error : Wrong year in license header!\n")
    }

    let lineNumber = 1 // license header must be at the very top of source file
    let errorMessage: String = "\(filePath):\(lineNumber + lineNumberOffset): error : No valid License Header at the beginning of the file found! "
        + "Maybe the license header is valid but contains some whitespaces at the end of some lines!\n"
    return (true, errorMessage)
}

func licenseCheckForReadme(_ filePath: String, fileContent: String) -> (failed: Bool, errorMessage: String?) {
    let range = fileContent.range(of: "## License Header")
    if range == nil {
        return (true, "\(pathToReadmeFile):1: error: Unable to find license header section\n")
    }
    let sectionString = String(fileContent[range!.lowerBound ..< fileContent.endIndex])
    let sectionRange = sectionString.range(of: "<code>")
    if sectionRange == nil {
        return (true, "\(pathToReadmeFile):1: error: Unable to find code section within license header section\n")
    }
    let licenseString = String(sectionString[sectionString.index(after: sectionRange!.upperBound) ..< sectionString.endIndex])
    let newLineCountRange = fileContent.startIndex ..< range!.upperBound
    let newLineCountSubString = String(fileContent[newLineCountRange])
    let lineNumberOfLicenseHeaderStart: Int = newLineCountSubString.components(separatedBy: "\n").count
    return licenseCheck(pathToReadmeFile,
                        fileContent: licenseString,
                        lineNumberOffset: lineNumberOfLicenseHeaderStart)
}

//------------------------------------------------------------------------------------------------------------
//                                 CHECKS
//------------------------------------------------------------------------------------------------------------

let stderr = FileHandle.standardError
let fileManager = FileManager.default
let enumerator: FileManager.DirectoryEnumerator? = fileManager.enumerator(atPath: ".")

guard let firstArgument = CommandLine.arguments.first else {
    printErrorAndExitIfFailed("\(#file):\(#line - 1): error: WTH is going on here!! "
        + "Unable to determine the file name of this script!\n")
    exit(ERR_FAILED)
}

var fileNameOfThisScript = (firstArgument as NSString).lastPathComponent
if fileNameOfThisScript.hasSuffix(".swift") == false {
    fileNameOfThisScript += ".swift"
}

// prepare lists
var index = 0
var localizedStringCheckSeparatedExcludeFiles = [String]()
for excludeFile in localizedStringCheckExcludeFiles {
    if excludeFile.hasSuffix(".m") || excludeFile.hasSuffix(".h") || excludeFile.hasSuffix(".swift") {
        localizedStringCheckSeparatedExcludeFiles.append(excludeFile)
        index += 1
        continue
    }
    if excludeFile.hasSuffix(".[hm]") || excludeFile.hasSuffix(".[mh]") {
        let fileNameWithoutExtension = excludeFile.removeCharsFromEnd(".[mh]".count)
        localizedStringCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".h")
        localizedStringCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".m")
    } else {
        let errorLineNumber = localizedStringCheckExcludeFilesLine - (localizedStringCheckExcludeFiles.count - index)
        let errorMessage = "\(#file):\(errorLineNumber): error: The entry \(excludeFile) is invalid!\n"
        stderr.write(errorMessage.data(using: String.Encoding.utf8)!)
        exit(ERR_FAILED)
    }
    index += 1
}
localizedStringCheckSeparatedExcludeFiles.append(fileNameOfThisScript)

index = 0
var licenseCheckSeparatedExcludeFiles = [String]()
for excludeFile in licenseCheckExcludeFiles {
    if excludeFile.hasSuffix(".m") || excludeFile.hasSuffix(".h") || excludeFile.hasSuffix(".swift") {
        licenseCheckSeparatedExcludeFiles.append(excludeFile)
        index += 1
        continue
    }
    if excludeFile.hasSuffix(".[hm]") || excludeFile.hasSuffix(".[mh]") {
        let fileNameWithoutExtension = excludeFile.removeCharsFromEnd(".[mh]".count)
        licenseCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".h")
        licenseCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".m")
    } else {
        let errorLineNumber = licenseCheckExcludeFilesLine - (licenseCheckExcludeFiles.count - index)
        let errorMessage = "\(#file):\(errorLineNumber): error: The entry \(excludeFile) is invalid!\n"
        stderr.write(errorMessage.data(using: String.Encoding.utf8)!)
        exit(ERR_FAILED)
    }
    index += 1
}
licenseCheckSeparatedExcludeFiles.append(fileNameOfThisScript)

while let filePath = enumerator!.nextObject() as? String {
    // only check source files
    if filePath.hasSuffix(".h") == false && filePath.hasSuffix(".m") == false && filePath.hasSuffix(".swift") == false {
        continue
    }

    let fileName = (filePath as NSString).lastPathComponent

    // localized string check
    var content: String?
    if localizedStringCheckSeparatedExcludeFiles.contains(fileName) == false {
        var fileIsStoredInAnExcludedDir = false
        for excludeDir in localizedStringCheckSeparatedExcludeDirs {
            let range = filePath.range(of: excludeDir)
            if range != nil {
                fileIsStoredInAnExcludedDir = true
                break
            }
        }
        if fileIsStoredInAnExcludedDir {
            continue
        }

        content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        if content == nil {
            continue
        }

        let (failed, errorMessage) = localizedStringCheck(filePath, fileContent: content!)
        printResultErrorAndExitIfFailed(failed, errorMessage: errorMessage)
    }

    // license header check
    if licenseCheckSeparatedExcludeFiles.contains(fileName) == false {
        var fileIsStoredInAnExcludedDir = false
        for excludeDir in licenseCheckExcludeDirs {
            let range = filePath.range(of: excludeDir)
            if range != nil {
                fileIsStoredInAnExcludedDir = true
                break
            }
        }
        if fileIsStoredInAnExcludedDir {
            continue
        }

        if content == nil { // read in file if not yet done
            content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            if content == nil {
                continue
            }
        }
        let (failed, errorMessage) = licenseCheck(filePath, fileContent: content!)
        printResultErrorAndExitIfFailed(failed, errorMessage: errorMessage)
    }
}

// license check for README.md
do {
    let readmeFileContent = try String(contentsOfFile: pathToReadmeFile, encoding: String.Encoding.utf8)
    let (failed, errorMessage) = licenseCheckForReadme(pathToReadmeFile, fileContent: readmeFileContent)
    printResultErrorAndExitIfFailed(failed, errorMessage: errorMessage)
} catch {
    printErrorAndExitIfFailed("\(#file):\(pathToReadmeFileLine): error: Unable to open file or invalid filePath given!\n")
}

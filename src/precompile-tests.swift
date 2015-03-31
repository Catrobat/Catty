#!/usr/bin/env xcrun swift
/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
let pathToReadmeFile = "../README.md"; let pathToReadmeFileLine = __LINE__;

let localizedStringCheckExcludeFiles = [
    "LanguageTranslationDefines.h",
    "Functions.[hm]",
    "Operators.m",
    "BSKeyboardControls.m"
]; let localizedStringCheckExcludeFilesLine = __LINE__; // CAVE: NEVER separate these two statements by adding a new line

let licenseCheckExcludeDirs = [
    "TTTAttributedLabel",
    "minizip",
    "SSZipArchive",
    "GDataXMLNode",
    "FBShimmering",
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
    "pocketPaint"
]; let licenseCheckExcludeDirsLine = __LINE__; // CAVE: NEVER separate these two statements by adding a new line

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
    "MYBlurIntroductionView.[mh]",
    "MYIntroductionPanel.[mh]",
    "FBKVOController.[mh]"
]; let licenseCheckExcludeFilesLine = __LINE__; // CAVE: NEVER separate these two statements by adding a new line

let licenseSearchStringTemplate = "/**\n *  Copyright (C) 2010-%@ The Catrobat Team\n"
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

let ERR_SUCCESS : Int32 = 0
let ERR_FAILED : Int32 = 1

let components : NSDateComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: NSDate())
let licenseSearchStringCurrentYear = String(format:licenseSearchStringTemplate, String(components.year))
let licenseSearchStringPreviousYear = String(format:licenseSearchStringTemplate, String(components.year - 1))

//------------------------------------------------------------------------------------------------------------
//                                 FUNCTIONS
//------------------------------------------------------------------------------------------------------------
func localizedStringCheck(#filePath : String, #fileContent : String) -> (failed: Bool, errorMessage: NSString?)
{
    let range = fileContent.rangeOfString("NSLocalizedString")
    if range == nil {
        return (false, nil)
    }

    var newRange : Range<String.Index> = Range<String.Index>(start: fileContent.startIndex, end: range!.startIndex)
    let substring : String = fileContent.substringWithRange(newRange)
    var lineNumber : Int = substring.componentsSeparatedByString("\n").count
    if lineNumber == 0 {
        lineNumber = 1
    }
    let errorMessage : String = "\(filePath):\(lineNumber): error : NSLocalizedString HAS TO BE moved to LanguageTranslationDefines.h!\n"
    return (true, errorMessage)
}

func licenseCheck(#filePath : String, #fileContent : String, lineNumberOffset : Int = 0)
    -> (failed: Bool, errorMessage: NSString?)
{
    let range = fileContent.rangeOfString(licenseSearchStringCurrentYear)
    if range != nil {
        let index: Int = distance(fileContent.startIndex, range!.startIndex)
        if index != 0 {
            var newRange : Range<String.Index> = Range<String.Index>(start: fileContent.startIndex, end: range!.startIndex)
            let substring : String = fileContent.substringWithRange(newRange)
            var lineNumber : Int = substring.componentsSeparatedByString("\n").count
            if lineNumber == 0 {
                lineNumber = 1
            }
            let errorMessage : String = "\(filePath):\(lineNumber + lineNumberOffset): error : License header is valid but must always be placed at the very top of the file!\n"
            return (true, errorMessage)
        } else {
            return (false, nil)
        }
    }

    let rangePreviousYear = fileContent.rangeOfString(licenseSearchStringPreviousYear)
    if rangePreviousYear != nil {
        let index: Int = distance(fileContent.startIndex, rangePreviousYear!.startIndex)
        var lineNumber : Int = 1
        if index != 0 {
            var newRange : Range<String.Index> = Range<String.Index>(start: fileContent.startIndex, end: rangePreviousYear!.startIndex)
            let substring : String = fileContent.substringWithRange(newRange)
            lineNumber = substring.componentsSeparatedByString("\n").count
            if lineNumber == 0 {
                lineNumber = 1
            }
        }
        return (true, "\(filePath):\(lineNumber + lineNumberOffset): error : Wrong year in license header!\n")
    }

    let lineNumber = 1 // license header must be at the very top of source file
    let errorMessage : String = "\(filePath):\(lineNumber + lineNumberOffset): error : No valid License Header at the beginning of the file found! Maybe the license header is valid but contains some whitespaces at the end of some lines!\n"
    return (true, errorMessage)
}

func licenseCheckForReadme(#filePath : String, #fileContent : String) -> (failed: Bool, errorMessage: NSString?)
{
    let range = fileContent.rangeOfString("## License Header")
    if range == nil {
        return (true, "\(pathToReadmeFile):1: error: Unable to find license header section\n")
    }
    let sectionString = fileContent.substringWithRange(Range<String.Index>(start: range!.startIndex,
        end: fileContent.endIndex))
    let sectionRange = sectionString.rangeOfString("<code>")
    if sectionRange == nil {
        return (true, "\(pathToReadmeFile):1: error: Unable to find code section within license header section\n")
    }
    let licenseString = sectionString.substringWithRange(Range<String.Index>(start: advance(sectionRange!.endIndex, 1),
                                                                               end: sectionString.endIndex))
    var newLineCountRange = Range<String.Index>(start: fileContent.startIndex, end: range!.endIndex)
    let newLineCountSubString = fileContent.substringWithRange(newLineCountRange)
    var lineNumberOfLicenseHeaderStart : Int = newLineCountSubString.componentsSeparatedByString("\n").count
    return licenseCheck(filePath: pathToReadmeFile,
                     fileContent: licenseString,
                lineNumberOffset: lineNumberOfLicenseHeaderStart)
}

// helper functions
func printResultErrorAndExitIfFailed(#failed: Bool, #errorMessage: String?)
{
    if failed {
        printErrorAndExitIfFailed(errorMessage!)
    }
}

func printErrorAndExitIfFailed(errorMessage: String)
{
    stderr.writeData(errorMessage.dataUsingEncoding(NSUTF8StringEncoding)!)
    exit(ERR_FAILED)
}

// helper extensions
extension String {
    func removeCharsFromEnd(count:Int) -> String {
        let stringLength = countElements(self)
        let substringIndex = (stringLength < count) ? 0 : stringLength - count
        return self.substringToIndex(advance(self.startIndex, substringIndex))
    }
}

//------------------------------------------------------------------------------------------------------------
//                                 CHECKS
//------------------------------------------------------------------------------------------------------------

let stderr = NSFileHandle.fileHandleWithStandardError()
let fileManager = NSFileManager.defaultManager()
let enumerator:NSDirectoryEnumerator? = fileManager.enumeratorAtPath(".")

let fileNameOfThisScript : String? = Process.arguments.first?.lastPathComponent
if fileNameOfThisScript == nil {
    printErrorAndExitIfFailed("\(__FILE__):\(__LINE__ - 1): error: WTH is going on here!! Unable to determine the file name of this script!\n")
}

// prepare lists
var index = 0
var localizedStringCheckSeparatedExcludeFiles = [String]()
for excludeFile in localizedStringCheckExcludeFiles {
    if excludeFile.hasSuffix(".m") || excludeFile.hasSuffix(".h") || excludeFile.hasSuffix(".swift") {
        localizedStringCheckSeparatedExcludeFiles.append(excludeFile)
        ++index
        continue
    }
    if excludeFile.hasSuffix(".[hm]") || excludeFile.hasSuffix(".[mh]") {
        let fileNameWithoutExtension = excludeFile.removeCharsFromEnd(".[mh]".length)
        localizedStringCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".h")
        localizedStringCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".m")
    } else {
        let errorLineNumber = localizedStringCheckExcludeFilesLine - (localizedStringCheckExcludeFiles.count - index)
        let errorMessage = "\(__FILE__):\(errorLineNumber): error: The entry \(excludeFile) is invalid!\n"
        stderr.writeData(errorMessage.dataUsingEncoding(NSUTF8StringEncoding)!)
        exit(ERR_FAILED)
    }
    ++index
}
localizedStringCheckSeparatedExcludeFiles.append(fileNameOfThisScript!)

index = 0
var licenseCheckSeparatedExcludeFiles = [String]()
for excludeFile in licenseCheckExcludeFiles {
    if excludeFile.hasSuffix(".m") || excludeFile.hasSuffix(".h") || excludeFile.hasSuffix(".swift") {
        licenseCheckSeparatedExcludeFiles.append(excludeFile)
        ++index
        continue
    }
    if excludeFile.hasSuffix(".[hm]") || excludeFile.hasSuffix(".[mh]") {
        let fileNameWithoutExtension = excludeFile.removeCharsFromEnd(".[mh]".length)
        licenseCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".h")
        licenseCheckSeparatedExcludeFiles.append(fileNameWithoutExtension + ".m")
    } else {
        let errorLineNumber = licenseCheckExcludeFilesLine - (licenseCheckExcludeFiles.count - index)
        let errorMessage = "\(__FILE__):\(errorLineNumber): error: The entry \(excludeFile) is invalid!\n"
        stderr.writeData(errorMessage.dataUsingEncoding(NSUTF8StringEncoding)!)
        exit(ERR_FAILED)
    }
    ++index
}
licenseCheckSeparatedExcludeFiles.append(fileNameOfThisScript!)

while let filePath = enumerator!.nextObject() as? String {
    // only check source files
    if filePath.hasSuffix(".h") == false && filePath.hasSuffix(".m") == false && filePath.hasSuffix(".swift") == false {
        continue
    }

    let fileName = filePath.lastPathComponent

    // localized string check
    var content : String? = nil
    if contains(localizedStringCheckSeparatedExcludeFiles, fileName) == false {
        content = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
        if (content == nil) {
            continue
        }

        let (failed, errorMessage) = localizedStringCheck(filePath:filePath, fileContent:content!)
        printResultErrorAndExitIfFailed(failed:failed, errorMessage:errorMessage)
    }

    // license header check
    if contains(licenseCheckSeparatedExcludeFiles, fileName) == false {
        var fileIsStoredInAnExcludedDir = false
        for excludeDir in licenseCheckExcludeDirs {
            let range = filePath.rangeOfString(excludeDir)
            if range != nil {
                fileIsStoredInAnExcludedDir = true
                break
            }
        }
        if fileIsStoredInAnExcludedDir {
            continue
        }

        if content == nil { // read in file if not yet done
            content = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
            if content == nil {
                continue
            }
        }
        let (failed, errorMessage) = licenseCheck(filePath:filePath, fileContent:content!)
        printResultErrorAndExitIfFailed(failed:failed, errorMessage:errorMessage)
    }
}

// license check for README.md
let readmeFileContent = String(contentsOfFile: pathToReadmeFile, encoding: NSUTF8StringEncoding, error: nil)
if (readmeFileContent == nil) {
    printErrorAndExitIfFailed("\(__FILE__):\(pathToReadmeFileLine): error: Unable to open file or invalid filePath given!\n")
}
let (failed, errorMessage) = licenseCheckForReadme(filePath: pathToReadmeFile, fileContent: readmeFileContent!)
printResultErrorAndExitIfFailed(failed:failed, errorMessage:errorMessage)

exit(ERR_SUCCESS)

#!/usr/bin/env xcrun swift -I .
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


//------------------------------------------------------------------------------------------------------------
//                                 CHECKS
//------------------------------------------------------------------------------------------------------------


let fileManager = NSFileManager.defaultManager()

func checkLicenses() {
    
    
    let filePaths = getFilePaths
    while let filePath = enumerator!.nextObject() as? String {
        print("filePath: \(filePath)")
    }
}



func getFilePaths() -> NSDirectoryEnumerator {
    
    let enumerator: NSDirectoryEnumerator? = fileManager.enumeratorAtPath(".")
    
    //let fileNameOfThisScript = getFileNameOfScript()
    
    // TODO: Exclude files??
    
    return enumerator
}


func getFileNameOfScript() -> String {
    
    guard let firstArgument = Process.arguments.first else {
        printErrorAndExitIfFailed("\(__FILE__):\(__LINE__ - 1): error: WTH is going on here!! "
            + "Unable to determine the file name of this script!\n")
        exit(ERR_FAILED)
    }
    
    var fileNameOfThisScript = (firstArgument as NSString).lastPathComponent
    if fileNameOfThisScript.hasSuffix(".swift") == false {
        fileNameOfThisScript += ".swift"
    }
    
    return fileNameOfThisScript
}

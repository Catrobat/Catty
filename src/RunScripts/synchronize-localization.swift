#!/usr/bin/env xcrun swift -I .
/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

let fileData = try String(contentsOfFile: "Catty/Defines/LanguageTranslationDefines.h", encoding: .utf8)

var newData = fileData.replacingOccurrences(of: "#define ", with: "let ")
newData = newData.replacingOccurrences(of: "NSLocalizedString(@", with: "= NSLocalizedString(")
newData = newData.replacingOccurrences(of: "NSLocalizedString (@", with: "= NSLocalizedString(")
newData = newData.replacingOccurrences(of: "@\"", with: "\"")
newData = newData.replacingOccurrences(of: "\",\"", with: "\", \"")
newData = newData.replacingOccurrences(of: "\",nil", with: "\", nil")
newData = newData.replacingOccurrences(of: "\", ", with: "\", comment: ")
newData = newData.replacingOccurrences(of: "nil", with: "\"\"")
newData = newData.replacingOccurrences(of: "\\%", with: "%")

try newData.write(to: URL(fileURLWithPath: "Catty/Defines/LanguageTranslationDefinesSwift.swift"), atomically: false, encoding: .utf8)

newData = newData.replacingOccurrences(of: "\", comment: ", with: "\", bundle: Bundle(for: LanguageTranslation.self), comment: ")
newData += "\nimport UIKit\n\nclass LanguageTranslation {}\n"

try newData.write(to: URL(fileURLWithPath: "CattyUITests/Defines/LanguageTranslationDefinesUI.swift"), atomically: false, encoding: .utf8)

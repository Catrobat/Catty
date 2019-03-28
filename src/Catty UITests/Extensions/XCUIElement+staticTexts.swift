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

import XCTest

extension XCUIElement {
    func staticTextBeginsWith(_ queryString: String) -> XCUIElement {
        return staticTextBeginsWith(queryString, ignoreLeadingWhiteSpace: false)
    }

    func staticTextBeginsWith(_ queryString: String, ignoreLeadingWhiteSpace: Bool) -> XCUIElement {
        var predicate = NSPredicate(format: "label BEGINSWITH '"+queryString+"'")

        if ignoreLeadingWhiteSpace {
            predicate = NSPredicate(format: "label BEGINSWITH '"+queryString+"' OR label BEGINSWITH ' "+queryString+"'")
        }
        return self.staticTexts.element(matching: predicate)
    }

    func staticTextEquals(_ queryString: String, ignoreLeadingWhiteSpace: Bool) -> XCUIElement {
        var element = self.staticTexts[queryString]
        if element.exists || !ignoreLeadingWhiteSpace {
            return element
        }

        element = self.staticTexts[" " + queryString]
        if element.exists {
            return element
        }

        element = self.staticTexts[queryString + " "]
        if element.exists {
            return element
        }

        return self.staticTexts[" " + queryString + " "]
    }
}

extension XCUIElementQuery {
    func staticTextBeginsWith(_ queryString: String) -> XCUIElement {
        return staticTextBeginsWith(queryString, ignoreLeadingWhiteSpace: false)
    }

    func staticTextBeginsWith(_ queryString: String, ignoreLeadingWhiteSpace: Bool) -> XCUIElement {
        var predicate = NSPredicate(format: "label BEGINSWITH '"+queryString+"'")

        if ignoreLeadingWhiteSpace {
            predicate = NSPredicate(format: "label BEGINSWITH '"+queryString+"' OR label BEGINSWITH ' "+queryString+"'")
        }
        return self.staticTexts.element(matching: predicate)
    }

    func identifierTextBeginsWith(_ queryString: String) -> XCUIElementQuery {
        return self.containing(NSPredicate(format: "label BEGINSWITH '"+queryString+"'"))
    }

    func staticTextEquals(_ queryString: String, ignoreLeadingWhiteSpace: Bool) -> XCUIElement {
        var element = self.staticTexts[queryString]
        if element.exists || !ignoreLeadingWhiteSpace {
            return element
        }

        element = self.staticTexts[" " + queryString]
        if element.exists {
            return element
        }

        element = self.staticTexts[queryString + " "]
        if element.exists {
            return element
        }

        return self.staticTexts[" " + queryString + " "]
    }
}

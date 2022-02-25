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

extension Brick {

    @objc(xmlElementForBrickType: withContext:)
    func xmlElement(for brickType: String, with context: CBXMLSerializerContext) -> GDataXMLElement? {
        let indexOfBrick = CBXMLSerializerHelper.index(ofElement: self, in: context.brickList as? [Any])

        let brickTag = GDataXMLElement.init(name: "brick", xPathIndex: indexOfBrick + 1, context: context)

        if let typeAttribute = GDataXMLElement.attribute(withName: "type", stringValue: brickType) as? GDataXMLNode {
            brickTag?.addAttribute(typeAttribute)
        }

        let commentedOutTag = GDataXMLElement.element(withName: "commentedOut", stringValue: self.isDisabled ? "true" : "false")
        brickTag?.addChild(commentedOutTag)

        return brickTag
    }

}

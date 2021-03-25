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

extension SetLookBrick: CBXMLNodeProtocol {
    static func parse(from xmlElement: GDataXMLElement, with context: CBXMLParserContext) -> Self {

        let setLookBrick = self.init()
        let children = xmlElement.childrenWithoutCommentsAndCommentedOutTag() as Array
        if children.isEmpty {
            return setLookBrick
        }

        CBXMLParserHelper.validate(xmlElement, forNumberOfChildNodes: 1)

        let lookElement = children.first as? GDataXMLElement
        let lookList = context.spriteObject.lookList

        if CBXMLParserHelper.isReferenceElement(lookElement) {
            let referenceAttribute = lookElement?.attribute(forName: "reference")
            let xPath = referenceAttribute?.stringValue()
            guard let element = lookElement?.singleNode(forCatrobatXPath: xPath) else {
                fatalError("Invalid reference in SetLookBrick. No or too many looks found!")
            }
            guard let nameAttribute = element.attribute(forName: "name") else {
                fatalError("Look element does not contain a name attribute!")
            }
            setLookBrick.look = CBXMLParserHelper.findLook(in: lookList as? [Any], withName: nameAttribute.stringValue())
        } else {
            guard let look = context.parse(from: xmlElement, withClass: Look.self as? CBXMLNodeProtocol.Type) as? Look else {
                    fatalError("Unable to parse look...")
                }
            lookList?.add(look)
            setLookBrick.look = look
        }
        return setLookBrick
    }

    func xmlElement(with context: CBXMLSerializerContext) -> GDataXMLElement? {
        let brick = super.xmlElement(for: "SetLookBrick", with: context)

        if self.look != nil {
            if CBXMLSerializerHelper.index(ofElement: self.look, in: context.spriteObject.lookList as? [Any]) == NSNotFound {
                self.look = nil
            } else {
                let referenceXMLElement = GDataXMLElement.init(name: "look", context: context)
                let depthOfResource = CBXMLSerializerHelper.getDepthOfResource(self, for: context.spriteObject)
                let refPath = CBXMLSerializerHelper.relativeXPath(to: self.look, inLookList: context.spriteObject.lookList as? [Any], withDepth: depthOfResource)

                referenceXMLElement?.addAttribute(GDataXMLElement.attribute(withName: "reference", escapedStringValue: refPath) as? GDataXMLNode)
                brick?.addChild(referenceXMLElement, context: context)
            }
        }
        return brick
    }
}

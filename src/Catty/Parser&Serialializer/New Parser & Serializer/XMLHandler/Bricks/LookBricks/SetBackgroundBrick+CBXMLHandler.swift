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

extension SetBackgroundBrick: CBXMLNodeProtocol {
    static func parse(from xmlElement: GDataXMLElement, with context: CBXMLParserContext) -> Self {

        let setBackgroundBrick = self.init()
        let children = xmlElement.childrenWithoutCommentsAndCommentedOutTag() as Array
        if children.isEmpty {
            return setBackgroundBrick
        }

        CBXMLParserHelper.validate(xmlElement, forNumberOfChildNodes: 1)

        let lookElement = children.first as? GDataXMLElement
        let backgroundObject = context.spriteObjectList.firstObject as? SpriteObject
        let lookList = backgroundObject?.lookList

        if CBXMLParserHelper.isReferenceElement(lookElement) {
            let referenceAttribute = lookElement?.attribute(forName: "reference")
            let xPath = referenceAttribute?.stringValue()
            guard let element = lookElement?.singleNode(forCatrobatXPath: xPath) else {
                fatalError("Invalid reference in SetBackgroundBrick. No or too many looks found!")
            }
            guard let nameAttribute = element.attribute(forName: "name") else {
                fatalError("Look element does not contain a name attribute!")
            }
            setBackgroundBrick.look = CBXMLParserHelper.findLook(in: lookList as? [Any], withName: nameAttribute.stringValue())
        } else {
            guard let look = context.parse(from: xmlElement, withClass: Look.self as? CBXMLNodeProtocol.Type) as? Look else {
                    fatalError("Unable to parse look...")
                }
            lookList?.add(look)
            setBackgroundBrick.look = look
        }
        return setBackgroundBrick
    }

    func xmlElement(with context: CBXMLSerializerContext) -> GDataXMLElement? {
        let brick = super.xmlElement(for: "SetBackgroundBrick", with: context)
        let backgroundObject = self.script.object.scene.objects().first

        if self.look != nil {
            if CBXMLSerializerHelper.index(ofElement: self.look, in: backgroundObject?.lookList as? [Any]) == NSNotFound {
                self.look = nil
            } else {
                let referenceXMLElement = GDataXMLElement.init(name: "look", context: context)
                let depthOfResource = CBXMLSerializerHelper.getDepthOfResource(self, for: context.spriteObject)
                var refPath = ""
                if self.script.object == backgroundObject {
                    refPath = CBXMLSerializerHelper.relativeXPath(to: self.look, inLookList: backgroundObject?.lookList as? [Any], withDepth: depthOfResource)
                } else {
                    refPath = CBXMLSerializerHelper.relativeXPath(toBackground: self.look, forBackgroundObject: backgroundObject, withDepth: depthOfResource)
                }
                referenceXMLElement?.addAttribute(GDataXMLElement.attribute(withName: "reference", escapedStringValue: refPath) as? GDataXMLNode)
                brick?.addChild(referenceXMLElement, context: context)
            }
        }
        return brick
    }
}

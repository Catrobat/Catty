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

extension CloneBrick: CBXMLNodeProtocol {
    static func parse(from xmlElement: GDataXMLElement, with context: CBXMLParserContext) -> Self {
        let childCount = xmlElement.childrenWithoutCommentsAndCommentedOutTag().count
        if childCount > 1 {
            fatalError("Too many child nodes found... (0 or 1 expected, actual \(childCount)")
        }
        let cloneBrick = self.init()

        if childCount == 1 {
            CBXMLParserHelper.validate(xmlElement, forNumberOfChildNodes: 1)

            let objectToCloneElement = xmlElement.child(withElementName: "objectToClone")
            guard let _ = objectToCloneElement else {
                fatalError("No clonedObject element found...")
            }
            let newContext = context
            var spriteObject = newContext.parse(from: objectToCloneElement, withClass: SpriteObject.self) as! SpriteObject
            context.spriteObjectList = newContext.spriteObjectList
            context.clonedSpriteObjectList = newContext.clonedSpriteObjectList
            let alreadyExistantSpriteObject = CBXMLParserHelper.findSpriteObject(in: context.clonedSpriteObjectList as? [Any], withName: spriteObject.name)

            if alreadyExistantSpriteObject != nil {
                spriteObject = alreadyExistantSpriteObject!
            } else {
                context.clonedSpriteObjectList.add(spriteObject)
            }

            cloneBrick.objectToClone = spriteObject

        } else {
            cloneBrick.objectToClone = context.spriteObject
        }
        return cloneBrick
    }

    func xmlElement(with context: CBXMLSerializerContext) -> GDataXMLElement? {
        let brick = super.xmlElement(for: "CloneBrick", with: context)

        guard let _ = self.objectToClone else {
            fatalError("No sprite object given in CloneBrick")
        }

        guard let _ = self.script.object else {
            fatalError("Missing reference to brick's sprite object")
        }

        if self.objectToClone != self.script.object {
            let indexOfClonedObject = CBXMLSerializerHelper.index(ofElement: self.objectToClone, in: context.spriteObjectList as? [Any])
            let indexOfSpriteObject = CBXMLSerializerHelper.index(ofElement: self.script.object, in: context.spriteObjectList as? [Any])
            if indexOfClonedObject == Foundation.NSNotFound {
                fatalError("Cloned object does not exist in spriteObject list")
            }
            if indexOfSpriteObject == Foundation.NSNotFound {
                fatalError("Sprite object does not exist in spriteObject list")
            }

            let positionStackOfSpriteObject = context.spriteObjectNamePositions[self.objectToClone!.name as Any]
            if positionStackOfSpriteObject != nil {
                let clonedObjectXmlElement = GDataXMLElement.init(name: "objectToClone", context: context)
                let currentPositionStack = context.currentPositionStack

                let refPath = CBXMLSerializerHelper.relativeXPath(fromSourcePositionStack: currentPositionStack, toDestinationPositionStack: positionStackOfSpriteObject as? CBXMLPositionStack)

                clonedObjectXmlElement?.addAttribute(GDataXMLElement.attribute(withName: "reference", escapedStringValue: refPath) as? GDataXMLNode)
                brick?.addChild(clonedObjectXmlElement, context: context)

            } else {
                let newContext = context
                newContext.currentPositionStack = context.currentPositionStack
                let clonedObjectXmlElement = self.objectToClone?.xmlElement(with: newContext, asPointedObject: false, asGoToObject: false, asCloneOfObject: true)
                context.spriteObjectNamePositions = newContext.spriteObjectNamePositions
                context.spriteObjectNameUserVariableListPositions = newContext.spriteObjectNameUserVariableListPositions
                context.projectUserVariableNamePositions = newContext.projectUserVariableNamePositions
                context.projectUserListNamePositions = newContext.projectUserListNamePositions
                context.clonedSpriteObjectList = newContext.clonedSpriteObjectList
                brick?.addChild(clonedObjectXmlElement, context: context)
                context.clonedSpriteObjectList.add(self.objectToClone!)
            }
        }
        return brick
    }
}

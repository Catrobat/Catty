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

@objc extension UserVariable: CBXMLNodeProtocol {
    static func parse(from xmlElement: GDataXMLElement!, with context: CBXMLParserContext!) -> UserVariable {
        CBXMLValidator.exceptionIfNode(xmlElement, isNilOrNodeNameNotEquals: "userVariable")
        return self.parseUserVariable(xmlElement: xmlElement, with: context)
    }

    static func parseUserVariable(xmlElement: GDataXMLElement, with context: CBXMLParserContext) -> UserVariable {
        var returnElement = xmlElement

        if CBXMLParserHelper.isReferenceElement(returnElement) {
            guard let referenceAttribute = returnElement.attribute(forName: "reference") else {
                fatalError("No attribute for name: reference")
            }
            let xPath = referenceAttribute.stringValue()
            guard let returnElementSingleNode = returnElement.singleNode(forCatrobatXPath: xPath) else {
                fatalError("Invalid reference in UserVariable!")
            }
            returnElement = returnElementSingleNode
        }

        guard let userVariableName = returnElement.stringValue() else {
            fatalError("No name for user variable given.")
        }

        if let spriteObject = context.spriteObject {
            guard spriteObject.name != nil else {
                fatalError("Given spriteObject has no name.")
            }
            for userVariableToCompare in (spriteObject.userData.variables()) where userVariableToCompare.name == userVariableName {
                return userVariableToCompare
            }
        }

        guard let userVariable = CBXMLParserHelper.findUserVariable(in: context.programVariableList as? [UserVariable], withName: userVariableName) else {
            return UserVariable.init(name: userVariableName)
        }

        return userVariable
    }

    func xmlElement(with context: CBXMLSerializerContext) -> GDataXMLElement? {
        let xmlElement = GDataXMLElement.init(name: "userVariable", stringValue: self.name, context: context)
        guard let currentPositionsStack = context.currentPositionStack.mutableCopy() else {
            fatalError("MutableCopy() went wrong.")
        }

        var positionStackOfUserVariable: CBXMLPositionStack?

        if !context.project.userData.contains(self) {
            guard let spriteObjectName = context.spriteObject.name else {
                fatalError("The given spriteObject has no name specified.")
            }
            var alreadySerializedVarsOrLists: NSMutableDictionary? = context.spriteObjectNameUserVariableListPositions.object(forKey: spriteObjectName) as? NSMutableDictionary
            if let tempSerializedVarsOrLists = alreadySerializedVarsOrLists {
                positionStackOfUserVariable = tempSerializedVarsOrLists.object(forKey: self.name) as? CBXMLPositionStack
                if positionStackOfUserVariable != nil {
                    //already serialized
                    context.currentPositionStack.popXmlElementName()
                    guard let tempXmlElement = GDataXMLElement.init(name: "userVariable", context: context) else {
                        fatalError("Initialisation of user variable did not work.")
                    }
                    let refPath = CBXMLSerializerHelper.relativeXPath(fromSourcePositionStack: currentPositionsStack as? CBXMLPositionStack, toDestinationPositionStack: positionStackOfUserVariable)
                    tempXmlElement.addAttribute(GDataXMLElement.attribute(withName: "reference", escapedStringValue: refPath) as? GDataXMLNode)
                    return tempXmlElement
                }
            } else {
                let tempSerializedVarsOrLists = NSMutableDictionary.init()
                context.spriteObjectNameUserVariableListPositions.setObject(tempSerializedVarsOrLists, forKey: spriteObjectName as NSString)
                alreadySerializedVarsOrLists = tempSerializedVarsOrLists
            }
            guard let tempSerializedVarsOrLists = alreadySerializedVarsOrLists else {
                fatalError("Found nil")
            }
            tempSerializedVarsOrLists.setObject(currentPositionsStack, forKey: self.name as NSString)
            return xmlElement
        }

        positionStackOfUserVariable = context.projectUserVariableNamePositions.object(forKey: self.name) as? CBXMLPositionStack

        if positionStackOfUserVariable != nil {
            context.currentPositionStack.popXmlElementName()
            guard let tmpXmlElement = GDataXMLElement.init(name: "userVariable", context: context) else {
                fatalError("Error when creating xml element.")
            }
            let refPath = CBXMLSerializerHelper.relativeXPath(fromSourcePositionStack: currentPositionsStack as? CBXMLPositionStack, toDestinationPositionStack: positionStackOfUserVariable)
            tmpXmlElement.addAttribute(GDataXMLElement.attribute(withName: "reference", escapedStringValue: refPath) as? GDataXMLNode)
            return tmpXmlElement
        }

        context.projectUserVariableNamePositions.setObject(currentPositionsStack, forKey: self.name as NSString)
        return xmlElement
    }
}

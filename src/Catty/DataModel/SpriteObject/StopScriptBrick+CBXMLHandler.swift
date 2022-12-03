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

extension StopScriptBrick: CBXMLNodeProtocol {
   static func parse(from xmlElement: GDataXMLElement!, with context: CBXMLParserContext!) -> Self! {
       CBXMLParserHelper.validate(xmlElement, forNumberOfChildNodes: 1)
       let brick = self.init()

       let brickType = xmlElement.attribute(forName: "type")

       if brickType?.stringValue() == "StopScriptBrick" {
           if let selection: GDataXMLElement = xmlElement.child(withElementName: "selection") {
               if let choiceInt = Int(selection.stringValue()), let selection = StopStyle.from(rawValue: choiceInt) {
                   brick.selection = selection
               } else {
                   fatalError("No or invalid selectionChoice given...")
               }
           } else {
               fatalError("StopStyleBrick element does not contain a selection child element!")
           }
       } else {
           fatalError("StopStyleBrick is faulty!")
       }

       return brick
   }

   func xmlElement(with context: CBXMLSerializerContext) -> GDataXMLElement? {
       let brick = super.xmlElement(for: "StopScriptBrick", with: context)
       let numberString = String(format: "%i", arguments: [self.selection.rawValue])
       let selection = GDataXMLElement(name: "selection", stringValue: numberString, context: context)

       brick?.addChild(selection, context: context)
       return brick
  }
}

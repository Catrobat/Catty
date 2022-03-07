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

@objc extension CloneBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        .action { context in SKAction.run(self.actionBlock(context.formulaInterpreter)) }
    }

    func actionBlock(_ formulaInterpreter: FormulaInterpreterProtocol) -> () -> Void {
        guard let objectToClone = self.objectToClone
            else { fatalError("This should never happen!") }

        return {
            let object = SpriteObject()
            object.name = objectToClone.name + "Clone " + String(CloneBrick.nameCounter)
            CloneBrick.nameCounter += 1

            guard let scriptList = objectToClone.scriptList as NSMutableArray? as? [Script] else {
                //fatalError
                debugPrint("!! No script list given in object: \(objectToClone) !!")
                return
            }

            let context = CBMutableCopyContext()
            let variables = objectToClone.userData.variables()
            let lists = objectToClone.userData.lists()

            for variable in variables {
                let var1 = UserVariable(name: variable.name)
                let label = SKLabelNode(fontNamed: SpriteKitDefines.defaultFont)
                var1.value = variable.value
                var1.textLabel = label

                let value = variable.value as! Int? ?? 0
                var1.textLabel?.text = String(value)
                var1.textLabel?.fontColor = variable.textLabel?.fontColor ?? UIColor.black
                var1.textLabel?.fontSize = variable.textLabel?.fontSize ?? CGFloat(SpriteKitDefines.defaultLabelFontSize)
                var1.textLabel?.position = variable.textLabel?.position ?? CGPoint(x: 0, y: 0)
                var1.textLabel?.isHidden = variable.textLabel?.isHidden ?? true
                object.userData.add(var1)
            }

            for list in lists {
                let list1 = list.mutableCopy(with: context) as! UserList
                object.userData.add(list1)
            }

            for script in scriptList {
                let newScript = script.clone(with: object)!
                self.setScriptAttributes(script: newScript, oldScript: script)
                for brick in script.brickList {
                    let brickToClone = brick as! Brick
                    let newBrick = brickToClone.clone(with: newScript)!
                    self.setBrickAttributes(brick: newBrick, oldBrick: brickToClone)
                    newScript.brickList.add(newBrick)
                }
                object.scriptList.add(newScript)
            }

            object.soundList = objectToClone.soundList.mutableCopy() as? NSMutableArray
            object.lookList = objectToClone.lookList.mutableCopy() as? NSMutableArray

            objectToClone.scene.add(object: object)
            let spriteNode = CBSpriteNode(spriteObject: object)
            object.spriteNode = spriteNode

            let stage = objectToClone.spriteNode.scene as? Stage
            stage?.addChild(object.spriteNode)
            object.spriteNode.startAsClone(objectToClone.spriteNode)
            stage?.scheduler.registerSpriteNode(object.spriteNode)
            stage?.addClonedObjecToProject(spriteObject: object)
        }
    }

    func setBrickAttributes(brick: Brick, oldBrick: Brick) {
        brick.isDisabled = oldBrick.isDisabled
        brick.isSelected = oldBrick.isSelected
        brick.isAnimatedMoveBrick = oldBrick.isAnimatedMoveBrick
        brick.isAnimatedInsertBrick = oldBrick.isAnimatedInsertBrick
        brick.isAnimated = oldBrick.isAnimated
    }

    func setScriptAttributes(script: Script, oldScript: Script) {
        script.isDisabled = oldScript.isDisabled
        script.isSelected = oldScript.isSelected
        script.isAnimatedMoveBrick = oldScript.isAnimatedMoveBrick
        script.isAnimatedInsertBrick = oldScript.isAnimatedInsertBrick
        script.isAnimated = oldScript.isAnimated
    }
}

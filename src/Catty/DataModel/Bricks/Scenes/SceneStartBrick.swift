/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

//TODO adjust this file 
// TODO allow new scenes to be created within the scenes picker
// TODO if one scene gets deleted adjust the scene start brick

@objc(SceneStartBrick)
@objcMembers class SceneStartBrick: Brick, BrickProtocol, BrickSceneProtocol {

    func setScene(_ scene: Scene!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        if scene != nil {
            self.selectedScene = scene
        }
    }

    func scene(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Scene! {
        self.selectedScene
    }

    @objc var selectedScene: Scene?

//    override required init() {
//        super.init()
//    }

    override required init() {

    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.controlBrick
    }

    override class func description() -> String {
        "SceneStartBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        SceneStartBrickCell.self as BrickCellProtocol.Type
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {

        self.selectedScene = (ProjectManager.shared.currentProject.scenes.firstObject as! Scene)
    }

    func allowsStringFormula() -> Bool {
        true
    }

    override func isDisabledForBackground() -> Bool {
        false
    }
}

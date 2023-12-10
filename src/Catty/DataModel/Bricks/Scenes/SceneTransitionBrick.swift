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

@objc(SceneTransitionBrick)
@objcMembers class SceneTransitionBrick: Brick, BrickProtocol, BrickSceneProtocol {
    func sceneName() -> String! {
        selectedSceneName
    }

    func setScene(_ scene: Scene!) {
        if scene != nil {
            self.selectedScene = scene
            self.selectedSceneName = scene.name
        }
    }

    func scene(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Scene! {
        self.selectedScene
    }

    @objc var selectedScene: Scene?

    @objc var selectedSceneName: String?

    override required init() {
        super.init()
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.controlBrick
    }

    override class func description() -> String {
        "SceneTransitionBrick"
    }

    override func getRequiredResources() -> Int {
        ResourceType.noResources.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        SceneTransitionBrickCell.self as BrickCellProtocol.Type
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.selectedScene = (ProjectManager.shared.currentProject.scenes.firstObject as! Scene)
        self.selectedSceneName = selectedScene?.name
    }

    func allowsStringFormula() -> Bool {
        true
    }

    override func isDisabledForBackground() -> Bool {
        false
    }
}


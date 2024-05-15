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

class BrickCellScenesStartBrickData: iOSCombobox, BrickCellDataProtocol, iOSComboboxDelegate {

    var brickCell: BrickCell
    var lineNumber: Int
    var parameterNumber: Int

    override var isUserInteractionEnabled: Bool {
        get { self.brickCell.scriptOrBrick.isAnimatedInsertBrick == false }
        set { }
    }

    required init?(frame: CGRect, andBrickCell brickCell: BrickCell, andLineNumber line: Int, andParameterNumber parameter: Int) {
        self.brickCell = brickCell
        self.lineNumber = line
        self.parameterNumber = parameter

        super.init(frame: frame)

        var backgroundOptions: [String] = []
        var currentOptionIndex = 0

        var currentScene = (brickCell.scriptOrBrick as? BrickSceneProtocol)?.scene(forLineNumber: line, andParameterNumber: parameter)

        let selectedScenename = (brickCell.scriptOrBrick as? BrickSceneProtocol)?.sceneName()

        // this is just because we can't set our scene when parsing because the scene probably is not parsed yet, mabye remove the Scene Object cmplety and load it only when neeeded or find a better solution

        if currentScene?.name != selectedScenename {
            let scenes = ProjectManager.shared.currentProject.scenes.map { $0 as! Scene }
            currentScene = scenes.first { $0.name == selectedScenename }
            (brickCell.scriptOrBrick as? BrickSceneProtocol)?.setScene(currentScene)
        }

        for case let scene as Scene in ProjectManager.shared.currentProject.scenes {
            backgroundOptions.append(scene.name)

            if selectedScenename == scene.name {
                currentOptionIndex = backgroundOptions.count - 1
            }

            self.setNeedsDisplay()
        }

        self.values = backgroundOptions
        self.currentValue = backgroundOptions[currentOptionIndex]
        self.delegate = self
        self.accessibilityLabel = UIDefines.backgroundPickerAccessibilityLabel + "_" + self.currentValue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func comboboxDonePressed(_ combobox: iOSCombobox, withValue value: String) {
        self.brickCell.dataDelegate.updateBrickCellData(self, withValue: value)
    }

    func comboboxCancelPressed(_ combobox: iOSCombobox, withValue value: String) {
        self.brickCell.dataDelegate.enableUserInteractionAndResetHighlight()
    }

    func comboboxOpened(_ combobox: iOSCombobox!) {
        self.brickCell.dataDelegate.disableUserInteractionAndHighlight(self.brickCell, withMarginBottom: CGFloat(kiOSComboboxTotalHeight))
    }
}

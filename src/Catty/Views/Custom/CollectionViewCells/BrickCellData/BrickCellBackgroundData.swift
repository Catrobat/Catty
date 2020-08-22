/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class BrickCellBackgroundData: iOSCombobox, BrickCellDataProtocol, iOSComboboxDelegate {

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

        var backgroundOptions = [ kLocalizedNewElement ]
        var currentOptionIndex = 0

        if !brickCell.isInserting {
            guard let brick = brickCell.scriptOrBrick as? Brick, let script = brick.script, let backgroundObject = script.object.scene.objects().first else { return }

            let currentLook = (brickCell.scriptOrBrick as? BrickLookProtocol)?.look(forLineNumber: line, andParameterNumber: parameter)
            self.object = backgroundObject

            for case let look as Look in backgroundObject.lookList {
                backgroundOptions.append(look.name)

                if currentLook?.name == look.name && self.currentImage == nil {
                    self.setCurrentLook(look, for: backgroundObject)
                    currentOptionIndex = backgroundOptions.count - 1
                }
            }

            self.setNeedsDisplay()
        }

        self.values = backgroundOptions
        self.currentValue = backgroundOptions[currentOptionIndex]
        self.delegate = self
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

    private func setCurrentLook(_ look: Look, for object: SpriteObject) {
        let imageCache = RuntimeImageCache.shared()
        let path = object.projectPath() + kProjectImagesDirName + "/" + look.fileName

        if let image = imageCache?.cachedImage(forPath: path) {
            self.currentImage = image
        } else {
            imageCache?.loadImageFromDisk(withPath: path, onCompletion: { image, _ in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    self.currentImage = image
                    self.setNeedsDisplay()
                }
            })
        }
    }
}

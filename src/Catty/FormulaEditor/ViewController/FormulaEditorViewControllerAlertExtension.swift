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

extension FormulaEditorViewController {

    @objc func showComputeDialog(_ formula: Formula, andSpriteObject spriteObject: SpriteObject) {

        self.formulaManager.setup(for: formula)

        let computedString = self.interpretFormula(formula, for: spriteObject)

        self.computeDialog = UIAlertController(title: computedString, message: nil, preferredStyle: .alert)
        self.computeDialog.view.tintColor = UIColor.medium

        self.dialogUpdateTimer = Timer.scheduledTimer(withTimeInterval: UIDefines.formulaEditorComputeRefreshInterval, repeats: true, block: { _ in
            self.formulaManager.setup(for: formula)
            let computedString = self.interpretFormula(formula, for: spriteObject)
            self.computeDialog.title = computedString
        })

        let dismissAction = UIAlertAction(title: kLocalizedClose, style: .cancel) { _ in
            self.dialogUpdateTimer.invalidate()
            self.formulaManager.stop()
        }

        self.computeDialog.addAction(dismissAction)

        UIApplication.shared.windows.last?.rootViewController?.present(computeDialog, animated: true, completion: nil)

    }

    @objc func showSyntaxErrorView() {

        self.computeDialog = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        self.computeDialog.view.tintColor = UIColor.medium
        let okAction = UIAlertAction(title: kLocalizedOK, style: .cancel, handler: nil)
        self.computeDialog.addAction(okAction)

        if self.internFormula != nil && self.internFormula.isEmpty() {
            self.computeDialog.title = kUIFEEmptyInput
        } else {
            self.computeDialog.title = kUIFESyntaxError
            self.setParseErrorCursorAndSelection()
        }

        UIApplication.shared.windows.last?.rootViewController?.present(self.computeDialog, animated: true, completion: nil)
    }

    @objc func showFormulaTooLongView() {

        self.computeDialog = UIAlertController(title: kUIFEtooLongFormula, message: nil, preferredStyle: .alert)
        self.computeDialog.view.tintColor = UIColor.medium
        let okAction = UIAlertAction(title: kLocalizedOK, style: .cancel, handler: nil)
        self.computeDialog.addAction(okAction)

        UIApplication.shared.windows.last?.rootViewController?.present(self.computeDialog, animated: true, completion: nil)

    }

}

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

import UIKit

@objc class FormulaEditorKeyboardAccessoryView: UIView, FormulaEditorKeyboardViewProtocol {

    static var height: CGFloat { 2 * (FormulaEditorKeyboardAccessoryView.buttonHeight + FormulaEditorKeyboardView.padding) }

    @objc var functionsButton = LargeButton(title: kUIFEFunctions)
    @objc var propertiesButton = LargeButton(title: kUIFEProperties)
    @objc var sensorsButton = LargeButton(title: kUIFESensor)
    @objc var logicButton = LargeButton(title: kUIFELogic)
    @objc var dataButton = LargeButton(title: kUIFEData)

    @objc init(keyboardWidth: CGFloat) {
        let frame: CGRect

        frame = CGRect(origin: .zero, size: CGSize(width: keyboardWidth, height: FormulaEditorKeyboardAccessoryView.height))
        super.init(frame: frame)
        self.backgroundColor = UIColor.white

        self.setupKeyboardAccessoryViewLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupKeyboardAccessoryViewLayout() {
        let smallWidth = (self.frame.width - 7 * FormulaEditorKeyboardView.padding) / 6
        let mediumWidth = smallWidth * 2 + FormulaEditorKeyboardView.padding
        let largeWidth = smallWidth * 3 + FormulaEditorKeyboardView.padding * 2
        let height = FormulaEditorKeyboardAccessoryView.buttonHeight

        self.addSubview(self.functionsButton)
        self.addSubview(self.propertiesButton)
        self.addSubview(self.sensorsButton)
        self.addSubview(self.logicButton)
        self.addSubview(self.dataButton)

        self.functionsButton.translatesAutoresizingMaskIntoConstraints = false
        self.propertiesButton.translatesAutoresizingMaskIntoConstraints = false
        self.sensorsButton.translatesAutoresizingMaskIntoConstraints = false
        self.logicButton.translatesAutoresizingMaskIntoConstraints = false
        self.dataButton.translatesAutoresizingMaskIntoConstraints = false

        // Row 1
        self.functionsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.functionsButton.topAnchor.constraint(equalTo: self.topAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.functionsButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.functionsButton.widthAnchor.constraint(equalToConstant: largeWidth).isActive = true

        self.propertiesButton.topAnchor.constraint(equalTo: self.topAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.propertiesButton.leadingAnchor.constraint(equalTo: self.functionsButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.propertiesButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.propertiesButton.widthAnchor.constraint(equalToConstant: largeWidth).isActive = true

        // Row 2
        self.sensorsButton.topAnchor.constraint(equalTo: self.functionsButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.sensorsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.sensorsButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.sensorsButton.widthAnchor.constraint(equalToConstant: mediumWidth).isActive = true

        self.logicButton.leadingAnchor.constraint(equalTo: self.sensorsButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.logicButton.topAnchor.constraint(equalTo: self.functionsButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.logicButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.logicButton.widthAnchor.constraint(equalToConstant: mediumWidth).isActive = true

        self.dataButton.leadingAnchor.constraint(equalTo: self.logicButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.dataButton.topAnchor.constraint(equalTo: self.propertiesButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.dataButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.dataButton.widthAnchor.constraint(equalToConstant: mediumWidth).isActive = true
    }

}

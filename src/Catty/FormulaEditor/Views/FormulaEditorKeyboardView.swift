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

import UIKit

protocol FormulaEditorKeyboardViewProtocol {
    static var keyboardHeight: CGFloat { get }
    static var buttonHeight: CGFloat { get }
    var buttonWidth: CGFloat { get }
}

@objc class FormulaEditorKeyboardView: UIView, FormulaEditorKeyboardViewProtocol {

    static let padding = CGFloat(1)
    static let baseHeight = CGFloat(325)
    static let minimumHeightOffsetCenter = CGFloat(20)

    @objc var sectionButtonsHidden = false
    @objc var computeButton = LargeButton(title: kUIFECompute)

    @objc var arrowButton = ArrowButton()
    @objc var backspaceButton = BackspaceButton()

    @objc var textButton = OperatorButton(symbol: kUIFEAddNewText)
    @objc var equalsButton = OperatorButton(symbol: "=")
    @objc var subtractionButton = OperatorButton(symbol: "-")
    @objc var additionButton = OperatorButton(symbol: "+")
    @objc var divisionButton = OperatorButton(symbol: "/")
    @objc var multiplicationButton = OperatorButton(symbol: "x")
    @objc var openingBracketButton = OperatorButton(symbol: "(")
    @objc var closingBracketButton = OperatorButton(symbol: ")")
    @objc var decimalPointButton = OperatorButton(symbol: ".")

    @objc var numericButtons: [NumericButton] = {
        var numericButtons = [NumericButton]()
        for i in 0...9 {
            numericButtons.append(NumericButton(number: i))
        }
        return numericButtons
    }()

    @objc init(keyboardWidth: CGFloat) {
        let frame: CGRect
        let accessoryViewHeight = FormulaEditorKeyboardAccessoryView.height
        let inputViewHeight = FormulaEditorKeyboardView.keyboardHeight - accessoryViewHeight

        let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        frame = CGRect(origin: .zero, size: CGSize(width: keyboardWidth, height: inputViewHeight + bottomInset))

        super.init(frame: frame)
        self.backgroundColor = UIColor.white

        self.setupKeyboardLayout()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func animateArrowButton() {
        self.sectionButtonsHidden.toggle()

        let animations: (() -> Void) = {
            let angle = self.sectionButtonsHidden ? CGFloat(Float.pi) : CGFloat(-Float.pi)
            self.arrowButton.transform = self.arrowButton.transform.rotated(by: angle)
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: animations, completion: nil)
    }

    private func setupKeyboardLayout() {
        let smallWidth = self.buttonWidth
        let mediumWidth = smallWidth * 2 + FormulaEditorKeyboardView.padding
        let height = FormulaEditorKeyboardView.buttonHeight

        self.addSubview(self.arrowButton)
        self.addSubview(self.backspaceButton)
        self.addSubview(self.textButton)
        self.addSubview(self.divisionButton)
        self.addSubview(self.multiplicationButton)
        self.addSubview(self.equalsButton)
        self.addSubview(self.subtractionButton)
        self.addSubview(self.additionButton)
        self.addSubview(self.openingBracketButton)
        self.addSubview(self.closingBracketButton)
        self.addSubview(self.decimalPointButton)
        self.addSubview(self.computeButton)

        self.arrowButton.translatesAutoresizingMaskIntoConstraints = false
        self.backspaceButton.translatesAutoresizingMaskIntoConstraints = false
        self.textButton.translatesAutoresizingMaskIntoConstraints = false
        self.divisionButton.translatesAutoresizingMaskIntoConstraints = false
        self.multiplicationButton.translatesAutoresizingMaskIntoConstraints = false
        self.equalsButton.translatesAutoresizingMaskIntoConstraints = false
        self.subtractionButton.translatesAutoresizingMaskIntoConstraints = false
        self.additionButton.translatesAutoresizingMaskIntoConstraints = false
        self.openingBracketButton.translatesAutoresizingMaskIntoConstraints = false
        self.closingBracketButton.translatesAutoresizingMaskIntoConstraints = false
        self.decimalPointButton.translatesAutoresizingMaskIntoConstraints = false
        self.computeButton.translatesAutoresizingMaskIntoConstraints = false

        self.backspaceButton.accessibilityIdentifier = "backspaceButton"
        self.arrowButton.accessibilityIdentifier = "arrowButton"

        for index in 0...9 {
            self.addSubview(numericButtons[index])
            numericButtons[index].translatesAutoresizingMaskIntoConstraints = false
            self.numericButtons[index].heightAnchor.constraint(equalToConstant: height).isActive = true
            self.numericButtons[index].widthAnchor.constraint(equalToConstant: smallWidth).isActive = true
        }

        // Row 3
        self.arrowButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.arrowButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.arrowButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true
        self.arrowButton.topAnchor.constraint(equalTo: self.topAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.numericButtons[7].leadingAnchor.constraint(equalTo: self.arrowButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[7].topAnchor.constraint(equalTo: self.topAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.numericButtons[8].leadingAnchor.constraint(equalTo: self.numericButtons[7].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[8].topAnchor.constraint(equalTo: self.topAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.numericButtons[9].leadingAnchor.constraint(equalTo: self.numericButtons[8].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[9].topAnchor.constraint(equalTo: self.topAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.backspaceButton.leadingAnchor.constraint(equalTo: self.numericButtons[9].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.backspaceButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.backspaceButton.widthAnchor.constraint(equalToConstant: mediumWidth).isActive = true
        self.backspaceButton.topAnchor.constraint(equalTo: self.topAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        //Row 4
        self.textButton.topAnchor.constraint(equalTo: self.arrowButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.textButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.textButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.textButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.numericButtons[4].leadingAnchor.constraint(equalTo: self.textButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[4].topAnchor.constraint(equalTo: self.numericButtons[7].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.numericButtons[5].leadingAnchor.constraint(equalTo: self.numericButtons[4].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[5].topAnchor.constraint(equalTo: self.numericButtons[8].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.numericButtons[6].leadingAnchor.constraint(equalTo: self.numericButtons[5].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[6].topAnchor.constraint(equalTo: self.numericButtons[9].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.divisionButton.leadingAnchor.constraint(equalTo: self.numericButtons[6].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.divisionButton.topAnchor.constraint(equalTo: self.backspaceButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.divisionButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.divisionButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.multiplicationButton.leadingAnchor.constraint(equalTo: self.divisionButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.multiplicationButton.topAnchor.constraint(equalTo: self.backspaceButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.multiplicationButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.multiplicationButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        // Row 5
        self.equalsButton.topAnchor.constraint(equalTo: self.textButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.equalsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.equalsButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.equalsButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.numericButtons[1].leadingAnchor.constraint(equalTo: self.textButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[1].topAnchor.constraint(equalTo: self.numericButtons[4].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.numericButtons[2].leadingAnchor.constraint(equalTo: self.numericButtons[1].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[2].topAnchor.constraint(equalTo: self.numericButtons[5].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.numericButtons[3].leadingAnchor.constraint(equalTo: self.numericButtons[2].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[3].topAnchor.constraint(equalTo: self.numericButtons[6].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true

        self.subtractionButton.leadingAnchor.constraint(equalTo: self.numericButtons[3].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.subtractionButton.topAnchor.constraint(equalTo: self.divisionButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.subtractionButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.subtractionButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.additionButton.leadingAnchor.constraint(equalTo: self.subtractionButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.additionButton.topAnchor.constraint(equalTo: self.multiplicationButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.additionButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.additionButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        // Row 6
        self.openingBracketButton.topAnchor.constraint(equalTo: self.equalsButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.openingBracketButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.openingBracketButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.openingBracketButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.closingBracketButton.topAnchor.constraint(equalTo: self.numericButtons[1].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.closingBracketButton.leadingAnchor.constraint(equalTo: self.openingBracketButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.closingBracketButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.closingBracketButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.numericButtons[0].leadingAnchor.constraint(equalTo: self.closingBracketButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[0].topAnchor.constraint(equalTo: self.numericButtons[2].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.numericButtons[0].widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.decimalPointButton.topAnchor.constraint(equalTo: self.numericButtons[3].bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.decimalPointButton.leadingAnchor.constraint(equalTo: self.numericButtons[0].trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.decimalPointButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.decimalPointButton.widthAnchor.constraint(equalToConstant: smallWidth).isActive = true

        self.computeButton.leadingAnchor.constraint(equalTo: self.decimalPointButton.trailingAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.computeButton.topAnchor.constraint(equalTo: self.additionButton.bottomAnchor, constant: FormulaEditorKeyboardView.padding).isActive = true
        self.computeButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.computeButton.widthAnchor.constraint(equalToConstant: mediumWidth).isActive = true
    }
}

extension FormulaEditorKeyboardViewProtocol where Self: UIView {
    static var keyboardHeight: CGFloat {
        let halfScreenHeight = (Util.screenHeight() - Util.statusBarHeight() - FormulaEditorKeyboardView.minimumHeightOffsetCenter) / 2

        if FormulaEditorKeyboardView.baseHeight > halfScreenHeight {
            return halfScreenHeight
        }
        return FormulaEditorKeyboardView.baseHeight
    }

    static var buttonHeight: CGFloat { (self.keyboardHeight - 7 * FormulaEditorKeyboardView.padding) / 6 }

    var buttonWidth: CGFloat { (self.frame.size.width - 7 * FormulaEditorKeyboardView.padding) / 6 }
}

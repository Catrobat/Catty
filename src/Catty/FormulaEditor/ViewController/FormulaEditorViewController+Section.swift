/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

    @objc func initMathSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForMathSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight)
    }

    @objc func initLogicSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForLogicSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight)
    }

    @objc func initObjectSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForObjectSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight)
    }

    @objc func initSensorSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForDeviceSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight)
    }

    private func initWithItems(formulaEditorItems: [FormulaEditorItem], scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        var topAnchorView: UIView?
        var buttons = [UIButton]()

        for item in formulaEditorItems {
            let button = FormulaEditorButton(formulaEditorItem: item)
            topAnchorView = addButtonToScrollView(button: button, scrollView: scrollView, topAnchorView: topAnchorView, buttonHeight: buttonHeight)
            buttons.append(topAnchorView as! UIButton)
        }

        resizeSection(scrollView: scrollView, for: buttons, with: buttonHeight)
        return buttons
    }

    @objc func buttonPressed(sender: UIButton) {
        if let button = sender as? FormulaEditorButton {
            if let sensor = button.sensor {
                self.handleInput(for: sensor)
            } else if let function = button.function {
                self.handleInput(for: function)
            }
        }
    }

    private func addButtonToScrollView(button: FormulaEditorButton, scrollView: UIScrollView, topAnchorView: UIView?, buttonHeight: CGFloat) -> UIButton {
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)

        scrollView.addSubview(button)
        if topAnchorView == nil {
            button.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        } else {
            button.topAnchor.constraint(equalTo: (topAnchorView?.bottomAnchor)!, constant: 0).isActive = true
        }

        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true

        return button
    }

    private func resizeSection(scrollView: UIScrollView, for buttons: [UIButton], with buttonHeight: CGFloat) {
        scrollView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y, width: scrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
    }

    private func handleInput(for sensor: Sensor) {
        self.internFormula.handleKeyInput(for: sensor)
        self.handleInput()
    }

    private func handleInput(for function: Function) {
        self.internFormula.handleKeyInput(for: function)
        self.handleInput()
    }

    private func handleInput(for op: CBOperator) {
        self.internFormula.handleKeyInput(for: op)
        self.handleInput()
    }
}

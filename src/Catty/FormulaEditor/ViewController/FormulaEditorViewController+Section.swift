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

extension FormulaEditorViewController {

    @objc func initMathSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForMathSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight, fullButtonWidth: true)
    }

    @objc func initLogicSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForLogicSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight, fullButtonWidth: false)
    }

    @objc func initObjectSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForObjectSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight, fullButtonWidth: true)
    }

    @objc func initSensorSection(scrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        let items = formulaManager.formulaEditorItemsForDeviceSection(spriteObject: object)
        return initWithItems(formulaEditorItems: items, scrollView: scrollView, buttonHeight: buttonHeight, fullButtonWidth: true)
    }

    private func initWithItems(formulaEditorItems: [FormulaEditorItem], scrollView: UIScrollView, buttonHeight: CGFloat, fullButtonWidth: Bool) -> [UIButton] {
        var button: UIButton?
        var buttons = [UIButton]()

        for item in formulaEditorItems {
            button = buttonForScrollView(item: item, scrollView: scrollView, previousButton: button, buttonHeight: buttonHeight, fullButtonWidth: fullButtonWidth)
            buttons.append(button!)
        }

        resizeSection(scrollView: scrollView, for: buttons, with: buttonHeight, fullButtonWidth: fullButtonWidth)
        return buttons
    }

    @objc func buttonPressed(sender: UIButton) {
        if let button = sender as? FormulaEditorButton {
            if let sensor = button.sensor {
                handleInput(for: sensor)
            } else if let function = button.function {
                handleInput(for: function)
            } else if let op = button.op {
                handleInput(for: op)
            }
        }
    }

    @objc func divisionButtonPressed() {
        guard let op = formulaManager.getOperator(tag: DivideOperator.tag) else { return }
        handleInput(for: op)
    }

    @objc func multiplicationButtonPressed() {
        guard let op = formulaManager.getOperator(tag: MultOperator.tag) else { return }
        handleInput(for: op)
    }

    @objc func substractionButtonPressed() {
        guard let op = formulaManager.getOperator(tag: MinusOperator.tag) else { return }
        handleInput(for: op)
    }

    @objc func additionButtonPressed() {
        guard let op = formulaManager.getOperator(tag: PlusOperator.tag) else { return }
        handleInput(for: op)
    }

    private func buttonForScrollView(item: FormulaEditorItem, scrollView: UIScrollView, previousButton: UIButton?, buttonHeight: CGFloat, fullButtonWidth: Bool) -> UIButton {
        let button = FormulaEditorButton(formulaEditorItem: item)
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        scrollView.addSubview(button)

        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: fullButtonWidth ? 1.0 : 0.5).isActive = true

        let oddButton = scrollView.subviews.filter { $0 is FormulaEditorButton }.count % 2 != 0

        if fullButtonWidth || oddButton {
            button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
            button.topAnchor.constraint(equalTo: previousButton?.bottomAnchor ?? scrollView.topAnchor, constant: 0).isActive = true
        } else if let topAnchorView = previousButton {
            button.leftAnchor.constraint(equalTo: topAnchorView.rightAnchor, constant: 0).isActive = true
            button.topAnchor.constraint(equalTo: topAnchorView.topAnchor, constant: 0).isActive = true
        }

        return button
    }

    private func resizeSection(scrollView: UIScrollView, for buttons: [UIButton], with buttonHeight: CGFloat, fullButtonWidth: Bool) {
        let height = CGFloat(ceil(Double(buttons.count) / (fullButtonWidth ? 1 : 2))) * buttonHeight
        scrollView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y, width: scrollView.frame.size.width, height: height)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: height)
    }

    private func handleInput(for sensor: Sensor) {
        self.internFormula.handleKeyInput(for: sensor)
        self.handleInput()
    }

    private func handleInput(for function: Function) {
        self.internFormula.handleKeyInput(for: function)
        self.handleInput()
    }

    private func handleInput(for op: Operator) {
        self.internFormula.handleKeyInput(for: op)
        self.handleInput()
    }
}

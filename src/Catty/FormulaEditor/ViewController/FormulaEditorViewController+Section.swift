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

    func formulaEditorItemSelected(item: FormulaEditorItem) {

        if let sensor = item.sensor {
            handleInput(for: sensor)
        } else if let function = item.function {
            handleInput(for: function)
        } else if let op = item.op {
            handleInput(for: op)
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

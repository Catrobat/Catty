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

class FormulaEditorKeyboardButton: UIButton {

    private let touchDownAlpha = CGFloat(0.6)
    private let cornerRadius = CGFloat(15)

    init(touchDownFeedback: Bool = true) {
        super.init(frame: CGRect.zero)
        self.layer.cornerRadius = cornerRadius

        if touchDownFeedback {
            self.addTarget(self, action: #selector(tapFeedbackIn), for: .touchDown)
            self.addTarget(self, action: #selector(tapFeedbackOut), for: .touchUpInside)
            self.addTarget(self, action: #selector(tapFeedbackOut), for: .touchUpOutside)
            self.addTarget(self, action: #selector(tapFeedbackOut), for: .touchCancel)
            self.addTarget(self, action: #selector(tapFeedbackOut), for: .touchDragExit)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapFeedbackIn() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(self.touchDownAlpha)
        })

    }

    @objc func tapFeedbackOut() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
        })
    }
}

class NumericButton: FormulaEditorKeyboardButton {

    var number = Int()

    init(number: Int) {
        super.init()
        self.number = number
        self.backgroundColor = .formulaEditorNumericButtons
        self.setTitle("\(number)", for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.tag = number + 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LargeButton: FormulaEditorKeyboardButton {

    init(title: String) {
        super.init(touchDownFeedback: false)
        self.backgroundColor = .formulaEditorLargeButtons
        self.setTitle(title, for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class OperatorButton: FormulaEditorKeyboardButton {

    init(symbol: String) {
        super.init()
        self.backgroundColor = .formulaEditorOperatorButtons
        self.setTitle(symbol, for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true

        if symbol == "." {
            self.tag = Int(TOKEN_TYPE_DECIMAL_MARK.rawValue)
        } else if symbol == "(" {
            self.tag = Int(BRACKET_OPEN.rawValue)
        } else if symbol == ")" {
            self.tag = Int(BRACKET_CLOSE.rawValue)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BackspaceButton: FormulaEditorKeyboardButton {

    init() {
        super.init()
        self.backgroundColor = .formulaEditorOperatorButtons
        let image = UIImage(named: "backspaceButton")?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ArrowButton: FormulaEditorKeyboardButton {

    init() {
        super.init(touchDownFeedback: false)
        self.backgroundColor = .formulaEditorLargeButtons
        let image = UIImage(named: "formulaEditorArrow")
        self.setImage(image, for: .normal)
        self.tintColor = UIColor.white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

import Foundation

@objc(WhenConditionScript)
class WhenConditionScript: Script, BrickFormulaProtocol {
    @objc var condition: Formula
    @objc var preCondition: Bool

    init(condition: Formula) {
        self.condition = condition
        self.preCondition = false
        super.init()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public required init() {
        self.condition = Formula(integer: 1)
        self.preCondition = false
        super.init()
    }

    public func category() -> kBrickCategoryType {
        kBrickCategoryType.eventBrick
    }

    override func isAnimateable() -> Bool {
        true
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.condition
    }

    func getFormulas() -> [Formula]! {
        [self.condition]
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.condition = formula
    }

    func allowsStringFormula() -> Bool {
        false
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.condition = Formula(integer: 1)
    }

    override func description() -> String {
        String(format: "WhenConditionScript (Formula: %@)", self.condition.getDisplayString())
    }

    override func getRequiredResources() -> Int {
        self.condition.getRequiredResources()
    }

    @objc(mutableCopyWithContext:)
    override func mutableCopy(with context: CBMutableCopyContext!) -> Any! {
        guard context != nil else { fatalError("\(CBMutableCopyContext.Type.self)/" + " must not be nil!") }

        let brick = WhenConditionScript.init()
        brick.condition = self.condition
        let updatedReference = context.updatedReference(forReference: self.condition)

        if updatedReference != nil {
            guard let updatedFormula = updatedReference as? Formula else { return brick }
            brick.condition = updatedFormula
        }

        return brick
    }
}

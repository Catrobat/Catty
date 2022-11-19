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

@objc(WebRequestBrick)
@objcMembers class WebRequestBrick: Brick, BrickProtocol, BrickFormulaProtocol, BrickVariableProtocol {

    var request: Formula?
    var userVariable: UserVariable?
    var downloaderFactory: WebRequestDownloaderFactory
    var alertControllerBuilder: AlertControllerBuilderProtocol

    override required init() {
        self.downloaderFactory = WebRequestDownloaderFactory()
        self.alertControllerBuilder = AlertControllerBuilder()
        super.init()
    }

    convenience init(request: Formula, userVariable: UserVariable, script: Script) {
        self.init()
        self.request = request
        self.userVariable = userVariable
        self.script = script
    }

    func category() -> kBrickCategoryType {
        kBrickCategoryType.dataBrick
    }

    override class func description() -> String {
        "WebRequestBrick"
    }

    override func isWebRequest() -> Bool {
        true
    }

    override func getRequiredResources() -> Int {
        ResourceType.internet.rawValue
    }

    override func brickCell() -> BrickCellProtocol.Type! {
        WebRequestBrickCell.self as BrickCellProtocol.Type
    }

    func variable(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> UserVariable! {
        self.userVariable
    }

    func setVariable(_ variable: UserVariable!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.userVariable = variable
    }

    func formula(forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) -> Formula! {
        self.request
    }

    func setFormula(_ formula: Formula!, forLineNumber lineNumber: Int, andParameterNumber paramNumber: Int) {
        self.request = formula
    }

    func getFormulas() -> [Formula]? {
        if let request = request {
            return [request]
        }
        return nil
    }

    override func setDefaultValuesFor(_ spriteObject: SpriteObject!) {
        self.request = Formula(string: "https://catrob.at/joke")
    }

    func allowsStringFormula() -> Bool {
        true
    }

    override func isDisabledForBackground() -> Bool {
        false
    }
}

/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

@objc public protocol TextFieldInitialStateDefiner {
    func initialText(text: String) -> TextFieldAlertDefining
    func placeholder(placeholder: String) -> TextFieldAlertDefining
}

@objc public protocol TextFieldAlertActionAdding {
    func addDefaultActionWithTitle(title: String, handler: ((String) -> Void)?) -> TextFieldAlertControllerBuilding
    func addCancelActionWithTitle(title: String, handler: (() -> Void)?) -> TextFieldAlertControllerBuilding
}

@objc public protocol TextFieldAlertDefining : TextFieldInitialStateDefiner, TextFieldAlertActionAdding {}

public final class InputValidationResult : NSObject {
    let valid: Bool
    let localizedMessage: String?
    
    private init(valid: Bool, localizedMessage: String?) {
        self.valid = valid
        self.localizedMessage = localizedMessage
    }
    
    static func validInput() -> InputValidationResult {
        return InputValidationResult(valid: true, localizedMessage: nil)
    }
    
    @objc(invalidInputWithLocalizedMessage:)
    static func invalidInput(localizedMessage: String) -> InputValidationResult {
        return InputValidationResult(valid: false, localizedMessage: localizedMessage)
    }
}

@objc public protocol TextFieldInputValidator {
    func characterValidator(validator: (String) -> Bool) -> TextFieldInputValidating
    func valueValidator(validator: (String) -> InputValidationResult) -> TextFieldInputValidating
}

@objc public protocol TextFieldInputValidating : TextFieldInputValidator, BuilderProtocol { }

@objc public protocol TextFieldAlertControllerBuilding : TextFieldAlertActionAdding, BuilderProtocol, TextFieldInputValidating { }


final class TextFieldAlertController : BaseAlertController, TextFieldAlertDefining, TextFieldAlertControllerBuilding, UITextFieldDelegate {
    private var characterValidator: ((String) -> Bool)?
    private var valueValidator: ((String) -> InputValidationResult)?
    private let initialMessage: String?
    
    init(title: String?, message: String?) {
        initialMessage = message
        
        super.init(title: title, message: message, style: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            $0.clearButtonMode = .WhileEditing
            $0.returnKeyType = .Done
            $0.keyboardType = .Default
            $0.delegate = self
            $0.becomeFirstResponder()
        }
    }
    
    func initialText(text: String) -> TextFieldAlertDefining {
        alertController.textFields?[0].text = text
        return self
    }
    
    func placeholder(placeholder: String) -> TextFieldAlertDefining {
        alertController.textFields?[0].placeholder = placeholder
        return self
    }
    
    @objc func addDefaultActionWithTitle(title: String, handler: ((String) -> Void)?) -> TextFieldAlertControllerBuilding {
        let action = UIAlertAction(title: title, style: .Default) { [weak self] _ in
            guard let `self` = self else { return }
            
            let inputText = self.alertController.textFields?.first?.text ?? ""
            
            if let validationResult = self.valueValidator?(inputText) where !validationResult.valid {
                self.reinputWithMessage(validationResult.localizedMessage!, alertController: self.alertController)
                return
            }
            handler?(inputText)
        }
        alertController.addAction(action)
        return self
    }
    
    private func reinputWithMessage(message: String, alertController: UIAlertController) {
        AlertControllerBuilder.alertWithTitle(kLocalizedPocketCode, message: message)
            .addCancelActionWithTitle(kLocalizedOK, handler: {
                Util.topmostViewController().presentViewController(alertController, animated: true, completion: nil)
            }).build()
            .showWithController(Util.topmostViewController())
    }
    
    @objc func addCancelActionWithTitle(title: String, handler: (() -> Void)?) -> TextFieldAlertControllerBuilding {
        alertController.addAction(UIAlertAction(title: title, style: .Cancel) {_ in handler?() })
        return self
    }
    
    @objc func characterValidator(validator: (String) -> Bool) -> TextFieldInputValidating {
        characterValidator = validator
        return self
    }
    
    @objc func valueValidator(validator: (String) -> InputValidationResult) -> TextFieldInputValidating {
        valueValidator = validator
        return self
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let isValidCharacter = characterValidator
            where string.characters.contains({ !isValidCharacter(String($0)) }) {
            return false
        }
        
        if alertController.message != initialMessage {
            alertController.message = initialMessage
        }
        
        return true
    }
}

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

import Foundation

@objc public protocol TextFieldInitialStateDefiner {
    func initialText(_ text: String) -> TextFieldAlertDefining
    func placeholder(_ placeholder: String) -> TextFieldAlertDefining
}

@objc public protocol TextFieldAlertActionAdding {
    func addDefaultActionWithTitle(_ title: String, handler: ((String) -> Void)?) -> TextFieldAlertControllerBuilding
    func addCancelActionWithTitle(_ title: String, handler: (() -> Void)?) -> TextFieldAlertControllerBuilding
}

@objc public protocol TextFieldAlertDefining : TextFieldInitialStateDefiner, TextFieldAlertActionAdding {}

@objc
public final class InputValidationResult : NSObject {
    @objc let valid: Bool
    let localizedMessage: String?
    
    private init(valid: Bool, localizedMessage: String?) {
        self.valid = valid
        self.localizedMessage = localizedMessage
    }
    
    @objc
    static func validInput() -> InputValidationResult {
        return InputValidationResult(valid: true, localizedMessage: nil)
    }
    
    @objc(invalidInputWithLocalizedMessage:)
    static func invalidInput(_ localizedMessage: String) -> InputValidationResult {
        return InputValidationResult(valid: false, localizedMessage: localizedMessage)
    }
}

@objc public protocol TextFieldInputValidator {
    func characterValidator(_ validator: @escaping (String) -> Bool) -> TextFieldInputValidating
    func valueValidator(_ validator: @escaping (String) -> InputValidationResult) -> TextFieldInputValidating
}

@objc public protocol TextFieldInputValidating : TextFieldInputValidator, BuilderProtocol { }

@objc public protocol TextFieldAlertControllerBuilding : TextFieldAlertActionAdding, TextFieldInputValidating { }


final class TextFieldAlertController : BaseAlertController, TextFieldAlertDefining, TextFieldAlertControllerBuilding, UITextFieldDelegate {
    private var characterValidator: ((String) -> Bool)?
    private var valueValidator: ((String) -> InputValidationResult)?
    private let initialMessage: String?
    
    init(title: String?, message: String?) {
        initialMessage = message
        
        super.init(title: title, message: message, style: .alert)
        
        alertController.addTextField {
            $0.clearButtonMode = .whileEditing
            $0.returnKeyType = .done
            $0.keyboardType = .default
            $0.delegate = self
            $0.becomeFirstResponder()
        }
    }
    
    func initialText(_ text: String) -> TextFieldAlertDefining {
        alertController.textFields?[0].text = text
        return self
    }
    
    func placeholder(_ placeholder: String) -> TextFieldAlertDefining {
        alertController.textFields?[0].placeholder = placeholder
        return self
    }
    
    @objc func addDefaultActionWithTitle(_ title: String, handler: ((String) -> Void)?) -> TextFieldAlertControllerBuilding {
        let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            
            let inputText = self.alertController.textFields?.first?.text ?? ""
            
            if let validationResult = self.valueValidator?(inputText), !validationResult.valid {
                self.reinputWithMessage(validationResult.localizedMessage!, alertController: self.alertController)
                return
            }
            handler?(inputText)
        }
        alertController.addAction(action)
        return self
    }
    
    private func reinputWithMessage(_ message: String, alertController: UIAlertController) {
        AlertControllerBuilder.alert(title: kLocalizedPocketCode, message: message)
            .addCancelAction(title: kLocalizedOK, handler: {
                Util.topmostViewController().present(alertController, animated: true, completion: nil)
            }).build()
            .showWithController(Util.topmostViewController())
    }
    
    @objc func addCancelActionWithTitle(_ title: String, handler: (() -> Void)?) -> TextFieldAlertControllerBuilding {
        alertController.addAction(UIAlertAction(title: title, style: .cancel) {_ in handler?() })
        return self
    }

    @objc func characterValidator(_ validator: @escaping (String) -> Bool) -> TextFieldInputValidating {
        characterValidator = validator
        return self
    }
    
    @objc func valueValidator(_ validator: @escaping (String) -> InputValidationResult) -> TextFieldInputValidating {
        valueValidator = validator
        return self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let isValidCharacter = characterValidator, string.contains(where: { !isValidCharacter(String($0)) }) {
            return false
        }
        
        if alertController.message != initialMessage {
            alertController.message = initialMessage
        }
        
        return true
    }
}

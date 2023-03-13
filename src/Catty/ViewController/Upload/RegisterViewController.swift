/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class RegisterViewController: BaseAuthenticationViewController, UITextFieldDelegate {

    var username: String?

    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var usernameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var confirmPasswordField: UITextField!

    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var termsOfUseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = kLocalizedRegister
        initView()
        addDoneToTextFields()
    }

    func initView() {
        view.backgroundColor = .background

        headerImageView.image = UIImage(named: "PocketCode")
        headerImageView.contentMode = .scaleAspectFit

        aplyTitleStyle(for: titleLabel, text: kLocalizedRegister)

        applyStyle(for: usernameField, placeholder: kLocalizedUsername, icon: "person", tag: 1, text: username)
        usernameField.textContentType = .username

        applyStyle(for: emailField, placeholder: kLocalizedEmail, icon: "envelope", tag: 2)
        emailField.textContentType = .emailAddress
        emailField.keyboardType = .emailAddress

        applyStyle(for: passwordField, placeholder: kLocalizedPassword, icon: "lock", tag: 3)
        passwordField.textContentType = .newPassword
        passwordField.isSecureTextEntry = true

        applyStyle(for: confirmPasswordField, placeholder: kLocalizedConfirmPassword, icon: "exclamationmark.lock", tag: 4)
        confirmPasswordField.textContentType = .newPassword
        confirmPasswordField.isSecureTextEntry = true

        applyPrimaryStyle(for: registerButton, title: kLocalizedDone, action: #selector(registerAction))

        applySecondaryStyle(for: termsOfUseButton, title: "\(kLocalizedTermsAgreementPart) \(kLocalizedTermsOfUse)", action: #selector(termsOfUseAction), fontSize: 16)
    }

    func addDoneToTextFields() {
        usernameField.returnKeyType = .next
        usernameField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEndOnExit)

        emailField.returnKeyType = .next
        emailField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEndOnExit)

        passwordField.returnKeyType = .next
        passwordField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEndOnExit)

        confirmPasswordField.returnKeyType = .done
        confirmPasswordField.addTarget(self, action: #selector(registerAction), for: .editingDidEndOnExit)
    }

    // MARK: Actions

    @objc func registerAction() {
        dismissKeyboard()

        guard let username = usernameField.text, !username.isEmpty else {
            Util.alert(text: kLocalizedLoginUsernameNecessary)
            return
        }

        guard let email = emailField.text, isValidEmail(email) else {
            Util.alert(text: kLocalizedLoginEmailNotValid)
            return
        }

        guard let password = passwordField.text, password.count >= 6 else {
            Util.alert(text: kLocalizedLoginPasswordNotValid)
            return
        }

        guard let confirmPassword = confirmPasswordField.text, confirmPassword == password else {
            Util.alert(text: kLocalizedRegisterPasswordConfirmationNoMatch)
            return
        }

        registerButton.isEnabled = false
        showLoadingView()

        StoreAuthenticator().register(username: username, email: email, password: password) { error in
            DispatchQueue.main.async(execute: {
                self.hideLoadingView()
                self.registerButton.isEnabled = true

                switch error {
                case .none:
                    if let delegate = self.delegate as? UIViewController {
                        self.navigationController?.popToViewController(delegate, animated: true)
                    } else if let loginVC = self.previousViewController as? LoginViewController,
                              let loginVCPresenter = loginVC.previousViewController {
                        self.navigationController?.popToViewController(loginVCPresenter, animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .validation(response: let validationMessages):
                    Util.alert(text: validationMessages.values.joined(separator: "\n"))
                case .network, .timeout:
                    Util.defaultAlertForNetworkError()
                default:
                    Util.alert(text: kLocalizedUnexpectedErrorMessage)
                }
            })
        }
    }

    @objc func termsOfUseAction() {
        if let termsOfUseUrl = URL(string: NetworkDefines.termsOfUseUrl) {
            UIApplication.shared.open(termsOfUseUrl)
        }
    }

    // MARK: Helpers

    func isValidEmail(_ string: String) -> Bool {
        let emailRegex = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: string)
    }
}

/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class LoginViewController: BaseAuthenticationViewController, UITextFieldDelegate {

    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var usernameField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!

    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var forgotButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = kLocalizedLogin
        initView()
        addDoneToTextFields()
    }

    func initView() {
        view.backgroundColor = .background

        headerImageView.image = UIImage(named: "PocketCode")
        headerImageView.contentMode = .scaleAspectFit

        aplyTitleStyle(for: titleLabel, text: kLocalizedLogin)

        let username = UserDefaults.standard.string(forKey: NetworkDefines.kUsername)
        applyStyle(for: usernameField, placeholder: kLocalizedUsername, icon: "person", tag: 1, text: username)
        usernameField.textContentType = .username

        applyStyle(for: passwordField, placeholder: kLocalizedPassword, icon: "lock", tag: 2)
        passwordField.textContentType = .password
        passwordField.isSecureTextEntry = true

        applyPrimaryStyle(for: loginButton, title: kLocalizedLogin, action: #selector(loginAction))

        applySecondaryStyle(for: forgotButton, title: kLocalizedForgotPassword, action: #selector(forgotAction))

        applyPrimaryStyle(for: registerButton, title: kLocalizedRegister, action: #selector(registerAction))
    }

    func addDoneToTextFields() {
        usernameField.returnKeyType = .next
        usernameField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEndOnExit)

        passwordField.returnKeyType = .done
        passwordField.addTarget(self, action: #selector(loginAction), for: .editingDidEndOnExit)
    }

    // MARK: Actions

    @objc func loginAction() {
        dismissKeyboard()

        guard let username = usernameField.text, !username.isEmpty else {
            Util.alert(text: kLocalizedLoginUsernameNecessary)
            return
        }

        guard let password = passwordField.text, password.count >= 6 else {
            Util.alert(text: kLocalizedLoginPasswordNotValid)
            return
        }

        loginButton.isEnabled = false
        showLoadingView()

        StoreAuthenticator().login(username: username, password: password) { error in
            DispatchQueue.main.async(execute: {
                self.hideLoadingView()
                self.loginButton.isEnabled = true

                switch error {
                case .none:
                    if let delegate = self.delegate as? UIViewController {
                        self.navigationController?.popToViewController(delegate, animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .authentication:
                    Util.alert(text: kLocalizedAuthenticationFailed)
                case .network, .timeout:
                    Util.defaultAlertForNetworkError()
                default:
                    Util.alert(text: kLocalizedUnexpectedErrorMessage)
                }
            })
        }
    }

    @objc func forgotAction() {
        if let resetPasswordUrl = URL(string: NetworkDefines.resetPasswordUrl) {
            UIApplication.shared.open(resetPasswordUrl)
        }
    }

    @objc func registerAction() {
        let storyboard = UIStoryboard.init(name: "iPhone", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterController") as! RegisterViewController

        vc.delegate = delegate
        vc.username = usernameField.text

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Helpers

    override func willMove(toParent parent: UIViewController?) {
        if let delegate = delegate, parent == nil {
            delegate.successfullyAuthenticated()
        }
    }
}

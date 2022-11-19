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

//TODO: implement regex for password
extension LoginViewController {

    @objc func loginAction() {
        let username = (self.usernameField?.text ?? "").trimmingCharacters(in: .whitespaces)
        let password = (self.passwordField?.text ?? "").trimmingCharacters(in: .whitespaces)
        if username.isEmpty {
            let alert = UIAlertController(title: kLocalizedPocketCode, message: kLocalizedLoginUsernameNecessary, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: kLocalizedOK, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else if !validPassword(password: password) {
            let alert = UIAlertController(title: kLocalizedPocketCode, message: kLocalizedLoginPasswordNotValid, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: kLocalizedOK, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else if username.contains(" ") || password.contains(" ") {
            let alert = UIAlertController(title: kLocalizedPocketCode, message: kLocalizedNoWhitespaceAllowed, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: kLocalizedOK, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if let username = self.usernameField.text, let password = self.passwordField.text {
            loginAtServer(withUsername: username, andPassword: password)
        }
    }

    func validPassword(password: String) -> Bool {
        password.count >= 6 ? true : false
    }

}

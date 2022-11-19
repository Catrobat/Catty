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
        let username = (self.usernameField.text ?? "").trimmingCharacters(in: .whitespaces)
        let password = (self.passwordField.text ?? "").trimmingCharacters(in: .whitespaces)
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
            loginAtServer(username: username, password: password)
        }
    }

    func validPassword(password: String) -> Bool {
        password.count >= 6 ? true : false
    }

    func loginAtServer(username: String, password: String) {
        let httpBoundary = "---------------------------98598263596598246508247098291---------------------------"
        let usernameTag = "registrationUsername"
        let passwordTag = "registrationPassword"
        let registrationCountryTag = "registrationCountry"

        debugPrint("Login started with username:\(username) and password:\(password)")

        var request = URLRequest(url: URL(string: NetworkDefines.loginUrl)!)
        request.httpMethod = "POST"
        let contentType = String(format: "multipart/form-data; boundary=%@", httpBoundary)
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        var body = Data()

        self.userName = username

        if let data = username.data(using: String.Encoding(rawValue: NSUTF8StringEncoding)) {
            self.setFormDataParameter(parameterID: usernameTag, data: data, body: &body)
        }

        self.password = password

        if let data = password.data(using: String.Encoding(rawValue: NSUTF8StringEncoding)) {
            self.setFormDataParameter(parameterID: passwordTag, data: data, body: &body)
        }

        //Country
//        let currentLocale = NSLocale()
//        let countryCode = String(describing: currentLocale.object(forKey: NSLocale.Key.countryCode))
//        debugPrint("Current Country is: \(countryCode)")
//
//        if let data = countryCode.data(using: String.Encoding(rawValue: NSUTF8StringEncoding)) {
//            self.setFormDataParameter(parameterID: registrationCountryTag, data: data, body: &body)
//        }

        //  //Language ?!
        // close form
        body.append(String(format: "--%@--\r\n", httpBoundary).data(using: String.Encoding(rawValue: NSUTF8StringEncoding))!)
        // set request body
        request.httpBody = body

        let postLength = String(format: "%lu", body.count)

        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
        request.timeoutInterval = TimeInterval(NetworkDefines.connectionTimeout)

        self.showLoadingView()

        self.dataTask = self.createSession().dataTask(with: request as URLRequest, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                if Util.isNetworkError(error) {
                    DispatchQueue.main.async {
                        self.loginButton.isEnabled = false
                        self.hideLoadingView()
                        Util.defaultAlertForNetworkError()
                        return
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.handleLoginResponse(with: data, andResponse: response)
                }
            }
        })

        if self.dataTask != nil {
            self.dataTask.resume()
            self.loginButton.isEnabled = false
            self.showLoadingView()
        } else {
            self.loginButton.isEnabled = true
            self.hideLoadingView()
            Util.defaultAlertForNetworkError()
        }

    }
    func setFormDataParameter(parameterID: String, data: Data, body: inout Data) {
        let httpBoundary = "---------------------------98598263596598246508247098291---------------------------"
        body.append(Data(String(format: "--%@\r\n", httpBoundary).utf8))

        let parameterString = String(format: "Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterID)
        body.append(Data(parameterString.utf8))
        body.append(data)
        body.append(Data(String(format: "\r\n").utf8))
    }

    func createSession() -> URLSession {
        if self.session == nil {
            // Initialize Session Configuration
            let sessionConfiguration = URLSessionConfiguration.default
            let header: [String: String] = ["Accept": "Application/json"]
            // Configure Session Configuration
            sessionConfiguration.httpAdditionalHeaders = header
            // Initialize Session
            self.session = URLSession.init(configuration: sessionConfiguration)
        }

        return self.session
    }
}

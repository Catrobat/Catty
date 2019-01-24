/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

class RegisterViewController: BaseLoginViewController, UITextFieldDelegate {

    let usernameTag = "registrationUsername"
    let passwordTag = "registrationPassword"
    let registrationEmailTag = "registrationEmail"
    let registrationCountryTag = "registrationCountry"

    let tokenTag = "token"
    let statusCodeTag = "statusCode"
    let answerTag = "answer"
    let statusCodeOK = "200"
    let statusCodeRegistrationOK = "201"

    private var dataTask: URLSessionDataTask?
    private var shouldShowAlert = false

    weak var catTVC: CatrobatTableViewController?
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var termsOfUseButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var usernameField: UITextField!
    @IBOutlet private weak var confirmPasswordField: UITextField!
    var userName = ""
    var password = ""
    private var userEmail = ""
    private var loadingView: LoadingView?

    private var _session: URLSession?
    private var session: URLSession? {
        if _session == nil {
            // Initialize Session Configuration
            let sessionConfiguration = URLSessionConfiguration.default

            // Configure Session Configuration
            sessionConfiguration.httpAdditionalHeaders = [ "Accept": "application/json" ]

            // Initialize Session
            _session = URLSession(configuration: sessionConfiguration)
        }

        return _session
    }

    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kLocalizedRegister
        navigationController?.title = title
        initView()
        addDoneToTextFields()
        shouldShowAlert = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async(execute: {
            self.dataTask?.cancel()
        })
        super.viewWillDisappear(animated)
    }

    func initView() {
        let mainColor = UIColor.background()
        let darkColor = UIColor.globalTint()

        let fontName = "Avenir-Book"
        let boldFontName = "Avenir-Black"

        view.backgroundColor = mainColor
        headerImageView.image = UIImage(named: "PocketCode")
        headerImageView.contentMode = .scaleAspectFit

        titleLabel.textColor = UIColor.globalTint()
        if let font = UIFont(name: boldFontName, size: 28.0) {
            titleLabel.font = font
        }
        titleLabel.text = kLocalizedInfoRegister
        titleLabel.sizeToFit()

        usernameField.backgroundColor = UIColor.white
        usernameField.placeholder = kLocalizedUsername
        if !userName.isEmpty {
            usernameField.text = userName
        }
        usernameField.font = UIFont(name: fontName, size: 16.0)
        usernameField.layer.borderColor = UIColor(white: 0.9, alpha: 0.7).cgColor
        usernameField.layer.borderWidth = 1.0
        usernameField.tag = 1

        let leftView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView.image = UIImage(named: "user")
        usernameField.leftViewMode = .always
        usernameField.leftView = leftView
        let leftView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView2.image = UIImage(named: "password")
        passwordField.leftViewMode = .always
        passwordField.leftView = leftView2

        emailField.backgroundColor = UIColor.white
        emailField.placeholder = kLocalizedEmail
        emailField.font = UIFont(name: fontName, size: 16.0)
        emailField.layer.borderColor = UIColor(white: 0.9, alpha: 0.7).cgColor
        emailField.layer.borderWidth = 1.0
        emailField.tag = 2

        let leftView3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView3.image = UIImage(named: "email")
        emailField.leftViewMode = .always
        emailField.leftView = leftView3

        passwordField.backgroundColor = UIColor.white
        passwordField.placeholder = kLocalizedPassword
        if !password.isEmpty {
            passwordField.text = password
        }
        passwordField.isSecureTextEntry = true
        passwordField.font = UIFont(name: fontName, size: 16.0)
        passwordField.layer.borderColor = UIColor(white: 0.9, alpha: 0.7).cgColor
        passwordField.layer.borderWidth = 1.0
        passwordField.tag = 3

        let leftView4 = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView4.image = UIImage(named: "password")
        confirmPasswordField.leftViewMode = .always
        confirmPasswordField.leftView = leftView4 //Tried to reuse leftView2, but that led to problems

        confirmPasswordField.backgroundColor = UIColor.white
        confirmPasswordField.placeholder = kLocalizedConfirmPassword
        //    if (self.password) {
        //        self.passwordConfirmationField.text = self.password;
        //    }
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.font = UIFont(name: fontName, size: 16.0)
        confirmPasswordField.layer.borderColor = UIColor(white: 0.9, alpha: 0.7).cgColor
        confirmPasswordField.layer.borderWidth = 1.0
        confirmPasswordField.tag = 4

        termsOfUseButton.titleLabel?.lineBreakMode = .byWordWrapping
        termsOfUseButton.backgroundColor = UIColor.clear
        if let font = UIFont(name: boldFontName, size: 14.0) {
            termsOfUseButton.titleLabel?.font = font
        }
        termsOfUseButton.titleLabel?.textAlignment = .center
        termsOfUseButton.setTitle("\(kLocalizedTermsAgreementPart) \(kLocalizedTermsOfUse)", for: .normal)
        termsOfUseButton.setTitleColor(UIColor.buttonTint(), for: .normal)
        termsOfUseButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .highlighted)
        termsOfUseButton.addTarget(self, action: #selector(RegisterViewController.openTermsOfUse), for: .touchUpInside)

        registerButton.backgroundColor = darkColor
        if let font = UIFont(name: boldFontName, size: 20.0) {
            registerButton.titleLabel?.font = font
        }
        registerButton.setTitle(kUIFEDone, for: .normal)
        registerButton.setTitleColor(UIColor.background(), for: .normal)
        registerButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .highlighted)
        registerButton.addTarget(self, action: #selector(RegisterViewController.registerAction), for: .touchUpInside)
    }

    func addDoneToTextFields() {
        usernameField.returnKeyType = .next
        usernameField.addTarget(self, action: #selector(RegisterViewController.textFieldShouldReturn(_:)), for: .editingDidEndOnExit)
        emailField.returnKeyType = .next
        emailField.addTarget(self, action: #selector(RegisterViewController.textFieldShouldReturn(_:)), for: .editingDidEndOnExit)
        passwordField.returnKeyType = .next
        passwordField.addTarget(self, action: #selector(RegisterViewController.textFieldShouldReturn(_:)), for: .editingDidEndOnExit)
        confirmPasswordField.returnKeyType = .done
        confirmPasswordField.addTarget(self, action: #selector(RegisterViewController.registerAction), for: .editingDidEndOnExit)
    }

    func stringContainsSpace(_ checkString: String?) -> Bool {
        let whiteSpaceRange: NSRange? = (checkString as NSString?)?.rangeOfCharacter(from: CharacterSet.whitespaces)
        if Int(whiteSpaceRange?.location ?? 0) != NSNotFound {
            return true
        }
        return false
    }

    func nsStringIsValidEmail(_ checkString: String?) -> Bool {
        // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
        let emailRegex = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: checkString)
    }

    func validPassword(_ password: String?) -> Bool {
        let numberofCharacters: Int = 6
        if (password?.count ?? 0) >= numberofCharacters {
            return true
        } else {
            return false
        }
    }

    // MARK: Actions

    @objc func registerAction() {
        if usernameField.text!.isEmpty {
            Util.alert(withText: kLocalizedLoginUsernameNecessary)
            return
        } else if emailField.text!.isEmpty || !nsStringIsValidEmail(emailField.text) {
            Util.alert(withText: kLocalizedLoginEmailNotValid)
            return
        } else if !validPassword(passwordField.text) {
            Util.alert(withText: kLocalizedLoginPasswordNotValid)
            return
        } else if stringContainsSpace(usernameField.text) || stringContainsSpace(passwordField.text) {
            Util.alert(withText: kLocalizedNoWhitespaceAllowed)
            return
        } else if confirmPasswordField.text!.isEmpty || !(confirmPasswordField.text == passwordField.text) {
            Util.alert(withText: kLocalizedRegisterPasswordConfirmationNoMatch)
            confirmPasswordField.text = ""
            return
        }

        registerAtServer(withUsername: usernameField.text, andPassword: passwordField.text, andEmail: emailField.text)
    }

    func registerAtServer(withUsername username: String?, andPassword password: String?, andEmail email: String?) {
        print("Register started with username:\(username ?? "") and password:\(password ?? "") and email:\(email ?? "")")

        let registrationUrl = Util.isProductionServerActivated() ? kRegisterUrl : kTestRegisterUrl
        let urlString = "\(registrationUrl)/\(kConnectionRegister)"

        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "POST"

        let contentType = "multipart/form-data; boundary=\(RequestManager.httpBoundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()

        //username
        userName = username ?? ""
        RequestManager.setFormDataParameter(usernameTag, with: username?.data(using: .utf8), forHTTPBody: &body)

        //password
        self.password = password ?? ""
        RequestManager.setFormDataParameter(passwordTag, with: password?.data(using: .utf8), forHTTPBody: &body)

        //email
        userEmail = email ?? ""
        RequestManager.setFormDataParameter(registrationEmailTag, with: email?.data(using: .utf8), forHTTPBody: &body)

        //Country
        let currentLocale = NSLocale.current as NSLocale
        let countryCode = currentLocale.object(forKey: .countryCode) as? String
        print("Current Country is:\(countryCode ?? "")")
        RequestManager.setFormDataParameter(registrationCountryTag, with: countryCode?.data(using: .utf8), forHTTPBody: &body)

        // close form
        if let data = "--\(RequestManager.httpBoundary)--\r\n".data(using: .utf8) {
            body.append(data)
        }
        // set request body
        request.httpBody = body

        request.timeoutInterval = TimeInterval(kConnectionTimeout)

        let postLength = String(format: "%lu", UInt(body.count))
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")

        showLoadingView()

        dataTask = session?.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                if Util.isNetworkError(error) {
                    if let error = error {
                        print("ERROR: \(error)")
                    }

                    DispatchQueue.main.async(execute: {
                        self.registerButton.isEnabled = true
                        self.hideLoadingView()
                        Util.defaultAlertForNetworkError()
                        return
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    self.handleRegisterResponse(with: data, andResponse: response)
                })
            }
        }

        if dataTask != nil {
            dataTask?.resume()
            registerButton.isEnabled = false
            showLoadingView()
        } else {
            registerButton.isEnabled = true
            hideLoadingView()
            Util.defaultAlertForNetworkError()
        }
    }

    func handleRegisterResponse(with data: Data?, andResponse response: URLResponse?) {
        if data == nil {
            if shouldShowAlert {
                shouldShowAlert = false
                hideLoadingView()
                Util.defaultAlertForNetworkError()
            }
            return
        }

        var dictionary: [AnyHashable: Any]?
        if let data = data {
            do {
                dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
            } catch {
                print("JSON response could not be serialized")
            }
        }
        var statusCode: String?
        if let value = dictionary?[statusCodeTag] {
            statusCode = "\(value)"
            print("StatusCode is \(statusCode!)")
        }

        if (statusCode == statusCodeOK) || (statusCode == statusCodeRegistrationOK) {

            print("Registration successful")
            var token: String?
            if let value = dictionary?[tokenTag] {
                token = "\(value)"
                print("Token is \(token!)")
            }

            //save username, password and email in keychain and token in nsuserdefaults
            UserDefaults.standard.set(true, forKey: kUserIsLoggedIn)
            UserDefaults.standard.setValue(userName, forKey: kcUsername)
            UserDefaults.standard.setValue(userEmail, forKey: kcEmail)
            UserDefaults.standard.synchronize()

            JNKeychain.saveValue(token, forKey: kUserLoginToken)

            hideLoadingView()
            navigationController?.popToRootViewController(animated: false)
        } else {
            registerButton.isEnabled = true
            hideLoadingView()

            let serverResponse = dictionary?[answerTag] as? String
            print("Error: \(serverResponse ?? "")")
            Util.alert(withText: serverResponse)
        }
    }

    @objc func openTermsOfUse() {
        let url = kTermsOfUseURL
        if let url = URL(string: url) {
            UIApplication.shared.openURL(url)
        }
    }

    @objc override func dismissKeyboard() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
    }

    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }
        loadingView?.show()
        Util.setNetworkActivityIndicator(true)
    }

    func hideLoadingView() {
        loadingView?.hide()
        Util.setNetworkActivityIndicator(false)
    }

    func textFieldDidBeginEditing(_ sender: UITextField) {
        activeField = sender
    }

    override func textFieldDidEndEditing(_ sender: UITextField) {
        activeField = nil
    }
}

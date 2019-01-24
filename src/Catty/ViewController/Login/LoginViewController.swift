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

//web status codes are on: https://github.com/Catrobat/Catroweb/blob/master/statusCodes.php

class LoginViewController: BaseLoginViewController, UITextFieldDelegate {

    let usernameTag = "registrationUsername"
    let passwordTag = "registrationPassword"
    let registrationEmailTag = "registrationEmail"
    let registrationCountryTag = "registrationCountry"

    let tokenTag = "token"
    let statusCodeTag = "statusCode"
    let answerTag = "answer"
    let statusCodeOK = "200"
    let statusCodeRegistrationOK = "201"
    let statusAuthenticationFailed = "601"

    //random boundary string
    let httpBoundary = "---------------------------98598263596598246508247098291---------------------------"

    @objc weak var catTVC: CatrobatTableViewController?
    @IBOutlet private weak var usernameField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var forgotButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var registerButton: UIButton!
    private var userEmail = ""
    private var userName = ""
    private var password = ""
    private var loadingView: LoadingView?

    private var _session: URLSession?
    private var session: URLSession? {
        if _session == nil {
            // Initialize Session Configuration
            let sessionConfiguration = URLSessionConfiguration.default

            // Configure Session Configuration
            sessionConfiguration.httpAdditionalHeaders = [
                "Accept": "application/json"
            ]

            // Initialize Session
            _session = URLSession(configuration: sessionConfiguration)
        }

        return _session
    }
    private var dataTask: URLSessionDataTask?
    private var shouldShowAlert = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kLocalizedLogin
        navigationController?.title = title
        initView()
        addDoneToTextFields()
        shouldShowAlert = true
        usernameField.delegate = self
        passwordField.delegate = self
    }

    deinit {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }

    func initView() {
        let mainColor = UIColor.background()
        let darkColor = UIColor.globalTint()

        let fontName = "Avenir-Book"
        let boldFontName = "Avenir-Black"

        view.backgroundColor = mainColor
        headerImageView.image = UIImage(named: "PocketCode")
        headerImageView.contentMode = .scaleAspectFit

        infoLabel.textColor = UIColor.globalTint()
        if let font = UIFont(name: boldFontName, size: 28.0) {
            infoLabel.font = font
        }
        infoLabel.text = kLocalizedInfoLogin
        infoLabel.sizeToFit()

        usernameField.backgroundColor = UIColor.white
        usernameField.placeholder = kLocalizedUsername
        usernameField.font = UIFont(name: fontName, size: 16.0)
        usernameField.layer.borderColor = UIColor(white: 0.9, alpha: 0.7).cgColor
        usernameField.layer.borderWidth = 1.0
        usernameField.tag = 1

        let leftView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView.image = UIImage(named: "user")
        usernameField.leftViewMode = .always
        usernameField.leftView = leftView

        passwordField.backgroundColor = UIColor.white
        passwordField.placeholder = kLocalizedPassword
        passwordField.isSecureTextEntry = true
        passwordField.font = UIFont(name: fontName, size: 16.0)
        passwordField.layer.borderColor = UIColor(white: 0.9, alpha: 0.7).cgColor
        passwordField.layer.borderWidth = 1.0
        passwordField.tag = 2

        let leftView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView2.image = UIImage(named: "password")
        passwordField.leftViewMode = .always
        passwordField.leftView = leftView2

        loginButton.backgroundColor = darkColor
        if let font = UIFont(name: boldFontName, size: 20.0) {
            loginButton.titleLabel?.font = font
        }
        loginButton.setTitle(kLocalizedLogin, for: .normal)
        loginButton.setTitleColor(UIColor.background(), for: .normal)
        loginButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .highlighted)
        loginButton.addTarget(self, action: #selector(LoginViewController.loginAction), for: .touchUpInside)

        forgotButton.backgroundColor = UIColor.clear
        if let font = UIFont(name: fontName, size: 15.0) {
            forgotButton.titleLabel?.font = font
        }
        forgotButton.setTitle(kLocalizedForgotPassword, for: .normal)
        forgotButton.setTitleColor(UIColor.buttonTint(), for: .normal)
        forgotButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .highlighted)
        forgotButton.addTarget(self, action: #selector(LoginViewController.forgotPassword), for: .touchUpInside)
        //    self.forgotButton.frame = CGRectMake(0, currentHeight, self.view.frame.size.width, self.forgotButton.frame.size.height);

        registerButton.backgroundColor = darkColor
        if let font = UIFont(name: boldFontName, size: 20.0) {
            registerButton.titleLabel?.font = font
        }
        registerButton.setTitle(kLocalizedRegister, for: .normal)
        registerButton.setTitleColor(UIColor.background(), for: .normal)
        registerButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .highlighted)
        var insets = UIEdgeInsets()
        insets.left = 15
        insets.right = 15
        insets.top = 10
        insets.bottom = 10
        registerButton.contentEdgeInsets = insets
        registerButton.addTarget(self, action: #selector(LoginViewController.registerAction), for: .touchUpInside)
        //    self.registerButton.frame = CGRectMake(20, currentHeight, self.view.frame.size.width-40, self.registerButton.frame.size.height);
    }

    func addDoneToTextFields() {
        usernameField.returnKeyType = .next
        usernameField.addTarget(self, action: #selector(LoginViewController.textFieldShouldReturn(_:)), for: .editingDidEndOnExit)
        passwordField.returnKeyType = .done
        passwordField.addTarget(self, action: #selector(LoginViewController.loginAction), for: .editingDidEndOnExit)
    }

    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async(execute: {
            self.dataTask?.cancel()
        })

        super.viewWillDisappear(animated)
    }

    func textFieldDidBeginEditing(_ sender: UITextField) {
        activeField = sender
    }

    override func textFieldDidEndEditing(_ sender: UITextField) {
        activeField = nil
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            catTVC?.afterSuccessfulLogin()
        }
    }

    func addHorizontalLine(to view: UIView?, andHeight height: CGFloat) {
        let lineView = UIView(frame: CGRect(x: 0, y: height, width: view?.frame.size.width ?? 0.0, height: 1))
        lineView.backgroundColor = UIColor.utilityTint()
        view?.addSubview(lineView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func setFormDataParameter(_ parameterID: String?, with data: Data?, forHTTPBody body: Data?) {
        var body = body
        if let data = "--\(httpBoundary)\r\n".data(using: .utf8) {
            body?.append(data)
        }

        let parameterString = "Content-Disposition: form-data; name=\"\(parameterID ?? "")\"\r\n\r\n"
        if let data = parameterString.data(using: .utf8) {
            body?.append(data)
        }
        if let data = data {
            body?.append(data)
        }
        if let data = "\r\n".data(using: .utf8) {
            body?.append(data)
        }
    }

    // MARK: Actions
    @objc func loginAction() {
        if usernameField.text!.isEmpty {
            Util.alert(withText: kLocalizedLoginUsernameNecessary)
            return
        } else if !validPassword(passwordField.text) {
            Util.alert(withText: kLocalizedLoginPasswordNotValid)
            return
        } else if stringContainsSpace(usernameField.text) || stringContainsSpace(passwordField.text) {
            Util.alert(withText: kLocalizedNoWhitespaceAllowed)
            return
        }

        loginAtServer(withUsername: usernameField.text, andPassword: passwordField.text)
    }

    @objc func registerAction() {
        let storyboard = UIStoryboard(name: "iPhone", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterController") as? RegisterViewController
        vc?.catTVC = catTVC
        vc?.userName = usernameField.text ?? ""
        vc?.password = passwordField.text ?? ""

        if let vc = vc {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func loginAtServer(withUsername username: String?, andPassword password: String?) {
        print("Login started with username:\(username ?? "") and password:\(password ?? "")")

        let loginUrl = Util.isProductionServerActivated() ? kLoginUrl : kTestLoginUrl
        let urlString = "\(loginUrl)/\(kConnectionLogin)"

        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "POST"

        let contentType = "multipart/form-data; boundary=\(httpBoundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()

        //username
        userName = username ?? ""
        setFormDataParameter(usernameTag, with: username?.data(using: .utf8), forHTTPBody: body)

        //password
        self.password = password ?? ""
        setFormDataParameter(passwordTag, with: password?.data(using: .utf8), forHTTPBody: body)

        //    //Country
        //    NSLocale *currentLocale = [NSLocale currentLocale];
        //    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        //    NSDebug(@"Current Country is: %@", countryCode);
        //    [self setFormDataParameter:registrationCountryTag withData:[countryCode dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        //    
        //    //Language ?! 

        // close form
        if let data = "--\(httpBoundary)--\r\n".data(using: .utf8) {
            body.append(data)
        }
        // set request body
        request.httpBody = body

        let postLength = String(format: "%lu", UInt(body.count))
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")

        request.timeoutInterval = TimeInterval(kConnectionTimeout)

        showLoadingView()

        dataTask = session?.dataTask(with: request as URLRequest) { data, response, error in

            if error != nil {
                if Util.isNetworkError(error) {
                    if let error = error {
                        print("ERROR: \(error)")
                    }

                    DispatchQueue.main.async(execute: {
                        self.loginButton.isEnabled = true
                        self.hideLoadingView()
                        Util.defaultAlertForNetworkError()
                        return
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    self.handleLoginResponse(with: data, andResponse: response)
                })
            }
        }

        if dataTask != nil {
            dataTask?.resume()
            loginButton.isEnabled = false
            showLoadingView()
        } else {
            loginButton.isEnabled = true
            hideLoadingView()
            Util.defaultAlertForNetworkError()
        }

    }

    func handleLoginResponse(with data: Data?, andResponse response: URLResponse?) {
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

        if statusCode == statusCodeOK {
            print("Login successful")
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
            navigationController?.popViewController(animated: false)
        } else if statusCode == statusAuthenticationFailed {
            loginButton.isEnabled = true
            hideLoadingView()
            print("Error: \(kLocalizedAuthenticationFailed)")
            Util.alert(withText: kLocalizedAuthenticationFailed)
        } else {
            loginButton.isEnabled = true
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

    @objc func forgotPassword() {
        let url = Util.isProductionServerActivated() ? kRecoverPassword : kTestRecoverPassword
        if let url = URL(string: url) {
            UIApplication.shared.openURL(url)
        }
    }

    // MARK: Helpers

    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            //        [self.loadingView setBackgroundColor:[UIColor globalTintColor]];
            if let loadingView = loadingView {
                view.addSubview(loadingView)
            }
        }
        loadingView?.show()
        Util.setNetworkActivityIndicator(true)
    }

    func hideLoadingView() {
        loadingView?.hide()
        Util.setNetworkActivityIndicator(false)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

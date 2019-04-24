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

class UploadViewController: UIViewController {

    let uploadParameterTag = "upload"
    let fileChecksumParameterTag = "fileChecksum"
    let tokenParameterTag = "token"
    let projectNameTag = "projectTitle"
    let projectDescriptionTag = "projectDescription"
    let userEmailTag = "userEmail"
    let userNameTag = "username"
    let deviceLanguageTag = "deviceLanguage"

    let statusCodeTag = "statusCode"
    let answerTag = "answer"
    let projectIDTag = "projectId"
    let statusCodeOK = "200"
    let statusCodeTokenWrong = "601"

    //random boundary string
    //web status codes are on: https://github.com/Catrobat/Catroweb/blob/master/statusCodes.php
    let httpBoundary = "---------------------------98598263596598246508247098291---------------------------"
    let uploadFontSize: CGFloat = 16.0

    private var uploadBarButton: UIBarButtonItem?
    private var activeRequest: Bool = false
    private var project: Project?
    private var descriptionTextViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var projectNameLabel: UILabel!
    @IBOutlet private weak var projectNameTextField: UITextField!
    @IBOutlet private weak var sizeLabel: UILabel!
    @IBOutlet private weak var sizeValueLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!

    private var zipFileData: Data?
    private var loadingView: LoadingView?
    private var _session: URLSession?
    private var session: URLSession? {
        if _session == nil {
            // Initialize Session Configuration
            let sessionConfiguration = URLSessionConfiguration.default

            // Configure Session Configuration
            sessionConfiguration.httpAdditionalHeaders = ["Accept": "application/json"]

            // Initialize Session
            _session = URLSession(configuration: sessionConfiguration)
        }
        return _session
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background()
        initProjectNameViewElements()
        initSizeViewElements()
        initDescriptionViewElements()
        initObservers()
        hideKeyboardWhenTapInViewController()

        self.uploadBarButton = UIBarButtonItem(title: kLocalizedUpload,
                                               style: .plain,
                                               target: self,
                                               action: #selector(UploadViewController.checkProjectAction))
        navigationItem.rightBarButtonItem = self.uploadBarButton

        projectNameTextField.becomeFirstResponder()
    }

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.project = Project.init(loadingInfo: Util.lastUsedProjectLoadingInfo())!
    }

    func initProjectNameViewElements() {
        projectNameLabel.textColor = UIColor.globalTint()
        projectNameLabel.text = kLocalizedName
        projectNameLabel.font = UIFont.boldSystemFont(ofSize: uploadFontSize)

        projectNameTextField.textColor = UIColor.textTint()
        projectNameTextField.backgroundColor = UIColor.white
        projectNameTextField.borderStyle = .roundedRect
        projectNameTextField.keyboardType = .default
        projectNameTextField.text = project?.header.programName!
    }

    func initSizeViewElements() {
        sizeLabel.textColor = UIColor.globalTint()
        sizeLabel.text = kLocalizedSize
        sizeLabel.font = UIFont.boldSystemFont(ofSize: uploadFontSize)

        let fileManager = CBFileManager.shared()
        zipFileData = nil
        zipFileData = fileManager?.zip(project)

        sizeValueLabel.textColor = UIColor.textTint()
        sizeValueLabel.font = UIFont.boldSystemFont(ofSize: uploadFontSize)

        guard let data = zipFileData else {
            debugPrint("ZIPing project files failed")
            self.dismissView()
            return
        }
        sizeValueLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data.count),
                                                        countStyle: .file)
    }

    func initDescriptionViewElements() {
        descriptionLabel.textColor = UIColor.globalTint()
        descriptionLabel.text = kLocalizedDescription
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: uploadFontSize)

        descriptionTextView.textColor = UIColor.textTint()
        descriptionTextView.keyboardAppearance = .default
        descriptionTextView.backgroundColor = UIColor.white
        descriptionTextView.keyboardType = .default
        descriptionTextView.text = project?.header.programDescription ?? ""

        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.textViewBorderGray().cgColor
        descriptionTextView.layer.cornerRadius = 8

        //manual constraint (because we need to store the bottom anchor)
        descriptionTextViewBottomConstraint = descriptionTextView
            .bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -20)
        descriptionTextViewBottomConstraint.isActive = true
    }

    func initObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UploadViewController.uploadAction),
                                               name: NSNotification.Name(rawValue: kReadyToUpload),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }

    func dismissView() {
        navigationController?.popViewController(animated: true)
    }

    func enableUploadView() {
        DispatchQueue.main.async(execute: {
            self.loadingView?.hide()
            self.navigationItem.rightBarButtonItem = self.uploadBarButton
            for view: UIView in self.view.subviews where !(view is LoadingView) {
                view.alpha = 1.0
            }
            self.view.isUserInteractionEnabled = true
        })
    }

    // MARK: - Helpers

    func setFormDataParameter(_ parameterID: String?, with data: Data?, forHTTPBody body: inout Data) {
        if let anEncoding = "--\(httpBoundary)\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        let parameterString = "Content-Disposition: form-data; name=\"\(parameterID ?? "")\"\r\n\r\n"
        if let anEncoding = parameterString.data(using: .utf8) {
            body.append(anEncoding)
        }
        if let aData = data {
            body.append(aData)
        }
        if let anEncoding = "\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
    }

    func setAttachmentParameter(_ parameterID: String?, with data: Data?, forHTTPBody body: inout Data) {
        if let anEncoding = "--\(httpBoundary)\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        let parameterString = "Content-Disposition: attachment; name=\"\(parameterID ?? "")\"; filename=\".zip\" \r\n"
        if let anEncoding = parameterString.data(using: .utf8) {
            body.append(anEncoding)
        }
        if let anEncoding = "Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        if let aData = data {
            body.append(aData)
        }
        if let anEncoding = "\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
    }

    func showLoading() {
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }

        loadingView?.show()
        let barButtonSpinner = UIActivityIndicatorView(style: .white)
        barButtonSpinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButtonSpinner)
    }

    // MARK: - Actions

    @objc func checkProjectAction() {
        if projectNameTextField.text!.isEmpty {
            Util.alert(withText: kLocalizedUploadProjectNecessary)
            return
        }
        project?.rename(toProjectName: projectNameTextField.text!)
        project?.updateDescription(withText: descriptionTextView.text)

        self.showLoading()
        for view: UIView in view.subviews where !(view is LoadingView) {
            view.alpha = 0.3
        }
        view.isUserInteractionEnabled = false

        activeRequest = true
    }

    // MARK: - Upload

    @objc func uploadAction() {
        //This is to prevent uploading the project twice, since the notification for uploading is received twice
        if !activeRequest {
            return
        }
        activeRequest = false

        //Project might have changed, update zip file accordingly
        let fileManager = CBFileManager.shared()
        zipFileData = fileManager?.zip(project)

        var checksum: String?
        if zipFileData != nil {
            checksum = zipFileData?.md5()
        }

        if checksum != nil {
            debugPrint("Upload started for file: "+(project?.header.programName)!+" with checksum:"+checksum!)

            //Upload example URL: https://pocketcode.org/api/upload/upload.json?upload=ZIPFile&fileChecksum=MD5&token=loginToken
            //For testing use: https://catroid-test.catrob.at/api/upload/upload.json?upload=ZIPFile&fileChecksum=MD5&token=loginToken

            //Warning: TestServer Uploads are restricted in size (about 1MB)!!!

            let uploadUrl = kUploadUrl
            let urlString = "\(uploadUrl)/\(kConnectionUpload)"

            let request = NSMutableURLRequest()
            request.url = URL(string: urlString)
            request.httpMethod = "POST"

            let contentType = "multipart/form-data; boundary=\(httpBoundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")

            var body = Data()

            //Project Name
            setFormDataParameter(projectNameTag,
                                 with: project?.header.programName.data(using: .utf8),
                                 forHTTPBody: &body)

            //Project Description
            setFormDataParameter(projectDescriptionTag,
                                 with: project?.header.programDescription.data(using: .utf8),
                                 forHTTPBody: &body)

            //User Email
            if UserDefaults.standard.value(forKey: kcEmail) != nil {
                setFormDataParameter(userEmailTag,
                                     with: (UserDefaults.standard.value(forKey: kcEmail) as! String).data(using: .utf8),
                                     forHTTPBody: &body)
            }

            //checksum
            setFormDataParameter(fileChecksumParameterTag,
                                 with: checksum?.data(using: .utf8),
                                 forHTTPBody: &body)

            //token
            let token = JNKeychain.loadValue(forKey: kUserLoginToken) as! String
            setFormDataParameter(tokenParameterTag,
                                 with: token.data(using: .utf8),
                                 forHTTPBody: &body)

            //Username
            setFormDataParameter(userNameTag,
                                 with: (UserDefaults.standard.value(forKey: kcUsername) as! String).data(using: .utf8),
                                 forHTTPBody: &body)

            //Language
            setFormDataParameter(deviceLanguageTag,
                                 with: NSLocale.preferredLanguages[0].data(using: .utf8),
                                 forHTTPBody: &body)

            //zip file
            setAttachmentParameter(uploadParameterTag,
                                   with: zipFileData,
                                   forHTTPBody: &body)

            // close request form
            if let anEncoding = "--\(httpBoundary)--\r\n".data(using: .utf8) {
                body.append(anEncoding)
            }
            // set request body
            request.httpBody = body

            let postLength = String(format: "%lu", UInt(body.count))
            request.addValue(postLength, forHTTPHeaderField: "Content-Length")

            // debug output
            let string1 = String(data: request.httpBody!,
                                 encoding: String.Encoding.utf8) ?? "Data could not be printed"
            debugPrint(string1)

            // start request
            let dataTask = session!.dataTask(with: request as URLRequest) { data, _, error in
                self.enableUploadView()
                if error != nil {
                    debugPrint("Connection could not be established")
                    Util.defaultAlertForNetworkError()
                } else {
                    var dictionary: [AnyHashable: Any]?
                    if let aData = data {
                        do {
                            dictionary = try JSONSerialization.jsonObject(with: aData, options: []) as? [AnyHashable: Any]
                        } catch {
                            print("JSON response could not be serialized")
                        }
                    }
                    var statusCode: String?
                    if let aTag = dictionary?[self.statusCodeTag] {
                        statusCode = "\(aTag)"
                    }
                    debugPrint("StatusCode is ", statusCode ?? "undefined")

                    if statusCode == self.statusCodeOK {
                        debugPrint("Upload successful")

                        //Set unique Project-ID received from server
                        var projectId: String?
                        if let aTag = dictionary?[self.projectIDTag] {
                            projectId = "\(aTag)"
                            self.project?.header.programID = projectId
                            self.project?.saveToDisk(withNotification: true)
                        }

                        //Set new token but when? everytime is wrong
                        if let aTag = dictionary?[self.tokenParameterTag] {
                            JNKeychain.saveValue(aTag, forKey: kUserLoginToken)
                        }

                        DispatchQueue.main.async(execute: {
                            self.dismissView()
                        })
                    } else {
                        let serverResponse = dictionary?[self.answerTag] as? String
                        debugPrint("Error: ", serverResponse ?? "undefined")
                        DispatchQueue.main.async(execute: {
                            if serverResponse != nil {
                                Util.alert(withText: serverResponse)
                            } else {
                                Util.alert(withText: kLocalizedUploadProblem)
                            }
                        })

                        if statusCode == self.statusCodeTokenWrong {
                            //Token not valid
                            UserDefaults.standard.set(false, forKey: kUserIsLoggedIn)

                            var viewArray: [AnyHashable]?
                            if let aControllers = self.parent?.navigationController?.viewControllers {
                                viewArray = aControllers
                            }
                            viewArray?.removeLast()
                            var newViewArray: [AnyHashable]?
                            if let anArray = viewArray {
                                newViewArray = anArray
                            }
                            if let anArray = newViewArray as? [UIViewController] {
                                self.parent?.navigationController?.setViewControllers(anArray, animated: true)
                            }
                        }
                    }
                }
            }
            dataTask.resume()
        } else {
            debugPrint("Could not build checksum")
            enableUploadView()
            Util.alert(withText: kLocalizedUploadProblem)
        }
    }

    // MARK: - Keyboard

    @objc func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            UIView.animate(withDuration: 0.5, animations: {
                self.descriptionTextViewBottomConstraint.constant = -keyboardFrame.size.height - 20
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.descriptionTextViewBottomConstraint.constant = -20
            self.view.layoutIfNeeded()
        }
    }
}

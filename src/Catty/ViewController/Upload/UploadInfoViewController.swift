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

//Warning: TestServer Uploads are restricted in size (about 1MB)!!!

import UIKit

@objc class UploadInfoViewController: UIViewController {

    let uploadParameterTag = "upload"
    let fileChecksumParameterTag = "fileChecksum"
    let tokenParameterTag = "token"
    let programNameTag = "projectTitle"
    let programDescriptionTag = "projectDescription"
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

    private var activeRequest: Bool = false

    weak var delegate: DismissPopupDelegate?
    @objc public var program: Program?

    @IBOutlet private weak var programNameLabel: UILabel!
    @IBOutlet private weak var programNameTextField: UITextField!
    @IBOutlet private weak var sizeLabel: UILabel!
    @IBOutlet private weak var sizeValueLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var uploadButton: UIButton!

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
    private var zipFileData: Data?
    private var loadingView: LoadingView?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background()
        initProgramNameViewElements()
        initSizeViewElements()
        initDescriptionViewElements()
        initActionButtons()
        title = kLocalizedUpload
        navigationController?.isToolbarHidden = true
        navigationController?.title = title
        let rightButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(UploadInfoViewController.dismissView))
        navigationItem.rightBarButtonItem = rightButton
        navigationController?.navigationBar.tintColor = UIColor.navTint()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.navTint()]
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UploadInfoViewController.uploadAction),
                                               name: NSNotification.Name(rawValue: kReadyToUpload),
                                               object: nil)

        programNameTextField.becomeFirstResponder()
        self.hideKeyboardWhenTapInViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initProgramNameViewElements() {
        programNameLabel.textColor = UIColor.globalTint()
        programNameLabel.text = kLocalizedName
        programNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: uploadFontSize)!

        programNameTextField.textColor = UIColor.textTint()
        programNameTextField.backgroundColor = UIColor.white
        programNameTextField.borderStyle = .roundedRect
        programNameTextField.autocorrectionType = .no
        programNameTextField.autocapitalizationType = .none
        programNameTextField.keyboardType = .default
        programNameTextField.text = program?.header.programName!
    }

    func initSizeViewElements() {
        sizeLabel.textColor = UIColor.globalTint()
        sizeLabel.text = kLocalizedSize
        sizeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: uploadFontSize)!

        let fileManager = CBFileManager.shared()
        zipFileData = nil
        zipFileData = fileManager?.zip(program)
        var zipFileSizeString = ""

        if zipFileData == nil {
            debugPrint("ZIPing program files failed")
            delegate?.dismissPopup(withCode: false)
        } else {
            zipFileSizeString = adaptSizeRepresentationString(zipFileData?.count ?? 0) ?? ""
        }

        sizeValueLabel.textColor = UIColor.textTint()
        sizeValueLabel.text = zipFileSizeString
        sizeValueLabel.font = UIFont(name: "HelveticaNeue-Bold", size: uploadFontSize)!
    }

    func initDescriptionViewElements() {
        descriptionLabel.textColor = UIColor.globalTint()
        descriptionLabel.text = kLocalizedDescription
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: uploadFontSize)!

        descriptionTextView.textColor = UIColor.textTint()
        descriptionTextView.keyboardAppearance = .default
        descriptionTextView.backgroundColor = UIColor.white
        descriptionTextView.autocorrectionType = .no
        descriptionTextView.autocapitalizationType = .none
        descriptionTextView.keyboardType = .default
        descriptionTextView.text = program?.header.programDescription ?? ""

        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.textViewBorderGray().cgColor
        descriptionTextView.layer.cornerRadius = 8
    }

    func initActionButtons() {
        uploadButton.setTitle(kLocalizedUpload, for: .normal)
        uploadButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: uploadFontSize + 4)!
        uploadButton.backgroundColor = UIColor.globalTint()
        uploadButton.titleLabel?.textAlignment = .center
        uploadButton.addTarget(self, action: #selector(UploadInfoViewController.checkProgramAction), for: .touchUpInside)
        uploadButton.setTitleColor(UIColor.buttonHighlightedTint(), for: .normal)
    }

    @objc func dismissView() {
        navigationController?.dismiss(animated: true)
    }

    func enableUploadView() {
        DispatchQueue.main.async(execute: {
            self.loadingView?.hide()
            for view: UIView in self.view.subviews where !(view is LoadingView) {
                view.alpha = 1.0
            }
            self.uploadButton.isEnabled = true
            self.view.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
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

    func adaptSizeRepresentationString(_ size: Int) -> String? {
        var sizeFloat = CGFloat(size)

        var divisionAmount: Int = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB"]

        while sizeFloat > 1024 {
            sizeFloat /= 1024
            divisionAmount += 1
        }

        return String(format: "%.2f %@", sizeFloat, tokens[divisionAmount])
    }

    // MARK: - Actions

    func cancel() {
        delegate?.dismissPopup(withCode: false)
    }

    @objc func checkProgramAction() {
        if programNameTextField.text!.isEmpty {
            Util.alert(withText: kLocalizedUploadProgramNecessary)
            return
        }
        //RemixOF
        if program?.header.url != nil && program?.header.userHandle != nil {
            program?.header.remixOf = program?.header.url
            program?.header.url = nil
            program?.header.userHandle = nil
        }
        program?.rename(toProgramName: programNameTextField.text!)
        program?.updateDescription(withText: descriptionTextView.text)
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }
        loadingView?.show()
        for view: UIView in view.subviews where !(view is LoadingView) {
            view.alpha = 0.3
        }
        view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false

        activeRequest = true
    }

    // MARK: - Upload

    @objc func uploadAction() {
        //This is to prevent uploading the program twice, since the notification for uploading is received twice
        if !activeRequest {
            return
        }
        activeRequest = false

        //Program might have changed, update zip file accordingly
        let fileManager = CBFileManager.shared()
        zipFileData = fileManager?.zip(program)

        var checksum: String?
        if zipFileData != nil {
            checksum = zipFileData?.md5()
        }

        if checksum != nil {
            debugPrint("Upload started for file: "+(program?.header.programName)!+" with checksum:"+checksum!)

            //Upload example URL: https://pocketcode.org/api/upload/upload.json?upload=ZIPFile&fileChecksum=MD5&token=loginToken
            //For testing use: https://catroid-test.catrob.at/api/upload/upload.json?upload=ZIPFile&fileChecksum=MD5&token=loginToken

            let uploadUrl = Util.isProductionServerActivated() ? kUploadUrl : kTestUploadUrl
            let urlString = "\(uploadUrl)/\(kConnectionUpload)"

            let request = NSMutableURLRequest()
            request.url = URL(string: urlString)
            request.httpMethod = "POST"

            let contentType = "multipart/form-data; boundary=\(httpBoundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")

            var body = Data()

            //Program Name
            setFormDataParameter(programNameTag, with: program?.header.programName.data(using: .utf8), forHTTPBody: &body)

            //Program Description
            setFormDataParameter(programDescriptionTag, with: program?.header.programDescription.data(using: .utf8), forHTTPBody: &body)

            //User Email
            if UserDefaults.standard.value(forKey: kcEmail) != nil {
                setFormDataParameter(userEmailTag, with: (UserDefaults.standard.value(forKey: kcEmail) as! String).data(using: .utf8), forHTTPBody: &body)
            }

            //checksum
            setFormDataParameter(fileChecksumParameterTag, with: checksum?.data(using: .utf8), forHTTPBody: &body)

            //token
            let token = JNKeychain.loadValue(forKey: kUserLoginToken) as! String
            setFormDataParameter(tokenParameterTag, with: token.data(using: .utf8), forHTTPBody: &body)

            //Username
            setFormDataParameter(userNameTag, with: (UserDefaults.standard.value(forKey: kcUsername) as! String).data(using: .utf8), forHTTPBody: &body)

            //Language
            setFormDataParameter(deviceLanguageTag, with: NSLocale.preferredLanguages[0].data(using: .utf8), forHTTPBody: &body)

            //zip file
            setAttachmentParameter(uploadParameterTag, with: zipFileData, forHTTPBody: &body)

            // close request form
            if let anEncoding = "--\(httpBoundary)--\r\n".data(using: .utf8) {
                body.append(anEncoding)
            }
            // set request body
            request.httpBody = body

            let postLength = String(format: "%lu", UInt(body.count))
            request.addValue(postLength, forHTTPHeaderField: "Content-Length")

            // debug output
            let string1 = String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
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
                    debugPrint("StatusCode is ", statusCode!)

                    if statusCode == self.statusCodeOK {
                        debugPrint("Upload successful")

                        //Set unique Program-ID received from server
                        var projectId: String?
                        if let aTag = dictionary?[self.projectIDTag] {
                            projectId = "\(aTag)"
                            self.program?.header.programID = projectId
                            self.program?.saveToDisk(withNotification: true)
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
                        debugPrint("Error: "+serverResponse!)
                        DispatchQueue.main.async(execute: {
                            Util.alert(withText: serverResponse)
                            self.delegate?.dismissPopup(withCode: false)
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
}

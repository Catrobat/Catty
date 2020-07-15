/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
    let uploadFontSize: CGFloat = 16.0

    private var uploadBarButton: UIBarButtonItem?
    private var activeRequest: Bool = false
    private var project: Project?
    private var descriptionTextViewBottomConstraint: NSLayoutConstraint!
    private var uploader: StoreProjectUploaderProtocol?

    @IBOutlet private weak var projectNameLabel: UILabel!
    @IBOutlet private weak var projectNameTextField: UITextField!
    @IBOutlet private weak var sizeLabel: UILabel!
    @IBOutlet private weak var sizeValueLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!

    private var loadingView: LoadingView?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.nibName != nil {
            view.backgroundColor = UIColor.background
            initProjectNameViewElements()
            initSizeViewElements()
            initDescriptionViewElements()
            initObservers()
            hideKeyboardWhenTapInViewController()

            self.uploadBarButton = UIBarButtonItem(title: kLocalizedUploadProject,
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(UploadViewController.checkProjectAction))
            navigationItem.rightBarButtonItem = self.uploadBarButton

            projectNameTextField.becomeFirstResponder()
        }
    }

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.project = Project.init(loadingInfo: Util.lastUsedProjectLoadingInfo())!

        self.uploader = StoreProjectUploader(fileManager: CBFileManager())
    }

    init(uploader: StoreProjectUploaderProtocol, project: Project) {
        activeRequest = true
        self.project = project
        super.init(nibName: nil, bundle: nil)
        self.uploader = uploader
    }

    func initProjectNameViewElements() {
        projectNameLabel.textColor = UIColor.globalTint
        projectNameLabel.text = kLocalizedName
        projectNameLabel.font = UIFont.boldSystemFont(ofSize: uploadFontSize)

        projectNameTextField.borderStyle = .roundedRect
        projectNameTextField.layer.borderWidth = 1.0
        projectNameTextField.layer.borderColor = UIColor.textViewBorderGray.cgColor
        projectNameTextField.layer.cornerRadius = 3
        projectNameTextField.keyboardType = .default
        projectNameTextField.text = project?.header.programName!
    }

    func initSizeViewElements() {
        sizeLabel.textColor = UIColor.globalTint
        sizeLabel.text = kLocalizedSize
        sizeLabel.font = UIFont.boldSystemFont(ofSize: uploadFontSize)

        let fileManager = CBFileManager.shared()
        let zipFileData = fileManager?.zip(project)

        sizeValueLabel.textColor = UIColor.textTint
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
        descriptionLabel.textColor = UIColor.globalTint
        descriptionLabel.text = kLocalizedDescription
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: uploadFontSize)

        descriptionTextView.keyboardAppearance = .default
        descriptionTextView.keyboardType = .default
        descriptionTextView.text = project?.header.programDescription ?? ""

        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.textViewBorderGray.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textColor = UIColor.textTint
        descriptionTextView.clipsToBounds = true

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
        if self.nibName != nil {
            DispatchQueue.main.async(execute: {
                self.loadingView?.hide()
                self.navigationItem.rightBarButtonItem = self.uploadBarButton
                for view: UIView in self.view.subviews where !(view is LoadingView) {
                    view.alpha = 1.0
                }
                self.view.isUserInteractionEnabled = true
            })
        }
    }

    // MARK: - Helpers

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
        project?.rename(toProjectName: projectNameTextField.text!, andShowSaveNotification: true)
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
        if let project = project, let uploader = self.uploader {
            uploader.upload(project: project,
                            completion: { projectId, error  in
                                self.enableUploadView()
                                if let error = error {
                                    switch error {
                                    case .unexpectedError, .timeout:
                                        Util.defaultAlertForNetworkError()
                                    case .zippingError, .invalidProject, .request:
                                        Util.alert(withText: kLocalizedUploadProblem)
                                    case .authenticationFailed:
                                        UserDefaults.standard.set(false, forKey: kUserIsLoggedIn)

                                        AlertControllerBuilder.alert(title: kLocalizedPocketCode, message: kLocalizedSessionExpired)
                                            .addDefaultAction(title: kLocalizedOK) {
                                                let storyboard = UIStoryboard(name: "iPhone", bundle: nil)
                                                if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginController") as? LoginViewController {
                                                    self.navigationController?.pushViewController(loginViewController, animated: true)
                                                }
                                            }.build().showWithController(self)
                                    }
                                    return
                                }
                                DispatchQueue.main.async(execute: {
                                    if let projectId = projectId {
                                        project.rename(toProjectName: project.header.programName, andProjectId: projectId, andShowSaveNotification: true)
                                    }
                                    self.dismissView()
                                })
            }, progression: nil)
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

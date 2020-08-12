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

class UploadViewController: UIViewController, UploadCategoryViewControllerDelegate {
    let labelFontSize: CGFloat = 17.0
    let valueFontSize: CGFloat = 17.0
    let horizontalConstrainValue: CGFloat = 25.0
    let verticalConstrainValue: CGFloat = 10.0
    let minimumHeightOfDescriptionTextView: CGFloat = 50

    private var uploadBarButton: UIBarButtonItem?
    private var activeRequest: Bool = false
    private var project: Project?
    private var descriptionTextViewBottomConstraint: NSLayoutConstraint!
    private var firstLineViewTopConstraint: NSLayoutConstraint!
    private var uploader: StoreProjectUploaderProtocol?
    private var projectNameTextFieldRenderingForFirstTime = true
    private var keyboardIsCoveringDescriptionView = false

    private var projectNameTextField: UITextField
    private var descriptionTextView: UITextView
    private var labels: [UILabel]
    private var separationViews: [UIView]
    private var values: [UILabel]
    private var selectCategoriesValueLabel: UILabel

    private var loadingView: LoadingView?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.nibName != nil {
            view.backgroundColor = UIColor.background
            initProjectNameViewElements()
            initSizeViewElements()
            initSelectCategoriesElements()
            initDescriptionViewElements()
            initObservers()
            hideKeyboardWhenTapInViewController()

            self.uploadBarButton = UIBarButtonItem(title: kLocalizedUploadProject,
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(UploadViewController.checkProjectAction))
            navigationItem.rightBarButtonItem = self.uploadBarButton
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if projectNameTextFieldRenderingForFirstTime {
            projectNameTextField.becomeFirstResponder()
            projectNameTextFieldRenderingForFirstTime = false
        }
        if descriptionTextView.frame.height < minimumHeightOfDescriptionTextView
            && descriptionTextView.isFirstResponder
            && !keyboardIsCoveringDescriptionView {
            firstLineViewTopConstraint.constant = -minimumHeightOfDescriptionTextView
        }
    }
    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        self.separationViews = [UIView]()
        self.labels = [UILabel]()
        self.values = [UILabel]()
        self.projectNameTextField = UITextField()
        self.descriptionTextView = UITextView()
        self.selectCategoriesValueLabel = UILabel()
        super.init(coder: aDecoder)
        self.project = Project.init(loadingInfo: Util.lastUsedProjectLoadingInfo())!

        self.uploader = StoreProjectUploader(fileManager: CBFileManager())
    }

    init(uploader: StoreProjectUploaderProtocol, project: Project, selectCategoriesValueLabel: UILabel) {
        activeRequest = true
        self.project = project
        self.separationViews = [UIView]()
        self.labels = [UILabel]()
        self.values = [UILabel]()
        self.projectNameTextField = UITextField()
        self.descriptionTextView = UITextView()
        self.selectCategoriesValueLabel = selectCategoriesValueLabel
        super.init(nibName: nil, bundle: nil)
        self.uploader = uploader
    }

    func initProjectNameViewElements() {
        addLineViewElement(withTopConstraint: 3 * verticalConstrainValue, fromElement: self.view)
        let programLabel = createLabel(text: kLocalizedName, font: .boldSystemFont(ofSize: labelFontSize), addConstraint: true)
        programLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        self.projectNameTextField = UITextField()
        projectNameTextField.keyboardType = .default
        projectNameTextField.text = project?.header.programName!
        self.view.addSubview(self.projectNameTextField)

        projectNameTextField.translatesAutoresizingMaskIntoConstraints = false
        projectNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        projectNameTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -horizontalConstrainValue).isActive = true
        projectNameTextField.centerYAnchor.constraint(equalTo: programLabel.centerYAnchor, constant: 1).isActive = true
        projectNameTextField.leftAnchor.constraint(equalTo: programLabel.rightAnchor, constant: 10).isActive = true
    }

    func initSizeViewElements() {
        if let lastLabel = labels.last {
            addLineViewElement(withTopConstraint: verticalConstrainValue, fromElement: lastLabel)
        }
        let sizeLabel = createLabel(text: kLocalizedSize, font: .boldSystemFont(ofSize: labelFontSize), addConstraint: true)

        let fileManager = CBFileManager.shared()
        let zipFileData = fileManager?.zip(project)
        guard let data = zipFileData else {
            debugPrint("ZIPing project files failed")
            self.dismissView()
            return
        }
        let value = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
        let sizeValueLabel = self.createValue(text: value, font: .systemFont(ofSize: valueFontSize), color: .lightGray)

        sizeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeValueLabel.centerYAnchor.constraint(equalTo: sizeLabel.centerYAnchor).isActive = true
        sizeValueLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -horizontalConstrainValue).isActive = true
    }

    func initSelectCategoriesElements() {
        if let lastLabel = labels.last {
            addLineViewElement(withTopConstraint: verticalConstrainValue, fromElement: lastLabel)
        }
        let selectCategoriesLabel = createLabel(text: kLocalizedSelectCategories, font: .boldSystemFont(ofSize: labelFontSize), addConstraint: false)

        var tags = String()
        if let existingTags = self.project?.header.tags, !existingTags.isEmpty {
            tags = existingTags
        } else {
            tags = kLocalizedNoCategoriesSelected
        }
        selectCategoriesValueLabel = createValue(text: tags, font: .systemFont(ofSize: valueFontSize - 5), color: .black)

        let selectCategoryView = UIView()
        let selectCategoryTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCategories))
        selectCategoryView.addGestureRecognizer(selectCategoryTapGesture)
        self.view.addSubview(selectCategoryView)

        selectCategoryView.translatesAutoresizingMaskIntoConstraints = false
        if let lastSeperationView = self.separationViews.last {
            selectCategoryView.topAnchor.constraint(equalTo: lastSeperationView.bottomAnchor, constant: verticalConstrainValue).isActive = true
        }
        selectCategoryView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: horizontalConstrainValue).isActive = true
        selectCategoryView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -horizontalConstrainValue).isActive = true

        selectCategoriesLabel.translatesAutoresizingMaskIntoConstraints = false
        selectCategoriesLabel.topAnchor.constraint(equalTo: selectCategoryView.topAnchor, constant: 0).isActive = true
        selectCategoriesLabel.leftAnchor.constraint(equalTo: selectCategoryView.leftAnchor, constant: 0).isActive = true

        selectCategoriesValueLabel.translatesAutoresizingMaskIntoConstraints = false
        selectCategoriesValueLabel.topAnchor.constraint(equalTo: selectCategoriesLabel.bottomAnchor, constant: 1).isActive = true
        selectCategoriesValueLabel.leftAnchor.constraint(equalTo: selectCategoryView.leftAnchor, constant: 0).isActive = true
        selectCategoriesValueLabel.bottomAnchor.constraint(equalTo: selectCategoryView.bottomAnchor, constant: 0).isActive = true

        var accessoryImageView = UIView()
        if let  accessoryImage = UIImage(named: "accessory") {
            accessoryImageView = UIImageView(image: accessoryImage.withRenderingMode(.alwaysTemplate))
        }
        accessoryImageView.tintColor = .lightGray
        self.view.addSubview(accessoryImageView)

        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        accessoryImageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        accessoryImageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        accessoryImageView.centerYAnchor.constraint(equalTo: selectCategoryView.centerYAnchor).isActive = true
        accessoryImageView.trailingAnchor.constraint(equalTo: selectCategoryView.trailingAnchor).isActive = true
    }

    func initDescriptionViewElements() {
        if let lastLabel = labels.last {
            addLineViewElement(withTopConstraint: verticalConstrainValue, fromElement: lastLabel)
        }
        let descriptionLabel = createLabel(text: kLocalizedDescription, font: .boldSystemFont(ofSize: labelFontSize), addConstraint: true)

        descriptionTextView = UITextView()
        descriptionTextView.keyboardAppearance = .default
        descriptionTextView.keyboardType = .default
        descriptionTextView.font = .systemFont(ofSize: valueFontSize)
        descriptionTextView.text = project?.header.programDescription ?? ""

        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.textViewBorderGray.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textColor = UIColor.textTint
        descriptionTextView.clipsToBounds = true
        self.view.addSubview(descriptionTextView)

        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        let hightConstrain = descriptionTextView.heightAnchor.constraint(equalToConstant: 100)
        hightConstrain.priority = UILayoutPriority(rawValue: 50)
        hightConstrain.isActive = true
        descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: verticalConstrainValue).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: horizontalConstrainValue).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -horizontalConstrainValue).isActive = true

        //manual constraint (because we need to store the bottom anchor)
        descriptionTextViewBottomConstraint = descriptionTextView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -20)
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

    func createValue(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = font
        self.view.addSubview(label)
        self.values.append(label)

        return label
    }

    func createLabel(text: String, font: UIFont, addConstraint: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.globalTint
        label.font = font
        self.view.addSubview(label)
        self.labels.append(label)

        if addConstraint {
            label.translatesAutoresizingMaskIntoConstraints = false
            if let lastSeperationView = self.separationViews.last {
             label.topAnchor.constraint(equalTo: lastSeperationView.bottomAnchor, constant: verticalConstrainValue).isActive = true
            }
            label.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: horizontalConstrainValue).isActive = true
        }

        return label
    }

    func addLineViewElement(withTopConstraint topConstraint: CGFloat, fromElement element: UIView) {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.textViewBorderGray
        self.separationViews.append(lineView)
        view.addSubview(lineView)

        lineView.translatesAutoresizingMaskIntoConstraints = false
        if element == self.view {
            firstLineViewTopConstraint = lineView.topAnchor.constraint(equalTo: element.topAnchor, constant: topConstraint)
            firstLineViewTopConstraint.isActive = true
        } else if values.count == 2, let selectCategoryValueLabel = self.values.last {
           lineView.topAnchor.constraint(equalTo: selectCategoryValueLabel.bottomAnchor, constant: topConstraint).isActive = true
        } else {
            lineView.topAnchor.constraint(equalTo: element.bottomAnchor, constant: topConstraint).isActive = true
        }
        lineView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueToSelectCategories {
            if let destination = segue.destination as? UploadCategoryViewController {
                destination.delegate = self
                destination.tags = project?.header.tags
            }
        }
    }

    func categoriesSelected(tags: [String]) {
        let stringRepresentationOfSelectedTags = tags.joined(separator: ", ")
        if !stringRepresentationOfSelectedTags.isEmpty {
            selectCategoriesValueLabel.text = stringRepresentationOfSelectedTags
        } else {
            selectCategoriesValueLabel.text = kLocalizedNoCategoriesSelected
        }
        project?.header.tags = tags.joined(separator: ", ")
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

    @objc func selectCategories() {
        projectNameTextField.endEditing(true)
        descriptionTextView.endEditing(true)
        performSegue(withIdentifier: kSegueToSelectCategories, sender: self)
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
                                        UserDefaults.standard.set(false, forKey: NetworkDefines.kUserIsLoggedIn)

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
                self.keyboardIsCoveringDescriptionView = self.descriptionTextView.frame.origin.y > (self.view.frame.height - (keyboardFrame.size.height + 20))
                if !self.keyboardIsCoveringDescriptionView {
                    self.descriptionTextViewBottomConstraint.constant = -keyboardFrame.size.height - 20
                }
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.descriptionTextViewBottomConstraint.constant = -20
            self.firstLineViewTopConstraint.constant = 3 * self.verticalConstrainValue
            self.keyboardIsCoveringDescriptionView = false
            self.view.layoutIfNeeded()
        }
    }
}

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

import UIKit

@objc protocol SetProjectDescriptionDelegate: NSObjectProtocol {
    func setDescription(_ description: String?)
}

@objc class ProjectDescriptionViewController: UIViewController {
    @objc weak var delegate: SetProjectDescriptionDelegate?

    private var header: UILabel!
    private var descriptionTextView: UITextView!
    private var descriptionTextViewBottomConstraint: NSLayoutConstraint!

    // MARK: Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteGray()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)

        initNavBar()
        initControls()
        initTextView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextView.becomeFirstResponder()
    }

    // MARK: Initialization
    func initControls() {
        header = UILabel()
        descriptionTextView = UITextView()
        view.addSubview(header)
        view.addSubview(descriptionTextView)

        header.textAlignment = .center
        header.text = kLocalizedSetDescription
        header.textColor = UIColor.globalTint()
        var navTopAnchor = view.safeTopAnchor
        if self.navigationController != nil {
            navTopAnchor = topLayoutGuide.bottomAnchor
        }
        header.setAnchors(top: navTopAnchor,
                          left: view.safeLeftAnchor,
                          right: view.safeRightAnchor,
                          bottom: nil,
                          topPadding: 20,
                          leftPadding: 20,
                          rightPadding: 20,
                          bottomPadding: 0)

        descriptionTextView.isAccessibilityElement = true
        descriptionTextView.accessibilityIdentifier = "descriptionTextView"
        descriptionTextView.setAnchors(top: header.bottomAnchor,
                                       left: view.safeLeftAnchor,
                                       right: view.safeRightAnchor,
                                       bottom: nil,
                                       topPadding: 20,
                                       leftPadding: 20,
                                       rightPadding: 20,
                                       bottomPadding: 0)
        //manual constraint (because we need to store the bottom anchor)
        descriptionTextViewBottomConstraint = descriptionTextView
            .bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -20)
        descriptionTextViewBottomConstraint.isActive = true
    }

    func initNavBar() {
        let doneBarButton = UIBarButtonItem(title: kLocalizedDone,
                                            style: .plain,
                                            target: self,
                                            action: #selector(doneAction(sender:)))
        let cancelBarButton = UIBarButtonItem(title: kLocalizedCancel,
                                              style: .plain,
                                              target: self,
                                              action: #selector(cancelAction(sender:)))
        doneBarButton.tintColor = UIColor.white
        cancelBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = cancelBarButton
        self.navigationItem.rightBarButtonItem = doneBarButton
    }

    func initTextView() {
        descriptionTextView.keyboardAppearance = UIKeyboardAppearance.default
        descriptionTextView.backgroundColor = UIColor.white
        descriptionTextView.textColor = UIColor.textTint()
        descriptionTextView.tintColor = UIColor.globalTint()
        descriptionTextView.font = UIFont.systemFont(ofSize: 16.0)

        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.textViewBorderGray().cgColor
        descriptionTextView.layer.cornerRadius = 8

        if delegate is MyProjectsViewController {
            var mpvc: MyProjectsViewController?
            mpvc = delegate as? MyProjectsViewController
            descriptionTextView.text = mpvc?.selectedProject.header.programDescription ?? ""
        }
        if delegate is ProjectTableViewController {
            var mpvc: ProjectTableViewController?
            mpvc = delegate as? ProjectTableViewController
            descriptionTextView.text = mpvc?.project.header.programDescription ?? ""
        }
    }

    // MARK: keyboard
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

    // MARK: Action
    @objc func cancelAction(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @objc func doneAction(sender: UIBarButtonItem) {
        delegate?.setDescription(descriptionTextView.text)
        dismiss(animated: true)
    }
}

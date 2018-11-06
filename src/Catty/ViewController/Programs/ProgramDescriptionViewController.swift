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

import UIKit

@objc protocol SetProgramDescriptionDelegate: NSObjectProtocol {
    func setDescription(_ description: String?)
}

@objc class ProgramDescriptionViewController: UIViewController {
    @objc weak var delegate: SetProgramDescriptionDelegate?

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

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

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
        header.setAnchors(top: navTopAnchor, left: view.safeLeftAnchor, right: view.safeRightAnchor, bottom: nil, topPadding: 20, leftPadding: 20, rightPadding: 20, bottomPadding: 0)

        descriptionTextView.isAccessibilityElement = true
        descriptionTextView.accessibilityIdentifier = "descriptionTextView"
        descriptionTextView.setAnchors(top: header.bottomAnchor, left: view.safeLeftAnchor, right: view.safeRightAnchor, bottom: nil, topPadding: 20, leftPadding: 20, rightPadding: 20, bottomPadding: 0)
        //manual constraint (because we need to store the bottom anchor)
        descriptionTextViewBottomConstraint = descriptionTextView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -20)
        descriptionTextViewBottomConstraint.isActive = true
    }

    func initNavBar() {
        let doneBarButton = UIBarButtonItem(title: kLocalizedDone, style: .plain, target: self, action: #selector(doneAction(sender:)))
        let cancelBarButton = UIBarButtonItem(title: kLocalizedCancel, style: .plain, target: self, action: #selector(cancelAction(sender:)))
        doneBarButton.tintColor = UIColor.white
        cancelBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem  = cancelBarButton
        self.navigationItem.rightBarButtonItem  = doneBarButton
    }

    func initTextView() {
        descriptionTextView.keyboardAppearance = UIKeyboardAppearance.default
        descriptionTextView.backgroundColor = UIColor.white
        descriptionTextView.textColor = UIColor.textTint()
        descriptionTextView.tintColor = UIColor.globalTint()

        if delegate is MyProgramsViewController {
            var mpvc: MyProgramsViewController?
            mpvc = delegate as? MyProgramsViewController
            descriptionTextView.text = mpvc?.selectedProgram.header.programDescription ?? ""
        }
        if delegate is ProgramTableViewController {
            var mpvc: ProgramTableViewController?
            mpvc = delegate as? ProgramTableViewController
            descriptionTextView.text = mpvc?.program.header.programDescription ?? ""
        }
    }

    // MARK: keyboard
    @objc func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
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

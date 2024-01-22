/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

@objc protocol AuthenticationDelegate {
    func successfullyAuthenticated()
}

class BaseAuthenticationViewController: UIViewController {

    @objc weak var delegate: AuthenticationDelegate?

    private let loadingView = LoadingView()
    private var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        loadingView.isHidden = true
        view.addSubview(loadingView)

        hideKeyboardWhenTapInViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        super.viewWillDisappear(animated)
    }

    // MARK: Keyboard handling

    @objc func keyboardWillShow(_ notification: NSNotification) {
        let scrollView = view.subviews.first { $0.isKind(of: UIScrollView.self) } as? UIScrollView

        scrollView?.isScrollEnabled = true

        if let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.size.height, right: 0)
            scrollView?.contentInset = insets
            scrollView?.scrollIndicatorInsets = insets
        }

        if let activeField = activeField {
            scrollView?.scrollRectToVisible(activeField.frame, animated: true)
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        let scrollView = view.subviews.first { $0.isKind(of: UIScrollView.self) } as? UIScrollView

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView?.contentInset = insets
        scrollView?.scrollIndicatorInsets = insets

        scrollView?.setContentOffset(CGPoint.zero, animated: true)
    }

    // MARK: Text field delegate

    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return false
    }

    // MARK: Loading Indicator

    func showLoadingView() {
        loadingView.show()
        Util.setNetworkActivityIndicator(true)
    }

    func hideLoadingView() {
        loadingView.hide()
        Util.setNetworkActivityIndicator(false)
    }

    // MARK: UI Styling

    func aplyTitleStyle(for label: UILabel, text: String) {
        label.textColor = .globalTint
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.text = text
        label.sizeToFit()
    }

    func applyStyle(for textField: UITextField, placeholder: String, icon: String, tag: Int, text: String? = nil) {
        textField.placeholder = placeholder
        if let text = text {
            textField.text = text
        }
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderColor = UIColor.textViewBorderGray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        if #available(iOS 13.0, *) {
            textField.layer.cornerCurve = .continuous
        }
        textField.tag = tag
        if let iconImage = UIImage(named: icon) {
            textField.setIcon(iconImage)
        }
    }

    func applyPrimaryStyle(for button: UIButton, title: String, action: Selector) {
        button.backgroundColor = .globalTint
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        if #available(iOS 13.0, *) {
            button.layer.cornerCurve = .continuous
        }
        button.setTitle(title, for: .normal)
        button.setTitleColor(.navTint, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    func applySecondaryStyle(for button: UIButton, title: String, action: Selector, fontSize: UInt = 18) {
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle(title, for: .normal)
        button.setTitleColor(.globalTint, for: .normal)
        button.setTitleColor(.navTint, for: .highlighted)
        button.addTarget(self, action: action, for: .touchUpInside)
    }
}

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

class BaseLoginViewController: UIViewController {

    let kOFFSET_FOR_KEYBOARD = 100.0

    private var isMovedUp = false

    weak var activeField: UITextField?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isMovedUp = false
        edgesForExtendedLayout = []
        // Do any additional setup after loading the view.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(BaseLoginViewController.dismissKeyboard))
        view.addGestureRecognizer(recognizer)
    }

    //method to move the view up/down whenever the keyboard is shown/dismissed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(BaseLoginViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(BaseLoginViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // unregister for keyboard notifications while not visible.
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewWillDisappear(animated)
    }

    @objc func keyboardWillShow(_ notification: Notification?) {

        let keyboardValue = (notification?.userInfo![UIResponder.keyboardFrameEndUserInfoKey]) as? NSValue
        let keyboardRect: CGRect? = keyboardValue?.cgRectValue

        var myScrollView: UIScrollView?
        for i: UIView in view.subviews where i is UIScrollView {
            myScrollView = i as? UIScrollView
        }

        myScrollView?.isScrollEnabled = true
        let insets = UIEdgeInsets(top: CGFloat(0.0),
                                  left: CGFloat(0.0),
                                  bottom: CGFloat(keyboardRect?.size.height ?? 0.0),
                                  right: CGFloat(0.0))

        myScrollView?.contentInset = insets
        myScrollView?.scrollIndicatorInsets = insets

        myScrollView?.scrollRectToVisible(activeField?.frame ?? CGRect.zero, animated: true)
    }

    @objc func keyboardWillHide(_ notification: Notification?) {
        let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)

        var myScrollView: UIScrollView?
        for i: UIView in view.subviews where i is UIScrollView {
            myScrollView = i as? UIScrollView
        }
        myScrollView?.contentInset = insets
        myScrollView?.scrollIndicatorInsets = insets
        view.endEditing(true)
    }

    func textFieldDidEndEditing(_ sender: UITextField) {
        activeField = nil
    }

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        // Try to find next responder
        let nextResponder: UIResponder? = textField.superview?.viewWithTag(nextTag)
        if nextResponder != nil {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
}

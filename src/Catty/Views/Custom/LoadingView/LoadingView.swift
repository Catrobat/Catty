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

class LoadingView: UIView {

    private let kLoadingBackgroundHeight = 100
    private let kLoadingBackgroundWidth = 200

    private var activityIndicator: UIActivityIndicatorView?
    private var loadingLabel: UILabel?

    // MARK: - init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        backgroundColor = UIColor.globalTint
        alpha = 0.70
        layer.cornerRadius = 5
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        initLoadingLabel()
        initActivityIndicator()
    }

    func initLoadingLabel() {
        loadingLabel = UILabel(frame: CGRect(x: 15, y: 65, width: 170, height: 20))
        loadingLabel?.backgroundColor = UIColor.clear
        loadingLabel?.textColor = UIColor.white
        let loadingText = "\(kLocalizedLoading)..."
        loadingLabel?.text = loadingText
        loadingLabel?.textAlignment = .center
        loadingLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loadingLabel?.adjustsFontSizeToFitWidth = true
        if let aLabel = loadingLabel {
            addSubview(aLabel)
        }
    }

    func initActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator?.frame = CGRect(x: 80, y: 15, width: 40, height: 40)
        if let anIndicator = activityIndicator {
            addSubview(anIndicator)
        }
    }

    // MARK: - show and hide

    @objc func show() {
        activityIndicator?.startAnimating()
        isHidden = false
        superview?.bringSubviewToFront(self)

        self.centerView()

        self.widthAnchor.constraint(equalToConstant: CGFloat(kLoadingBackgroundWidth)).isActive = true
        self.heightAnchor.constraint(equalToConstant: CGFloat(kLoadingBackgroundHeight)).isActive = true

        self.superview?.layoutIfNeeded()
    }

    @objc func hide() {
        activityIndicator?.stopAnimating()
        isHidden = true
    }
}

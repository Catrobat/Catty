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

class PrivacyPolicyViewController: UIViewController {

    let safeArea: UIView
    let imageView: UIImageView
    let headerLabel: UILabel
    let headlineLabel: UILabel
    let textLabel: UILabel
    let scrollView: UIScrollView
    let disagreeButton: UIButton
    let acceptButton: UIButton

    init() {
        safeArea = UIView()
        imageView = UIImageView()
        headerLabel = UILabel()
        headlineLabel = UILabel()
        textLabel = UILabel()
        scrollView = UIScrollView()
        disagreeButton = UIButton()
        acceptButton = UIButton()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction private func disagreeButtonAction(_ sender: UIButton) {
        Util.alert(text: kLocalizedPrivacyPolicyDenyText)
    }

    @IBAction private func acceptButtonAction(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        PrivacyPolicyViewController.hasBeenShown = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupSafeArea()
        self.setupImage()
        self.setupDisagreeButton()
        self.setupAcceptButton()
        self.setupScrollView()
        self.setupHeadline()
        self.setupHeader()
        self.setupText()
    }
}

fileprivate extension PrivacyPolicyViewController {
    func setupSafeArea() {
        safeArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeArea)

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
           safeArea.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
           safeArea.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
           safeArea.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
           safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: guide.bottomAnchor, multiplier: 1.0)
        ])
    }

    func setupImage() {
        imageView.image = UIImage(named: "PocketCode")
        safeArea.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: -48),
           imageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
           imageView.widthAnchor.constraint(equalToConstant: 300),
           imageView.heightAnchor.constraint(equalToConstant: 300 / 2.1357742182)
        ])
    }

    func setupDisagreeButton() {
        disagreeButton.setTitle(kLocalizedPrivacyPolicyDisagree, for: [])
        disagreeButton.backgroundColor = UIColor.globalTint
        disagreeButton.setTitleColor(UIColor.white, for: .normal)
        disagreeButton.addTarget(self, action: #selector(disagreeButtonAction(_:)), for: .touchUpInside)
        safeArea.addSubview(disagreeButton)

        disagreeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           disagreeButton.heightAnchor.constraint(equalToConstant: 50),
           disagreeButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
           disagreeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
           disagreeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4989)
        ])
    }

    func setupAcceptButton() {
        acceptButton.setTitle(kLocalizedPrivacyPolicyAgree, for: [])
        acceptButton.backgroundColor = UIColor.globalTint
        acceptButton.setTitleColor(UIColor.white, for: .normal)
        acceptButton.addTarget(self, action: #selector(acceptButtonAction(_:)), for: .touchUpInside)
        safeArea.addSubview(acceptButton)

        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           acceptButton.heightAnchor.constraint(equalToConstant: 50),
           acceptButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
           acceptButton.widthAnchor.constraint(equalTo: disagreeButton.widthAnchor),
           acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }

    func setupScrollView() {
        safeArea.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           scrollView.bottomAnchor.constraint(equalTo: acceptButton.topAnchor, constant: -16),
           scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
           scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
           scrollView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -32)
        ])
    }

    func setupHeadline() {
        headlineLabel.text = kLocalizedPrivacyPolicyHeadline
        headlineLabel.textColor = UIColor.globalTint
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headlineLabel.numberOfLines = 0
        headlineLabel.lineBreakMode = .byWordWrapping
        scrollView.addSubview(headlineLabel)

        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           headlineLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
           headlineLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
           headlineLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
           headlineLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupHeader() {
        headerLabel.text = kLocalizedPrivacyPolicyHeader
        headerLabel.textColor = UIColor.globalTint
        headerLabel.font = headerLabel.font.withSize(15)
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        scrollView.addSubview(headerLabel)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            headerLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupText() {
        textLabel.text = kLocalizedPrivacyPolicyText
        textLabel.textColor = UIColor.globalTint
        textLabel.font = textLabel.font.withSize(15)
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        scrollView.addSubview(textLabel)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           textLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
           textLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
           textLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
           textLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
           textLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}

extension PrivacyPolicyViewController {

    @objc static var hasBeenShown: Bool {
        get { UserDefaults.standard.bool(forKey: kUserPrivacyPolicyHasBeenShown) }
        set { UserDefaults.standard.set(newValue, forKey: kUserPrivacyPolicyHasBeenShown) }
    }

    @objc static var showOnEveryLaunch: Bool {
        get { UserDefaults.standard.bool(forKey: kUserShowPrivacyPolicyOnEveryLaunch) }
        set { UserDefaults.standard.set(newValue, forKey: kUserShowPrivacyPolicyOnEveryLaunch) }
    }
}

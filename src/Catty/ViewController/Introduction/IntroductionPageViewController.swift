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

@objc
class IntroductionPageViewController: UIPageViewController {

    /// The pages for the introduction content plus one extra page without
    /// content, that is shown before dismissing the introduction.
    private var pages: [UIViewController]!

    /// Content of the pages
    private let content = [
        IntroductionViewController.Content(title: kLocalizedWelcomeToPocketCode, description: kLocalizedWelcomeDescription, image: UIImage(imageLiteralResourceName: "page1_logo")),
        IntroductionViewController.Content(title: kLocalizedExploreApps, description: kLocalizedExploreDescription, image: UIImage(imageLiteralResourceName: "page2_explore")),
        IntroductionViewController.Content(title: kLocalizedCreateAndEdit, description: kLocalizedCreateAndEditDescription, image: UIImage(imageLiteralResourceName: "page3_info"))
    ]

    /// A flag that is set when scrolling to the extra page without content
    private var dismissAfterAnimation = false

    // MARK: - Lifecycle

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupBackground()
        self.dataSource = self
        self.delegate = self

        let storyboard = UIStoryboard(name: "Introduction", bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() as? IntroductionViewController else {
            fatalError("Failed to load introduction content view controllers.")
        }

        viewController.content = self.content[0]
        self.pages = [viewController]
        self.setViewControllers(self.pages, direction: .forward, animated: false)
    }
}

fileprivate extension IntroductionPageViewController {
    func setupBackground() {
        guard UIAccessibility.isReduceTransparencyEnabled else {
            self.view.backgroundColor = .darkGray
            self.view.alpha = 0.95
            return
        }

        self.view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate([self.view.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
                                     self.view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                                     self.view.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
                                     self.view.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)])
    }
}

extension IntroductionPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = self.pages.firstIndex(of: viewController), current > 0,
            self.content.indices.contains(current - 1)
            else { return nil }

        return self.pages[current - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = self.pages.firstIndex(of: viewController),
            current < self.content.count
            else { return nil }

        if self.pages.indices.contains(current + 1) {
            return self.pages[current + 1]
        }

        guard let storyboard = viewController.storyboard,
            let viewController = storyboard.instantiateInitialViewController() as? IntroductionViewController
            else { fatalError("Failed to load introduction content view controllers.") }

        if current + 1 < self.content.count {
            viewController.content = self.content[current + 1]
        }
        self.pages += [viewController]
        return viewController
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        // only show page indicator for the pages that have a content
        return self.content.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension IntroductionPageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   willTransitionTo pendingViewControllers: [UIViewController]) {
        // prepare for dismissing introduction on showing the extra page without content
        if let pendingViewController = pendingViewControllers.first,
            let index = self.pages.firstIndex(of: pendingViewController) {
            self.dismissAfterAnimation = index == self.content.count
        }
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // dismiss introduction on showing extra page without content
        if let previousViewController = previousViewControllers.first,
            let index = self.pages.firstIndex(of: previousViewController),
            self.dismissAfterAnimation && index == self.content.count - 1 && completed {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            IntroductionPageViewController.hasBeenShown = true
        }
    }
}

extension IntroductionPageViewController {
    @objc
    static var hasBeenShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kUserIntroductionHasBeenShown)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kUserIntroductionHasBeenShown)
        }
    }

    @objc
    static var showOnEveryLaunch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kUserShowIntroductionOnEveryLaunch)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kUserShowIntroductionOnEveryLaunch)
        }
    }
}

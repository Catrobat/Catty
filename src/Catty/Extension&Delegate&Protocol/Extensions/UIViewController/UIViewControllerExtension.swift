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

extension UIViewController {

    var previousViewController: UIViewController? {
        guard let viewControllers = navigationController?.viewControllers,
              let index = viewControllers.firstIndex(of: self), index > 0 else {
            return nil
        }

        return viewControllers[index - 1]
    }

    func hideKeyboardWhenTapInViewController() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(UIViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func openLoginScreen(_ delegate: AuthenticationDelegate? = nil) {
        guard let viewController = self.instantiateViewController("LoginController") as? LoginViewController else { return }
            viewController.delegate = delegate
            self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func openProject(_ project: Project) {
        ProjectManager.shared.currentProject = project
        guard let viewController = self.instantiateViewController("ScenesTableViewController") as? ScenesTableViewController else { return }
        project.activeScene = project.scenes[0] as! Scene
        viewController.project = project
        project.setAsLastUsedProject()
        viewController.stagePresenterVC = StagePresenterViewController()
        viewController.stagePresenterVC.stageManager = StageManager(project: project)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func openScene(_ scene: Scene, _ scenesTableViewController: ScenesTableViewController) {
        guard let viewController = self.instantiateViewController("SceneTableViewController") as? SceneTableViewController, let project = scene.project else { return }
        scenesTableViewController.project.activeScene = scene
        viewController.scene = scene
        viewController.project = scenesTableViewController.project
        viewController.stagePresenterVC = StagePresenterViewController()
        viewController.stagePresenterVC.stageManager = StageManager(project: project)

        viewController.sceneDelegate = scenesTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func openProjectDetails(projectId: String, storeProjectDownloader: StoreProjectDownloaderProtocol = StoreProjectDownloader()) {
        if let baseTableViewController = self as? BaseTableViewController {
            baseTableViewController.showLoadingView()
        }
        storeProjectDownloader.fetchProjectDetails(for: projectId, completion: {project, error in
            if let baseTableViewController = self as? BaseTableViewController {
                baseTableViewController.hideLoadingView()
            }

            guard error == nil else {
                Util.alert(text: kLocalizedUnableToLoadProject)
                return
            }
            guard let storeProject = project else {
                Util.alert(text: kLocalizedInvalidZip)
                return
            }
            let catrobatProject = storeProject.toCatrobatProject()

            guard let viewController = self.instantiateViewController("ProjectDetailStoreViewController") as? ProjectDetailStoreViewController else { return }
            viewController.project = catrobatProject
            self.navigationController?.pushViewController(viewController, animated: true)
        })
    }

    private func instantiateViewController(_ identifier: String) -> UIViewController? {
        let storyboard = UIStoryboard.init(name: "iPhone", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}

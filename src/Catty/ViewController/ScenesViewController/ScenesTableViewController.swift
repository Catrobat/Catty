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

import UIKit

class ScenesTableViewController: UITableViewController, SceneDelegate {
    var project = Project()
    var newScene = false
    var stagePresenterVC = StagePresenterViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = project.header.programName
        self.navigationItem.leftBarButtonItem?.title = kLocalizedProjects
        let edit = UIBarButtonItem(title: kLocalizedEdit, style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItems = [edit]
        setupToolBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
        self.tableView.reloadData()
        setupToolBar()
        if newScene {
            addNewSceneAllert()
        }
    }

    func addNewScene() {
        newScene = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { project.scenes.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = kImageCell
        var cell: UITableViewCell?

        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if !(cell?.conforms(to: CatrobatImageCell.self) ?? false) || !(cell is CatrobatBaseCell) {
            return cell!
        }

        if let imageCell = cell as? CatrobatBaseCell & CatrobatImageCell {
            ProjectManager.shared.loadSceneImage(scene: project.scenes[indexPath.row] as! Scene) { image in
                imageCell.iconImageView.image = image
            }
            imageCell.titleLabel.text = (project.scenes[indexPath.row] as AnyObject).name
            imageCell.setNeedsLayout()
            imageCell.iconImageView.contentMode = .scaleAspectFit
        }
        return cell!
    }

    @objc func editButtonTapped() {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let firstAction = UIAlertAction(title: kLocalizedRenameProject, style: .default) { _ in
            self.reanameProjectAlert()

        }

        let cancelAction = UIAlertAction(title: kLocalizedCancel, style: .cancel) { _ in }

        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true)
    }

    func reanameProjectAlert() {
        Util.askUser(forUniqueNameAndPerformAction: #selector(renameProject(inputProjectName:)),
                     target: self,
                     promptTitle: kLocalizedRenameProject,
                     promptMessage: "\(kLocalizedProjectName):",
                     promptValue: self.project.header.programName,
                     promptPlaceholder: kLocalizedEnterYourProjectNameHere,
                     minInputLength: UInt(kMinNumOfProjectNameCharacters),
                     maxInputLength: UInt(kMaxNumOfProjectNameCharacters),
                     invalidInputAlertMessage: kLocalizedProjectNameAlreadyExistsDescription,
                     existingNames: Project.allProjectNames())
    }

    @objc func addNewSceneAllert() {
        Util.askUser(forUniqueNameAndPerformAction: #selector(createNewScene(inputProjectName:)),
                     target: self,
                     promptTitle: "\(kLocalizedNew) \(kLocalizedScene)",
                     promptMessage: "\(kLocalizedNew) \(kLocalizedScene):",
                     promptValue: nil,
                     promptPlaceholder: "New Scene",
                     minInputLength: UInt(kMinNumOfProjectNameCharacters),
                     maxInputLength: UInt(kMaxNumOfProjectNameCharacters),
                     invalidInputAlertMessage: kLocalizedObjectNameAlreadyExistsDescription,
                     existingNames: self.project.scenes.map({ ($0 as! Scene).name }))
    }

    @objc func createNewScene(inputProjectName: String) {
        ProjectManager.shared.addNewScene(name: inputProjectName, project: self.project)
        self.project.saveToDisk(withNotification: false)
        self.tableView.reloadData()
    }

    @objc func renameProject(inputProjectName: String) {
        let newProjectName = Util.uniqueName(inputProjectName, existingNames: Project.allProjectNames())
        self.project.rename(toProjectName: newProjectName ?? self.project.header.programName, andShowSaveNotification: true)
        self.title = newProjectName
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { TableUtil.heightForImageCell() }

    @objc public func setObject(_ project: Project) {
        self.project = project
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openScene(self.project.scenes[indexPath.row] as! Scene, self)
    }

    func setupToolBar() {
        if #available(iOS 15.0, *) {
            let toolBarAppearance = UIToolbarAppearance()
            toolBarAppearance.backgroundColor = UIColor.toolBar

            if let navigationController = self.navigationController {
                navigationController.toolbar.standardAppearance = toolBarAppearance
                navigationController.toolbar.scrollEdgeAppearance = toolBarAppearance
            }
        }
        navigationController?.toolbar.tintAdjustmentMode = .normal
        navigationController?.toolbar.tintColor = UIColor.toolTint
        navigationController?.toolbar.barTintColor = UIColor.toolBar
        navigationController?.toolbar.backgroundColor = UIColor.toolBar

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewSceneAllert))
        let play = PlayButton(target: self, action: #selector(playSceneAction))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbarItems = [flex, add, flex, flex, play, flex]
    }

    @objc func playSceneAction(_ sender: Any) {

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.enabledOrientation = true
        }

        let landscapeMode = ProjectManager.shared.currentProject.header.landscapeMode

        DispatchQueue.main.async {
            if !landscapeMode {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
            if let navigationController = self.navigationController {
                self.stagePresenterVC.playScene(to: navigationController)
            }

        }
    }
}
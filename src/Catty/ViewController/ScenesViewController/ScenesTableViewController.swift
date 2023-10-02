/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class ScenesTableViewController: UITableViewController, AddNewSceneDelegate {

    func addNewScene() {
        newScene = true
    }

    var project = Project()
    var newScene = false
    let stagePresenterViewController = StagePresenterViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scenes" // maybe project.header.programName is better
        self.navigationItem.leftBarButtonItem?.title = kLocalizedProjects
        let edit = UIBarButtonItem(title: kLocalizedEdit, style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItems = [edit]
        stagePresenterViewController.project = project
        setupToolBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
        self.tableView.reloadData()
        setupToolBar()
        if newScene {
            createNewScene()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {return 1}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return project.scenes.count}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = kImageCell
        var cell: UITableViewCell?

        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if !(cell?.conforms(to: CatrobatImageCell.self) ?? false) || !(cell is CatrobatBaseCell) {
            return cell!
        }

        if let imageCell = cell as? CatrobatBaseCell & CatrobatImageCell {
           ProjectManager.shared.loadSceneImage(scene: project.scenes[indexPath.row] as! Scene) { [weak self] image in
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

        let firstAction = UIAlertAction(title: "\(kLocalizedNew) \(kLocalizedScene)", style: .default) { _ in
            self.createNewScene()
        }

        let cancelAction = UIAlertAction(title: kLocalizedCancel, style: .cancel) { _ in }

        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { TableUtil.heightForImageCell() }

    @objc public func setObject(_ project: Project) {
        self.project = project
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openScene(self.project.scenes[indexPath.row] as! Scene, self)
    }

    @objc func createNewScene() {

        let addNewSceneAlert = UIAlertController(title: "\(kLocalizedNew) \(kLocalizedScene)", message: nil, preferredStyle: .alert)
        addNewSceneAlert.addTextField()
        let errorAlert = UIAlertController(title: kLocalizedPocketCode, message: kLocalizedObjectNameAlreadyExistsDescription, preferredStyle: .alert)

        let cancelActionErrorAlert = UIAlertAction(title: kLocalizedOK, style: .default) { _ in
            self.present(addNewSceneAlert, animated: true, completion: nil)
        }
        errorAlert.addAction(cancelActionErrorAlert)

        let submitAction = UIAlertAction(title: kLocalizedOK, style: .default) { _ in
            let answer = addNewSceneAlert.textFields![0]

            if let name = answer.text {
                if self.project.scenes.map({ ($0 as! Scene).name }).contains(name) {
                    self.present(errorAlert, animated: true)
                } else {
                    ProjectManager.shared.addNewScene(name: name, project: self.project)
                    self.saveProject()
                    self.tableView.reloadData()
                }
            }
        }

        let cancelAction = UIAlertAction(title: kLocalizedCancel, style: .cancel) { _ in
        }
        newScene = false
        addNewSceneAlert.addAction(cancelAction)
        addNewSceneAlert.addAction(submitAction)
        present(addNewSceneAlert, animated: true, completion: nil)
    }

    func saveProject() {
        self.project.saveToDisk(withNotification: false)
    }

    func setupToolBar() {

        navigationController?.toolbar.tintAdjustmentMode = .normal
        navigationController?.toolbar.tintColor = UIColor.toolTint
        navigationController?.toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        navigationController?.toolbar.backgroundColor = UIColor.toolBar
        navigationController?.toolbar.barStyle = .default

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewScene))
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
                self.stagePresenterViewController.playScene(to: navigationController) {
                }
            }

        }
    }

}

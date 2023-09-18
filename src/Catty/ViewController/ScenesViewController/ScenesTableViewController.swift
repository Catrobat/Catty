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

class ScenesTableViewController: UITableViewController {

    var scenes: [Scene] = []
    var project: Project = Project()
    var addNewScene: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = project.header.programName
    }
    override func viewWillAppear(_ animated: Bool) {
        if addNewScene {
            createNewScene()
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {return 1}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return scenes.count}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = scenes[indexPath.row].name
        return cell

    }

    @objc public func setObject(_ project: Project) {
        self.project = project
        self.scenes = project.scenes as! [Scene]
        self.addNewScene = true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openScene(self.scenes[indexPath.row], self.project)
    }

    func createNewScene() {
        let ac = UIAlertController(title: "Scene name", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Ok", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            if let name = answer.text {
                let newScene = Scene(name: name)
                newScene.project = self.project
                self.scenes.append(newScene)
                self.addNewScene = false
                self.project.scenes.add(newScene)
                self.saveProject()
                self.tableView.reloadData()
            }
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    func saveProject() {
        self.project.saveToDisk(withNotification: false)

    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

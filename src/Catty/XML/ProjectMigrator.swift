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

@objcMembers class ProjectMigrator: NSObject, ProjectMigratorProtocol {

    static let minimumCatrobatLanguageVersionForScenes: Float = 0.992
    var fileManager: CBFileManager

    init(fileManager: CBFileManager) {
        self.fileManager = fileManager
    }

    func migrateToScene(project: Project) throws {

        guard let versionNumber = Float(project.header.catrobatLanguageVersion) else {
            throw ProjectMigratorError.unknown(description: "Unable to convert version number to Float")
        }

        if versionNumber < ProjectMigrator.minimumCatrobatLanguageVersionForScenes {
            throw ProjectMigratorError.unsupportedCatrobatLanguageVersion
        }

        let projectPath = project.projectPath()

        if !fileManager.directoryExists(projectPath) {
            throw ProjectMigratorError.pathNotFound
        }

        let directoryPath = projectPath + Util.defaultSceneName(forSceneNumber: 1)

        if !fileManager.directoryExists(directoryPath) {
            fileManager.createDirectory(directoryPath)
        }

        if fileManager.directoryExists(directoryPath) {
            self.moveDirectoryOrCopyFileToSceneDirectory(for: kScreenshotAutoFilename, projectPath: projectPath)
            self.moveDirectoryOrCopyFileToSceneDirectory(for: kProjectImagesDirName, projectPath: projectPath)
            self.moveDirectoryOrCopyFileToSceneDirectory(for: kProjectSoundsDirName, projectPath: projectPath)
            self.moveDirectoryOrCopyFileToSceneDirectory(for: kScreenshotManualFilename, projectPath: projectPath)
            self.moveDirectoryOrCopyFileToSceneDirectory(for: kScreenshotFilename, projectPath: projectPath)
        } else {
            throw ProjectMigratorError.unknown(description: "Unable to create \(kLocalizedScene) directory")
        }
    }

    private func moveDirectoryOrCopyFileToSceneDirectory(for projectResouceName: String, projectPath: String) {
        let fileOrDirectoryAtPath = projectPath + projectResouceName
        let fileOrDirectoryToPath = "\(projectPath + Util.defaultSceneName(forSceneNumber: 1))/\(projectResouceName)"

        if fileManager.fileExists(fileOrDirectoryAtPath) {

            fileManager.copyExistingFile(atPath: fileOrDirectoryAtPath, toPath: fileOrDirectoryToPath, overwrite: false)

        } else if fileManager.directoryExists(fileOrDirectoryAtPath) {

            fileManager.moveExistingDirectory(atPath: fileOrDirectoryAtPath, toPath: fileOrDirectoryToPath)

        }
    }
}

enum ProjectMigratorError: Error, Equatable {

    case unsupportedCatrobatLanguageVersion

    case pathNotFound

    case unknown(description: String)
}

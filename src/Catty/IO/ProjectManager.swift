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

@objc open class ProjectManager: NSObject {

    @objc static let shared = ProjectManager()

    @objc public var currentProject = Project.lastUsed()
    private let fileManager: CBFileManager
    private let imageCache: RuntimeImageCache

    public init(fileManager: CBFileManager = CBFileManager.shared(), imageCache: RuntimeImageCache = RuntimeImageCache.shared()) {
        self.fileManager = fileManager
        self.imageCache = imageCache
     }

    @objc func createProject(name: String, projectId: String?) -> Project {
        let project = Project()
        let projectName = Util.uniqueName(name, existingNames: Project.allProjectNames())
        project.header = Header.default()
        project.header.programName = projectName
        project.header.programID = projectId

        addNewScene(name: Util.defaultSceneName(forSceneNumber: 1), project: project)
        return project
    }

    func addNewScene(name: String, project: Project) {

        let scene = Scene(name: name)
        scene.project = project

        if fileManager.directoryExists(project.header.programName) == false {
               fileManager.createDirectory(project.projectPath())
           }

        let sceneDir = scene.path()
        if !fileManager.directoryExists(sceneDir) {
            fileManager.createDirectory(sceneDir)
        }

        let imagesDirName = scene.imagesPath()
        if fileManager.directoryExists(imagesDirName) == false {
            fileManager.createDirectory(imagesDirName)
        }

        let soundDirName = scene.soundsPath()
        if fileManager.directoryExists(soundDirName) == false {
            fileManager.createDirectory(soundDirName)
        }
        scene.addObject(withName: kLocalizedBackground)

        project.scenes.add(scene)
        
        guard let scenePath = scene.path() else { return }
        let filePath = scenePath + kScreenshotAutoFilename
        let projectIconNames = UIDefines.defaultScreenshots
        let randomIndex = Int(arc4random_uniform(UInt32(projectIconNames.count)))

        guard let defaultScreenshotImage = UIImage(named: projectIconNames[randomIndex]) else {
            debugPrint("Could not find image named \(projectIconNames[randomIndex])")
            return
        }

        guard let data = defaultScreenshotImage.pngData() else {
            return
        }

        fileManager.writeData(data, path: filePath)
        imageCache.clear()

    }

    func loadSceneImage(scene: Scene, completion: @escaping (_ image: UIImage?) -> Void) {

        guard let scenePath = scene.path() else {
            completion(UIImage(named: "catrobat"))
            return
        }

        let fallbackPaths = [
            scenePath + kScreenshotFilename,
            scenePath + kScreenshotManualFilename,
            scenePath + kScreenshotAutoFilename
        ]

        for imagePath in fallbackPaths {
            let image = imageCache.cachedImage(forPath: imagePath, andSize: UIDefines.previewImageSize)
            if image != nil {
                completion(image)
                return
            }
        }

        DispatchQueue.global(qos: .default).async {
            for imagePath in fallbackPaths where self.fileManager.fileExists(imagePath as String) {
                self.imageCache.loadImageFromDisk(
                    withPath: imagePath,
                    andSize: UIDefines.previewImageSize,
                    onCompletion: { image, _ in completion(image) }
                )
                return
            }
            completion(UIImage(named: "catrobat"))
        }
        return
    }

    @objc func loadPreviewImageAndCache(projectLoadingInfo: ProjectLoadingInfo, completion: @escaping (_ image: UIImage?, _ path: String?) -> Void) {
        let fallbackPaths = [
            projectLoadingInfo.basePath + kScreenshotFilename,
            projectLoadingInfo.basePath + kScreenshotManualFilename,
            projectLoadingInfo.basePath + kScreenshotAutoFilename
        ]

        for imagePath in fallbackPaths {
            if let image = imageCache.cachedImage(forPath: imagePath, andSize: UIDefines.previewImageSize) {
                completion(image, imagePath)
                return
            }
        }

        DispatchQueue.global(qos: .default).async {
            for imagePath in fallbackPaths where self.fileManager.fileExists(imagePath as String) {
                self.imageCache.loadImageFromDisk(
                    withPath: imagePath,
                    andSize: UIDefines.previewImageSize,
                    onCompletion: { image, path in completion(image, path) }
                )
                return
            }
            completion(UIImage(named: "catrobat"), nil)
        }

        return
    }

    func projectNames(for projectID: String) -> [String]? {
        if projectID.isEmpty {
            return nil
        }

        var projectNames = [String]()
        let allProjectLoadingInfos = Project.allProjectLoadingInfos()
        for case let projectLoadingInfo as ProjectLoadingInfo in allProjectLoadingInfos where projectLoadingInfo.projectID == projectID {
            projectNames.append(projectLoadingInfo.visibleName)
        }

        if projectNames.isEmpty {
            return nil
        }

        return projectNames
    }

    func addProjectFromFile(url: URL) -> Project? {
        let tempProjectName = String(Date().timeIntervalSinceReferenceDate) + url.lastPathComponent
        let path = url.path
        var newProject: NSData?

        if url.startAccessingSecurityScopedResource() {
            newProject = NSData.init(contentsOfFile: path)
            url.stopAccessingSecurityScopedResource()
        }

        if newProject == nil {
            Util.alert(text: kLocalizedUnableToImportProject)
            return nil
        }

        self.fileManager.unzipAndStore(newProject as Data?, withProjectID: nil, withName: tempProjectName)

        return getProjectNameAndRename(tempProjectName: tempProjectName)
    }

    func getProjectNameAndRename(tempProjectName: String) -> Project? {
        guard let projectLoadingInfo = ProjectLoadingInfo(forProjectWithName: tempProjectName, projectID: kNoProjectIDYetPlaceholder) else {
            Project.removeProjectFromDisk(withProjectName: tempProjectName, projectID: kNoProjectIDYetPlaceholder)
            Util.alert(text: kLocalizedUnableToImportProject)
            return nil
        }
        projectLoadingInfo.useOriginalName = true

        guard let projectObject = Project(loadingInfo: projectLoadingInfo),
              let newProjectName = Util.uniqueName(projectObject.header.programName, existingNames: Project.allProjectNames()) else {
            Project.removeProjectFromDisk(withProjectName: tempProjectName, projectID: kNoProjectIDYetPlaceholder)
            Util.alert(text: kLocalizedUnableToImportProject)
            return nil
        }

        projectLoadingInfo.useOriginalName = false

        let project = Project(loadingInfo: projectLoadingInfo)
        project?.rename(toProjectName: newProjectName, andShowSaveNotification: false)

        return project
    }

    @objc func removeObjects(_ project: Project, objects: [SpriteObject]) {
        guard let scene = project.scenes[0] as? Scene else {return}
        for object in objects where scene.objects().contains(object) {
            scene.removeObject(object)
        }
        project.saveToDisk(withNotification: true)
    }
}

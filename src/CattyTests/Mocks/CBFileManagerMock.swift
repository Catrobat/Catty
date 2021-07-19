/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@testable import Pocket_Code

final class CBFileManagerMock: CBFileManager {
    var dataWritten: [String: Data]
    var downloadedProjectsStored: [String: String]
    var readWillFail = false
    var writeWillFail = false

    var existingFiles: [String]
    var existingDirectories: [String]
    private var zipData: Data?

    init(filePath: [String], directoryPath: [String]) {
        self.existingFiles = filePath
        self.existingDirectories = directoryPath
        self.dataWritten = [:]
        self.downloadedProjectsStored = [:]
    }

    convenience init(zipData: Data) {
        self.init(filePath: [String](), directoryPath: [String]())
        self.zipData = zipData
    }

    override convenience init() {
        self.init(filePath: [], directoryPath: [])
    }

    override func fileExists(_ path: String) -> Bool {
        existingFiles.contains(path)
    }

    override func directoryExists(_ path: String) -> Bool {
        existingDirectories.contains(path)
    }

    override func createDirectory(_ path: String) {
        self.existingDirectories.append(path)
    }

    override func moveExistingDirectory(atPath oldPath: String, toPath newPath: String) {
        for i in 0..<existingDirectories.count where oldPath == self.existingDirectories[i] {
            self.existingDirectories[i] = newPath
        }
    }

    override func moveExistingFile(atPath oldPath: String, toPath newPath: String, overwrite: Bool) {
        for i in 0..<self.existingFiles.count where oldPath == existingFiles[i] {
            self.existingFiles[i] = newPath
        }
    }

    override func copyExistingFile(atPath oldPath: String!, toPath newPath: String!, overwrite: Bool) {
        if existingFiles.contains(oldPath) {
            self.existingFiles.append(newPath)
        }
    }

    override func zip(_ project: Project) -> Data? {
        zipData
    }

    override func writeData(_ data: Data, path: String) {
        if !existingFiles.contains(path) {
            existingFiles.append(path)
            dataWritten[path] = data
        }
    }

    override func storeDownloadedProject(_ data: Data!, withID projectId: String!, andName projectName: String!) -> Bool {
        downloadedProjectsStored[projectId] = projectName
        return true
    }

    override func read(_ path: String!) -> Data? {
        readWillFail == true ? nil : super.read(path)
    }

    override func write(_ data: Data, toPath: String!) -> Bool {
        if writeWillFail {
            return false
        }
        return true
    }
}

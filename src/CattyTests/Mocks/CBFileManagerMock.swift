/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
    private var existingFiles: [String]
    private var existingDirectories: [String]
    private var zipData: Data?
    private var imageCacheMock: RuntimeImageCache?

    override var imageCache: RuntimeImageCache {
        guard let imageCache = imageCacheMock else { return RuntimeImageCache.shared() }
        return imageCache
    }

    init(filePath: [String], directoryPath: [String]) {
        self.existingFiles = filePath
        self.existingDirectories = directoryPath
    }

    convenience init(zipData: Data) {
        self.init(filePath: [String](), directoryPath: [String]())
        self.zipData = zipData
    }

    convenience init(imageCache: RuntimeImageCache) {
        self.init(filePath: [], directoryPath: [])
        self.imageCacheMock = imageCache
    }

    convenience init(imageCache: RuntimeImageCache, filePath: [String]) {
        self.init(filePath: filePath, directoryPath: [])
        self.imageCacheMock = imageCache
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

    override func writeData(_ data: Data, path: String) {
        if !existingFiles.contains(path) {
            existingFiles.append(path)
        }
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

}

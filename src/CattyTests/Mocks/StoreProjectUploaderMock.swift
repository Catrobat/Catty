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

final class StoreProjectUploaderMock: StoreProjectUploaderProtocol {

    var error: StoreProjectUploaderError?
    var progress: Float = 0
    var timesUploadMethodCalled: Int = 0
    var timesFetchTagsMethodCalled: Int = 0
    var projectToUpload: Project?
    var language: String?
    var projectId: String?
    var tags: [String]?

    func upload(project: Project, completion: @escaping (String?, StoreProjectUploaderError?) -> Void, progression: ((Float) -> Void)?) {
        timesUploadMethodCalled += 1
        projectToUpload = project

        completion(self.projectId, self.error)
        if let progression = progression {
            progression(self.progress)
        }
    }

    func fetchTags(for language: String, completion: @escaping ([String], StoreProjectUploaderError?) -> Void) {
        self.language = language
        timesFetchTagsMethodCalled += 1

        if let tags = tags {
            completion(tags, self.error)
        }
    }
}

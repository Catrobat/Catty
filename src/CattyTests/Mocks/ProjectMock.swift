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

class ProjectMock: Project {

    private var mockedRequiredResources: Int = 0
    public var saveNotificationShown: Bool = false

    override convenience init() {
        self.init(width: 300, andHeight: 400)
    }

    convenience init(requiredResources: Int) {
        self.init(width: 300, andHeight: 400, andRequiredResources: requiredResources)
    }

    convenience init(width: CGFloat, andHeight: CGFloat) {
        self.init(width: width, andHeight: andHeight, andRequiredResources: ResourceType.noResources.rawValue)
    }

    required init(width: CGFloat, andHeight: CGFloat, andRequiredResources: Int) {
        super.init()
        self.header = Header()
        self.header.screenWidth = NSNumber(value: Float(width))
        self.header.screenHeight = NSNumber(value: Float(andHeight))
        self.mockedRequiredResources = andRequiredResources
    }

    override func getRequiredResources() -> Int {
        return mockedRequiredResources
    }

    override func rename(toProjectName projectName: String, andShowSaveNotification showSaveNotification: Bool) {
        self.saveNotificationShown = showSaveNotification
        super.rename(toProjectName: projectName, andShowSaveNotification: showSaveNotification)
    }
}

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

extension Notification.Name {

    static var alertDidAppear: Notification.Name {
        return .init(rawValue: NotificationName.alertDidAppear)
    }

    static var baseTableViewControllerDidAppear: Notification.Name {
        return .init(rawValue: NotificationName.baseTableViewControllerDidAppear)
    }

    static var baseCollectionViewControllerDidAppear: Notification.Name {
        return .init(rawValue: NotificationName.baseCollectionViewControllerDidAppear)
    }

    static var paintViewControllerDidAppear: Notification.Name {
        return .init(rawValue: NotificationName.paintViewControllerDidAppear)
    }

    static var formulaEditorControllerDidAppear: Notification.Name {
        return .init(rawValue: NotificationName.formulaEditorControllerDidAppear)
    }

    static var scenePresenterViewControllerDidAppear: Notification.Name {
        return .init(rawValue: NotificationName.scenePresenterViewControllerDidAppear)
    }

    static var brickSelected: Notification.Name {
        return .init(rawValue: NotificationName.brickSelected)
    }

    static var projectInvalidVersion: Notification.Name {
        return .init(rawValue: NotificationName.projectInvalidVersion)
    }

    static var projectInvalidXml: Notification.Name {
        return .init(rawValue: NotificationName.projectInvalidXml)
    }

    static var projectFetchDetailsFailure: Notification.Name {
        return .init(rawValue: NotificationName.projectFetchDetailsFailure)
    }
}

@objcMembers
public class NotificationName: NSObject {

    public static let alertDidAppear = "CustomAlertController.didAppear"
    public static let baseTableViewControllerDidAppear = "BaseTableViewController.didAppear"
    public static let baseCollectionViewControllerDidAppear = "BaseCollectionViewController.didAppear"
    public static let paintViewControllerDidAppear = "PaintViewController.didAppear"
    public static let formulaEditorControllerDidAppear = "FormulaEditorViewController.didAppear"
    public static let scenePresenterViewControllerDidAppear = "ScenePresenterViewController.didAppear"
    public static let brickSelected = "BrickCategoryViewController.brickSelected"
    public static let projectInvalidVersion = "Project.invalidVersion"
    public static let projectInvalidXml = "Project.invalidXml"
    public static let projectFetchDetailsFailure = "Project.fetchDetailsFailure"
}

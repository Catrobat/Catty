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

    static var alertDidAppear: Notification.Name { .init(rawValue: NotificationName.alertDidAppear) }
    static var baseTableViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.baseTableViewControllerDidAppear) }
    static var baseCollectionViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.baseCollectionViewControllerDidAppear) }
    static var paintViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.paintViewControllerDidAppear) }
    static var formulaEditorControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.formulaEditorControllerDidAppear) }
    static var scenePresenterViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.scenePresenterViewControllerDidAppear) }
    static var brickSelected: Notification.Name { .init(rawValue: NotificationName.brickSelected) }
    static var projectInvalidVersion: Notification.Name { .init(rawValue: NotificationName.projectInvalidVersion) }
    static var projectInvalidXml: Notification.Name { .init(rawValue: NotificationName.projectInvalidXml) }
    static var projectFetchFailure: Notification.Name { .init(rawValue: NotificationName.projectFetchFailure) }
    static var projectFetchDetailsFailure: Notification.Name { .init(rawValue: NotificationName.projectFetchDetailsFailure) }
    static var projectSearchFailure: Notification.Name { .init(rawValue: NotificationName.projectSearchFailure) }
    static var settingsCrashReportingChanged: Notification.Name { .init(rawValue: NotificationName.settingsCrashReportingChanged) }
    static var mediaLibraryDownloadIndexFailure: Notification.Name { .init(rawValue: NotificationName.mediaLibraryDownloadIndexFailure) }
    static var mediaLibraryDownloadDataFailure: Notification.Name { .init(rawValue: NotificationName.mediaLibraryDownloadDataFailure) }
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
    public static let projectFetchFailure = "Project.fetchFailure"
    public static let projectFetchDetailsFailure = "Project.fetchDetailsFailure"
    public static let projectSearchFailure = "Project.searchFailure"
    public static let settingsCrashReportingChanged = "SettingsTableViewController.crashReportingChanged"
    public static let mediaLibraryDownloadIndexFailure = "MediaLibrary.DownloadIndexFailure"
    public static let mediaLibraryDownloadDataFailure = "MediaLibrary.DownloadDataFailure"
}

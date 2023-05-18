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

extension Notification.Name {

    static var alertDidAppear: Notification.Name { .init(rawValue: NotificationName.alertDidAppear) }
    static var baseTableViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.baseTableViewControllerDidAppear) }
    static var baseCollectionViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.baseCollectionViewControllerDidAppear) }
    static var paintViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.paintViewControllerDidAppear) }
    static var formulaEditorControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.formulaEditorControllerDidAppear) }
    static var stagePresenterViewControllerDidAppear: Notification.Name { .init(rawValue: NotificationName.stagePresenterViewControllerDidAppear) }
    static var brickSelected: Notification.Name { .init(rawValue: NotificationName.brickSelected) }
    static var brickRemoved: Notification.Name { .init(rawValue: NotificationName.brickRemoved) }
    static var brickEnabled: Notification.Name { .init(rawValue: NotificationName.brickEnabled) }
    static var brickDisabled: Notification.Name { .init(rawValue: NotificationName.brickDisabled) }
    static var scriptEnabled: Notification.Name { .init(rawValue: NotificationName.scriptEnabled) }
    static var scriptDisabled: Notification.Name { .init(rawValue: NotificationName.scriptDisabled) }
    static var projectInvalidVersion: Notification.Name { .init(rawValue: NotificationName.projectInvalidVersion) }
    static var projectInvalidXml: Notification.Name { .init(rawValue: NotificationName.projectInvalidXml) }
    static var projectXmlTooLarge: Notification.Name { .init(rawValue: NotificationName.projectXmlTooLarge) }
    static var projectFetchFailure: Notification.Name { .init(rawValue: NotificationName.projectFetchFailure) }
    static var projectFetchDetailsFailure: Notification.Name { .init(rawValue: NotificationName.projectFetchDetailsFailure) }
    static var projectSearchFailure: Notification.Name { .init(rawValue: NotificationName.projectSearchFailure) }
    static var projectDownloadFailure: Notification.Name { .init(rawValue: NotificationName.projectDownloadFailure) }
    static var settingsCrashReportingChanged: Notification.Name { .init(rawValue: NotificationName.settingsCrashReportingChanged) }
    static var mediaLibraryDownloadIndexFailure: Notification.Name { .init(rawValue: NotificationName.mediaLibraryDownloadIndexFailure) }
    static var mediaLibraryDownloadDataFailure: Notification.Name { .init(rawValue: NotificationName.mediaLibraryDownloadDataFailure) }
    static var formulaSaved: Notification.Name { .init(rawValue: NotificationName.formulaSaved) }
}

@objcMembers
public class NotificationName: NSObject {

    public static let alertDidAppear = "CustomAlertController.didAppear"
    public static let baseTableViewControllerDidAppear = "BaseTableViewController.didAppear"
    public static let baseCollectionViewControllerDidAppear = "BaseCollectionViewController.didAppear"
    public static let paintViewControllerDidAppear = "PaintViewController.didAppear"
    public static let formulaEditorControllerDidAppear = "FormulaEditorViewController.didAppear"
    public static let stagePresenterViewControllerDidAppear = "StagePresenterViewController.didAppear"
    public static let brickSelected = "BrickCategoryViewController.brickSelected"
    public static let brickRemoved = "BrickCategoryViewController.brickRemoved"
    public static let brickEnabled = "BrickCategoryViewController.brickEnabled"
    public static let brickDisabled = "BrickCategoryViewController.brickDisabled"
    public static let scriptEnabled = "BrickCategoryViewController.scriptEnabled"
    public static let scriptDisabled = "BrickCategoryViewController.scriptDisabled"
    public static let projectInvalidVersion = "Project.invalidVersion"
    public static let projectInvalidXml = "Project.invalidXml"
    public static let projectXmlTooLarge = "Project.xmlTooLarge"
    public static let projectFetchFailure = "Project.fetchFailure"
    public static let projectFetchDetailsFailure = "Project.fetchDetailsFailure"
    public static let projectSearchFailure = "Project.searchFailure"
    public static let projectDownloadFailure = "Project.downloadFailure"
    public static let settingsCrashReportingChanged = "SettingsTableViewController.crashReportingChanged"
    public static let mediaLibraryDownloadIndexFailure = "MediaLibrary.DownloadIndexFailure"
    public static let mediaLibraryDownloadDataFailure = "MediaLibrary.DownloadDataFailure"
    public static let projectDownloaded = "ProjectDownloaded"
    public static let hideLoadingView = "HideLoadingView"
    public static let showSaved = "ShowSavedView"
    public static let readyToUpload = "ReadyToUpload"
    public static let formulaSaved = "FormulaEditorViewController.saveIfPossible"
}

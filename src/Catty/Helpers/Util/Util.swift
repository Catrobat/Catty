/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

import Foundation

func synchronized(lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

@objc extension Util {

    class func appName() -> String? {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        return appName
    }

    class func appVersion() -> String? {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion
    }

    class func appBuildName() -> String? {
        let appBuildName = Bundle.main.infoDictionary?["CatrobatBuildName"] as? String
        return appBuildName
    }

    class func appBuildVersion() -> String? {
        let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return appBuildVersion
    }

    @objc(alertWithText:)
    class func alert(text: String) {
        alert(title: kLocalizedPocketCode, text: text)
    }

    @objc(alertWithTitle:andText:)
    class func alert(title: String, text: String) {
        AlertControllerBuilder.alert(title: title, message: text)
            .addCancelAction(title: kLocalizedOK, handler: nil)
            .build().showWithController(Util.topmostViewController())
    }

    @objc(allMessagesForProject:)
    class func allMessages(for project: Project) -> NSOrderedSet {
        guard let allBroadcastMessages = project.allBroadcastMessages?.array else {
            return []
        }
        let messages = NSMutableOrderedSet(array: allBroadcastMessages)

        for object in project.allObjects() {
            for script in object.scriptList {
                if let broadcastScript = script as? BroadcastScript {
                    if let receivedMessage = broadcastScript.receivedMessage {
                        messages.add(receivedMessage)
                    }
                }
                if let script = script as? Script {
                    for brick in script.brickList {
                        if let broadcastBrick = brick as? BroadcastBrick {
                            messages.add(broadcastBrick.broadcastMessage)
                        } else if let broadcastBrick = brick as? BroadcastWaitBrick {
                            messages.add(broadcastBrick.broadcastMessage)
                        }
                    }
                }
            }
        }

        // Return immutable set, because adding items afterwards would have no effect
        return NSOrderedSet(orderedSet: messages)
    }

    class func catrobatLanguageVersion() -> String {
        let catrobatLanguageVersion = Bundle.main.infoDictionary?["CatrobatLanguageVersion"] as! String
        return catrobatLanguageVersion
    }

    class func catrobatMediaLicense() -> String? {
        let catrobatMediaLicense = Bundle.main.infoDictionary?["CatrobatMediaLicense"] as? String
        return catrobatMediaLicense
    }

    class func catrobatProgramLicense() -> String? {
        let catrobatProgramLicense = Bundle.main.infoDictionary?["CatrobatProgramLicense"] as? String
        return catrobatProgramLicense
    }

    class func deviceName() -> String {
        // From https://stackoverflow.com/a/26962452
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    class func defaultAlertForNetworkError() {
        if Thread.isMainThread {
            alert(text: kLocalizedErrorInternetConnection)
        } else {
            DispatchQueue.main.async(execute: {
                Util.defaultAlertForNetworkError()
            })
        }
    }

    class func defaultAlertForUnknownError() {
        if Thread.isMainThread {
            alert(text: kLocalizedErrorUnknown)
        } else {
            DispatchQueue.main.async(execute: {
                Util.defaultAlertForUnknownError()
            })
        }
    }

    @objc(lookWithName:forObject:)
    class func look(with name: String, for object: SpriteObject) -> Look? {
        guard let lookList = object.lookList else {
            return nil
        }

        for look in lookList {
            if let look = look as? Look, look.name == name {
                return look
            }
        }

        return nil
    }

    @objc(objectWithName:forScene:)
    class func object(with name: String, for scene: Scene) -> SpriteObject? {
        for object in scene.objects() where object.name == name {
            return object
        }

        return nil
    }

    class func platformName() -> String? {
        let platformName = Bundle.main.infoDictionary?["CatrobatPlatformName"] as? String
        return platformName
    }

    class func platformVersion() -> OperatingSystemVersion {
        let platformVersion = ProcessInfo.processInfo.operatingSystemVersion
        return platformVersion
    }

    class func platformVersionWithPatch() -> String {
        let os = self.platformVersion()
        let major = String(format: "%ld", os.majorVersion)
        let minor = String(format: "%ld", os.minorVersion)
        let patch = String(format: "%ld", os.patchVersion)
        let platformVersionWithPatch = "\(major).\(minor).\(patch)" as String
        return platformVersionWithPatch
    }

    class func platformVersionWithoutPatch() -> String {
        let os = self.platformVersion()
        let major = String(format: "%ld", os.majorVersion)
        let minor = String(format: "%ld", os.minorVersion)
        let platformVersionWithoutPatch = "\(major).\(minor)" as String
        return platformVersionWithoutPatch
    }

    class func screenSize(_ inPixel: Bool) -> CGSize {
        var screenSize = inPixel ? UIScreen.main.nativeBounds.size : UIScreen.main.bounds.size

        if inPixel && UIScreen.main.bounds.height == UIDefines.iPhone6PScreenHeight {
            let iPhonePlusDownsamplingFactor = CGFloat(1.15)
            screenSize.height /= iPhonePlusDownsamplingFactor
            screenSize.width /= iPhonePlusDownsamplingFactor
        }

        return screenSize
    }

    class func screenHeight(_ inPixel: Bool) -> CGFloat {
        let screenHeight = self.screenSize(inPixel).height
        return screenHeight
    }

    class func screenWidth(_ inPixel: Bool) -> CGFloat {
        let screenWidth = self.screenSize(inPixel).width
        return screenWidth
    }

    class func screenHeight() -> CGFloat {
        let screenHeight = self.screenSize(false).height
        return screenHeight
    }

    class func screenWidth() -> CGFloat {
        let screenWidth = self.screenSize(false).width
        return screenWidth
    }

    class func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return min(statusBarSize.width, statusBarSize.height)
    }

    class func showNotification(withMessage message: String?) {
        guard let hud = BDKNotifyHUD(image: nil, text: message) else {
            return
        }

        let vc = Util.topmostViewController()
        if vc.view == nil {
            return
        }

        hud.destinationOpacity = UIDefines.bdkNotifyHUDDestinationOpacity
        hud.center = CGPoint(x: vc.view.center.x, y: vc.view.center.y)

        vc.view.addSubview(hud)
        hud.present(withDuration: UIDefines.bdkNotifyHUDPresentationDuration,
                    speed: UIDefines.bdkNotifyHUDPresentationSpeed,
                    in: vc.view,
                    completion: {
                        hud.removeFromSuperview()
                    })
    }

    class func showNotificationForSaveAction() {
        guard let hud = BDKNotifyHUD(image: UIImage(named: UIDefines.bdkNotifyHUDCheckmarkImageName), text: kLocalizedSaved) else {
            return
        }

        let vc = Util.topmostViewController()
        if vc.view == nil {
            return
        }

        hud.destinationOpacity = UIDefines.bdkNotifyHUDDestinationOpacity
        hud.center = CGPoint(x: vc.view.center.x,
                             y: vc.view.center.y + UIDefines.bdkNotifyHUDCenterOffsetY)
        hud.tag = UIDefines.savedViewTag

        vc.view.addSubview(hud)
        hud.present(withDuration: UIDefines.bdkNotifyHUDPresentationDuration,
                    speed: UIDefines.bdkNotifyHUDPresentationSpeed,
                    in: vc.view,
                    completion: {
                        hud.removeFromSuperview()
                    })
    }

    @objc(soundWithName:forObject:)
    class func sound(with name: String, for object: SpriteObject) -> Sound? {
        guard let soundList = object.soundList else {
            return nil
        }

        for sound in soundList {
            if let sound = sound as? Sound, sound.name == name {
                return sound
            }
        }
        return nil
    }

    static func uniqueName(_ nameToCheck: String, existingNames: [String]) -> String {
        var baseName = nameToCheck.trimmingCharacters(in: .whitespaces)

        if !existingNames.contains(baseName) {
            return baseName
        }

        var counter = 0
        let regex = try? NSRegularExpression(pattern: "\\((\\d+)\\)$", options: [])
        if let match = regex?.firstMatch(in: baseName, options: [], range: NSRange(location: 0, length: baseName.count)) {
            let numberStr = (baseName as NSString).substring(with: match.range(at: 1))
            counter = Int(numberStr) ?? 0
            baseName = (baseName as NSString).substring(to: match.range.location)
            baseName = baseName.trimmingCharacters(in: .whitespaces)
        }

        var uniqueName: String
        repeat {
            counter += 1
            uniqueName = "\(baseName) (\(counter))"
        } while existingNames.contains(uniqueName)

        return uniqueName
    }
}

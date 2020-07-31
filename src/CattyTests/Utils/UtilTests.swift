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

import XCTest

@testable import Pocket_Code

final class UtilTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var script: Script!
    var broadcastScript: BroadcastScript!
    var broadcastBrick: BroadcastBrick!
    var broadcastWaitBrick: BroadcastWaitBrick!

    override func setUp() {

        project = Project()
        project.scene = Scene()

        super.setUp()
    }

    func testScreenSize() {
        let screenSizeInPoints = UIScreen.main.bounds.size
        let screenSizeInPixel = mainScreenSizeInPixel()

        XCTAssertEqual(screenSizeInPoints, Util.screenSize(false))
        XCTAssertEqual(screenSizeInPixel, Util.screenSize(true))
        XCTAssertNotEqual(screenSizeInPixel, screenSizeInPoints)
    }

    func testScreenWidth() {
        let screenWidthInPoints = UIScreen.main.bounds.size.width
        let screenSizeInPixel = mainScreenSizeInPixel()

        XCTAssertEqual(screenWidthInPoints, Util.screenWidth())
        XCTAssertEqual(screenWidthInPoints, Util.screenWidth(false))
        XCTAssertEqual(screenSizeInPixel.width, Util.screenWidth(true))
        XCTAssertNotEqual(screenSizeInPixel.width, screenWidthInPoints)
    }

    func testScreenHeight() {
        let screenHeightInPoints = UIScreen.main.bounds.size.height
        let screenSizeInPixel = mainScreenSizeInPixel()

        XCTAssertEqual(screenHeightInPoints, Util.screenHeight())
        XCTAssertEqual(screenHeightInPoints, Util.screenHeight(false))
        XCTAssertEqual(screenSizeInPixel.height, Util.screenHeight(true))
        XCTAssertNotEqual(screenSizeInPixel.height, screenHeightInPoints)
    }

    private func mainScreenSizeInPixel() -> CGSize {
        var screenSizeInPixel = UIScreen.main.nativeBounds.size

        if UIScreen.main.bounds.height == CGFloat(kIphone6PScreenHeight) {
            let iPhonePlusDownsamplingFactor = CGFloat(1.15)
            screenSizeInPixel.height /= iPhonePlusDownsamplingFactor
            screenSizeInPixel.width /= iPhonePlusDownsamplingFactor
        }
        return screenSizeInPixel
    }

    func testdefaultSceneNameForSceneNumber() {
        var sceneDirectoryname = Util.defaultSceneName(forSceneNumber: 1)
        XCTAssertEqual(sceneDirectoryname, "Scene 1")

        sceneDirectoryname = Util.defaultSceneName(forSceneNumber: 99)
        XCTAssertEqual(sceneDirectoryname, "Scene 99")
    }

    func testAppName() {
        let utilAppName = Util.appName()
        let bundleDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        XCTAssertEqual(utilAppName, bundleDisplayName)
    }

    func testAppVersion() {
        let utilAppVersion = Util.appVersion()
        let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        XCTAssertEqual(utilAppVersion, bundleShortVersion)
    }

    func testAppBuildName() {
        let utilAppBuildName = Util.appBuildName()
        let bundleBuildName = Bundle.main.infoDictionary?["CatrobatBuildName"] as? String
        XCTAssertEqual(utilAppBuildName, bundleBuildName)
    }

    func testAppBuildVersion() {
        let utilAppBuildVersion = Util.appBuildVersion()
        let bundleBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        XCTAssertEqual(utilAppBuildVersion, bundleBuildVersion)
    }

    func testCatrobatLanguageVersion() {
        let utilCatrobatLanguageVersion = Util.catrobatLanguageVersion()
        let bundleCatrobatLanguageVersion = Bundle.main.infoDictionary?["CatrobatLanguageVersion"] as? String
        XCTAssertEqual(utilCatrobatLanguageVersion, bundleCatrobatLanguageVersion)
    }

    func testCatrobatMediaLicense() {
        let utilCatrobatMediaLicense = Util.catrobatMediaLicense()
        let bundleCatrobatMediaLicense = Bundle.main.infoDictionary?["CatrobatMediaLicense"] as? String
        XCTAssertEqual(utilCatrobatMediaLicense, bundleCatrobatMediaLicense)
    }

    func testCatrobatProgramLicense() {
        let utilCatrobatProgramLicense = Util.catrobatProgramLicense()
        let bundleCatrobatProgramLicense = Bundle.main.infoDictionary?["CatrobatProgramLicense"] as? String
        XCTAssertEqual(utilCatrobatProgramLicense, bundleCatrobatProgramLicense)
    }

    func testDeviceName() {
        let utilDeviceName = Util.deviceName()
        let systemInfoDeviceName = UIDevice.current.modelName
        XCTAssertEqual(utilDeviceName, systemInfoDeviceName)
    }

    func testPlatformName() {
        let utilPlatformName = Util.platformName()
        let bundlePlatformName = Bundle.main.infoDictionary?["CatrobatPlatformName"] as? String
        XCTAssertEqual(utilPlatformName, bundlePlatformName)
    }

    func testPlatformVersion() {
        let utilPlatformVersion = Util.platformVersionWithoutPatch()
        let devicePlatformVersion = UIDevice.current.systemVersion
        XCTAssertEqual(utilPlatformVersion, devicePlatformVersion)
    }

    func testPlatformVersionWithPatch() {
        let utilPlatformVersionWithPatch = Util.platformVersionWithPatch()
        let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
        let majorPlatformVerison = String(operatingSystemVersion.majorVersion)
        let minorPlatformVersion = String(operatingSystemVersion.minorVersion)
        let patchPlatformVersion = String(operatingSystemVersion.patchVersion)
        let fullDevicePlatformVersion = "\(majorPlatformVerison).\(minorPlatformVersion).\(patchPlatformVersion)"
        XCTAssertEqual(utilPlatformVersionWithPatch, fullDevicePlatformVersion)
    }
    func testPlatformVersionWithoutPatch() {
        let utilPlatformVersion = Util.platformVersionWithoutPatch()
        let devicePlatformVersion = UIDevice.current.systemVersion
        XCTAssertEqual(utilPlatformVersion, devicePlatformVersion)
    }

    func testAllMessagesForProjectIsEmptyAtInit() {

        let messages = Util.allMessages(for: project)

        XCTAssertEqual(messages?.count, 0)
    }

    func testAllMessagesForProjectWithValues() {

        project.allBroadcastMessages?.add("firstValue")

        spriteObject = SpriteObject()
        project.scene.add(object: spriteObject!)
        broadcastScript = BroadcastScript()
        spriteObject.scriptList.add(broadcastScript!)
        broadcastScript.receivedMessage = "secondValue"

        script = Script()
        spriteObject.scriptList.add(script!)

        broadcastBrick = BroadcastBrick()
        script.brickList.add(broadcastBrick!)
        broadcastBrick.broadcastMessage = "thirdValue"

        broadcastWaitBrick = BroadcastWaitBrick()
        script.brickList.add(broadcastWaitBrick!)
        broadcastWaitBrick.broadcastMessage = "fourthValue"

        let messages = Util.allMessages(for: project)

        XCTAssertEqual(messages?.count, 4)
    }

    func testAllMessagesForProjectWithDuplicatedValues() {

        project.allBroadcastMessages?.add("duplicate")
        project.allBroadcastMessages?.add("duplicate")
        project.allBroadcastMessages?.add("duplicate")

        XCTAssertEqual(project.allBroadcastMessages?.count, 1)
    }
}

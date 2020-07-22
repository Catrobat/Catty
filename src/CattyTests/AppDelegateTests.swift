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

import AudioKit
import Nimble
import XCTest

@testable import Pocket_Code

final class AppDelegateTests: XCTestCase {

    var scenePresenterViewController: ScenePresenterViewControllerSpy!
    var audioEngineHelper: AudioEngineHelperSpy!
    weak var appDelegate: AppDelegate!

    override func setUp() {
        scenePresenterViewController = ScenePresenterViewControllerSpy()
        audioEngineHelper = AudioEngineHelperSpy()
        let rootViewController = UINavigationController()
        rootViewController.pushViewController(scenePresenterViewController, animated: false)

        let window = UIWindow()
        window.rootViewController = rootViewController

        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window = window
        appDelegate.audioEngineHelper = audioEngineHelper
    }

    func testApplicationWillResignActiveWhenSceneActive() {
        appDelegate.applicationWillResignActive(UIApplication.shared)

        expect(self.scenePresenterViewController.methodCalls).to(contain("pauseAction"))
        expect(self.scenePresenterViewController.methodCalls.count).to(be(1))
    }

    func testApplicationDidEnterBackground() {
        appDelegate.applicationDidEnterBackground(UIApplication.shared)

        expect(self.audioEngineHelper.methodCalls).to(contain("deactivateAudioSession"))
        expect(self.audioEngineHelper.methodCalls.count).to(be(1))
    }

    func testApplicationWillEnterForeground() {
        scenePresenterViewController.paused = true
        expect(self.scenePresenterViewController.isPaused()) == true

        appDelegate.applicationWillEnterForeground(UIApplication.shared)

        expect(self.audioEngineHelper.methodCalls).to(contain("activateAudioSession"))
        expect(self.audioEngineHelper.methodCalls.count).to(be(1))
    }

    func testApplicationWillEnterForegroundWhenScenePaused() {
        expect(self.scenePresenterViewController.isPaused()) == false

        appDelegate.applicationWillEnterForeground(UIApplication.shared)

        expect(self.audioEngineHelper.methodCalls).to(contain("activateAudioSession"))
        expect(self.audioEngineHelper.methodCalls.count).to(be(1))
    }

    func testApplicationDidBecomeActive() {
        expect(self.scenePresenterViewController.isPaused()) == false

        appDelegate.applicationDidBecomeActive(UIApplication.shared)

        expect(self.scenePresenterViewController.methodCalls).to(contain("resumeAction"))
        expect(self.scenePresenterViewController.methodCalls.count).to(be(1))
    }

    func testApplicationDidBecomeActiveWhenScenePaused() {
        scenePresenterViewController.paused = true
        expect(self.scenePresenterViewController.isPaused()) == true

        appDelegate.applicationDidBecomeActive(UIApplication.shared)

        expect(self.scenePresenterViewController.methodCalls).toNot(contain("resumeAction"))
    }
}

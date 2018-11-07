/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

final class TouchManagerMock: TouchManagerProtocol {

    var touchRecognizer: UILongPressGestureRecognizer?
    var scene: CBScene?
    var isScreenTouched: Bool = false
    var touches: [CGPoint] = []
    var lastTouch: CGPoint?

    var isStarted = false

    func startTrackingTouches(for scene: CBScene) {
        isStarted = true
    }

    func stopTrackingTouches() {
        isStarted = false
    }

    func reset() {
    }

    func screenTouched() -> Bool {
        return isScreenTouched
    }

    func numberOfTouches() -> Int {
        return touches.count
    }

    func lastPositionInScene() -> CGPoint? {
        return lastTouch
    }

    func getPositionInScene(for touchNumber: Int) -> CGPoint? {
        if touchNumber <= 0 || touches.count < touchNumber {
            return nil
        }
        return touches[touchNumber - 1]
    }
}

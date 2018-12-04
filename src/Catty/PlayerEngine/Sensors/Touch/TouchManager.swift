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

class TouchManager: TouchManagerProtocol, CBMultiTouchRecognizerDelegate {

    private var touchRecognizer: CBMultiTouchRecognizer?
    private var scene: CBScene?
    private var allTouches = [UITouch]()
    private var activeTouches = [UITouch]()
    private var inactiveTouches = [UITouch]()

    func startTrackingTouches(for scene: CBScene) {
        self.scene = scene

        let touchRecognizer = CBMultiTouchRecognizer(delegate: self)
        self.touchRecognizer = touchRecognizer
        self.scene?.view?.addGestureRecognizer(touchRecognizer)
        self.scene?.view?.isMultipleTouchEnabled = true
    }

    func stopTrackingTouches() {
        reset()
        scene = nil

        guard let touchRecognizer = self.touchRecognizer else { return }
        touchRecognizer.isEnabled = false
        self.scene?.view?.removeGestureRecognizer(touchRecognizer)
        self.touchRecognizer = nil
    }

    func reset() {
        allTouches.removeAll()
        activeTouches.removeAll()
        inactiveTouches.removeAll()
    }

    func screenTouched() -> Bool {
        return !activeTouches.isEmpty
    }

    func screenTouched(for touchNumber: Int) -> Bool {
        guard let touch = self.touch(for: touchNumber) else { return false }
        return activeTouches.contains(touch) && touch.phase != .ended && touch.phase != .cancelled
    }

    func numberOfTouches() -> Int {
        return allTouches.count
    }

    func lastPositionInScene() -> CGPoint? {
        let touchesCount = numberOfTouches()
        if touchesCount == 0 {
            return nil
        }
        return getPositionInScene(for: touchesCount)
    }

    func getPositionInScene(for touchNumber: Int) -> CGPoint? {
        guard let scene = self.scene, let touch = self.touch(for: touchNumber) else { return nil }
        return touch.location(in: scene)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Without this, other required gestures (like the left slide out control strip) are blocked.
        return true
    }

    func handle(touch: UITouch, for state: UIGestureRecognizerState) {
        if state == .began {
            activeTouches.append(touch)
            allTouches.append(touch)
        } else if state == .ended || state == .cancelled {
            activeTouches.removeObject(touch)
            inactiveTouches.append(touch)
        }
    }

    private func touch(for touchNumber: Int) -> UITouch? {
        if allTouches.count < touchNumber || touchNumber <= 0 {
            return nil
        }
        return allTouches[touchNumber - 1]
    }
}

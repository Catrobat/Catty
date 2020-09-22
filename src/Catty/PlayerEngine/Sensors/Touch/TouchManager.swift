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

class TouchManager: TouchManagerProtocol, CBMultiTouchRecognizerDelegate {

    private var touchRecognizer: CBMultiTouchRecognizer?
    private var stage: Stage?
    private var allTouches = [UITouch]()
    private var activeTouches = [UITouch]()

    func startTrackingTouches(for stage: Stage) {
        self.stage = stage

        let touchRecognizer = CBMultiTouchRecognizer(delegate: self)
        self.touchRecognizer = touchRecognizer
        self.stage?.view?.addGestureRecognizer(touchRecognizer)
        self.stage?.view?.isMultipleTouchEnabled = true
    }

    func stopTrackingTouches() {
        reset()
        stage = nil

        guard let touchRecognizer = self.touchRecognizer else { return }
        touchRecognizer.isEnabled = false
        self.stage?.view?.removeGestureRecognizer(touchRecognizer)
        self.touchRecognizer = nil
    }

    func reset() {
        allTouches.removeAll()
        activeTouches.removeAll()
    }

    func screenTouched() -> Bool {
        !activeTouches.isEmpty
    }

    func screenTouched(for touchNumber: Int) -> Bool {
        guard let touch = self.touch(for: touchNumber) else { return false }
        return activeTouches.contains(touch) && touch.phase != .ended && touch.phase != .cancelled
    }

    func numberOfTouches() -> Int {
        allTouches.count
    }

    func lastPositionInScene() -> CGPoint? {
        let touchesCount = numberOfTouches()
        if touchesCount == 0 {
            return nil
        }
        return getPositionInScene(for: touchesCount)
    }

    func getPositionInScene(for touchNumber: Int) -> CGPoint? {
        guard let stage = self.stage, let touch = self.touch(for: touchNumber) else { return nil }
        return touch.location(in: stage)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Without this, other required gestures (like the left slide out control strip) are blocked.
        return true
    }

    func handle(touch: UITouch, for state: UIGestureRecognizer.State) {
        if state == .began {
            activeTouches.append(touch)
            allTouches.append(touch)

            stage?.touchedWithTouch(touch)
        } else if state == .ended || state == .cancelled {
            activeTouches.removeObject(touch)
        }
    }

    private func touch(for touchNumber: Int) -> UITouch? {
        if allTouches.count < touchNumber || touchNumber <= 0 {
            return nil
        }
        return allTouches[touchNumber - 1]
    }
}

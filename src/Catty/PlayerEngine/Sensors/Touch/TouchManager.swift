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

class TouchManager: TouchManagerProtocol {

    private var touchRecognizer: CBMultiTouchRecognizer?
    private var scene: CBScene?

    func startTrackingTouches(for scene: CBScene) {
        self.scene = scene

        let touchRecognizer = CBMultiTouchRecognizer(scene: scene)
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
        self.touchRecognizer?.resetTouches()
    }

    func screenTouched() -> Bool {
        return touchRecognizer?.screenTouched() ?? false
    }

    func screenTouched(for touchNumber: Int) -> Bool {
        return touchRecognizer?.screenTouched(for: touchNumber - 1) ?? false
    }

    func numberOfTouches() -> Int {
        return touchRecognizer?.numberOfTouches() ?? 0
    }

    func lastPositionInScene() -> CGPoint? {
        let touchesCount = numberOfTouches()
        if touchesCount == 0 {
            return nil
        }
        return touchRecognizer?.location(for: touchesCount - 1)
    }

    func getPositionInScene(for touchNumber: Int) -> CGPoint? {
        return touchRecognizer?.location(for: touchNumber - 1)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Without this, other required gestures (like the left slide out control strip) are blocked.
        return true
    }

    @objc func handleTouch(gestureRecognizer: UIGestureRecognizer) {
    }
}

class CBMultiTouchRecognizer: UIGestureRecognizer {

    private let scene: CBScene
    private var allTouches = [UITouch]()
    private var activeTouches = [UITouch]()
    private var inactiveTouches = [UITouch]()

    init(scene: CBScene) {
        self.scene = scene

        super.init(target: nil, action: nil)
        super.cancelsTouchesInView = false
        super.isEnabled = true
    }

    func resetTouches() {
        allTouches.removeAll()
        activeTouches.removeAll()
        inactiveTouches.removeAll()
    }

    func numberOfTouches() -> Int {
        return allTouches.count
    }

    func screenTouched() -> Bool {
        return !activeTouches.isEmpty
    }

    func screenTouched(for touchNumber: Int) -> Bool {
        guard let touch = touch(for: touchNumber) else { return false }
        return activeTouches.contains(touch)
    }

    func location(for touchNumber: Int) -> CGPoint? {
        if allTouches.count <= touchNumber || touchNumber < 0 {
            return nil
        }
        return locationInScene(for: allTouches[touchNumber])
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if  self.isEnabled {
            guard let touch = touches.first else { return }
            allTouches.append(touch)
            activeTouches.append(touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        activeTouches.removeObject(touch)
        inactiveTouches.append(touch)
    }

    override func ignore(_ touch: UITouch, for event: UIEvent) {
        return // do nothing
    }

    private func touch(for touchNumber: Int) -> UITouch? {
        return allTouches.count <= touchNumber || touchNumber < 0 ? nil : allTouches[touchNumber]
    }

    private func locationInScene(for touch: UITouch) -> CGPoint {
        return touch.location(in: scene)
    }
}

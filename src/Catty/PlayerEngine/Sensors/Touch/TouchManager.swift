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

class TouchManager: NSObject, TouchManagerProtocol, UIGestureRecognizerDelegate {
    
    private var touchRecognizer: UILongPressGestureRecognizer?
    private var scene: CBScene?
    private var isScreenTouched: Bool
    private var touches: [CGPoint]
    private var lastTouch: CGPoint? // When finger is tapped and dragged around on the screen, this is updated.
    
    override init() {
        isScreenTouched = false
        touches = [CGPoint]()
    }
    
    func startTrackingTouches(for scene: CBScene) {
        self.scene = scene
        
        let touchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTouch(gestureRecognizer:)))
        touchRecognizer.minimumPressDuration = 0
        touchRecognizer.cancelsTouchesInView = false
        touchRecognizer.delegate = self
        touchRecognizer.isEnabled = true
    
        self.touchRecognizer = touchRecognizer
        UIApplication.shared.keyWindow?.addGestureRecognizer(touchRecognizer)
        reset()
    }
    
    func stopTrackingTouches() {
        scene = nil
        reset()
        
        guard let touchRecognizer = self.touchRecognizer else { return }
        touchRecognizer.isEnabled = false
        UIApplication.shared.keyWindow?.removeGestureRecognizer(touchRecognizer)
        self.touchRecognizer = nil
    }
    
    func reset() {
        touches.removeAll()
        isScreenTouched = false
        lastTouch = nil
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
        if touches.count <= touchNumber || touchNumber <= 0 {
            return nil
        }
        return touches[touchNumber - 1]
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Without this, other required gestures (like the left slide out control strip) are blocked.
        return true
    }
    
    @objc func handleTouch(gestureRecognizer: UIGestureRecognizer) {
        guard let scene = self.scene else { return }
        
        let position = gestureRecognizer.location(in: scene.view)
        lastTouch = position
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            isScreenTouched = true
            touches.append(position)
        }
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            isScreenTouched = false
        }
    }
}

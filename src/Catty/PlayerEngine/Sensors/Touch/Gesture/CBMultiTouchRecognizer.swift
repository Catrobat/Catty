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

class CBMultiTouchRecognizer: UIGestureRecognizer {

    private let touchManager: CBMultiTouchRecognizerDelegate

    init(delegate: CBMultiTouchRecognizerDelegate) {
        self.touchManager = delegate

        super.init(target: nil, action: nil)
        super.cancelsTouchesInView = false
        super.isEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        if  self.isEnabled {
            for touch in touches {
                touchManager.handle(touch: touch, for: .began)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        if  self.isEnabled {
            for touch in touches {
                touchManager.handle(touch: touch, for: .ended)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)

        if  self.isEnabled {
            for touch in touches {
                touchManager.handle(touch: touch, for: .cancelled)
            }
        }
    }

    override func ignore(_ touch: UITouch, for event: UIEvent) {
        return // do nothing
    }
}

protocol CBMultiTouchRecognizerDelegate: AnyObject {
    func handle(touch: UITouch, for state: UIGestureRecognizer.State)
}

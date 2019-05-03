/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

protocol TouchManagerProtocol {

    func startTrackingTouches(for scene: CBScene)

    func stopTrackingTouches()

    func reset()

    // Returns true if screen is currently touched
    func screenTouched() -> Bool

    // Returns true if screen is still touched for given touch
    func screenTouched(for toucNumber: Int) -> Bool

    func numberOfTouches() -> Int

    // Returns a SpriteKit specific position which needs to be converted. (0, 0) is at the bottom left corner
    func lastPositionInScene() -> CGPoint?

    // Returns a SpriteKit specific position which needs to be converted. (0, 0) is at the bottom left corner
    func getPositionInScene(for touchNumber: Int) -> CGPoint?
}

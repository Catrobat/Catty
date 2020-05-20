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

@testable import Pocket_Code

class CBSpriteNodeMock: CBSpriteNode {

    var mockedPosition: CGPoint?
    var mockedScene: SKScene?

    var updateMethodCallCount = 0

    required init(spriteObject: SpriteObject) {
        super.init(spriteObject: spriteObject)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var position: CGPoint {
        get {
            mockedPosition ?? super.position
        }
        set {
            self.mockedPosition = newValue
        }
    }

    override var scene: SKScene {
        get {
            mockedScene ?? super.scene!
        }
        set {
            self.mockedScene = newValue
        }
    }

    override func update(_ currentTime: TimeInterval) {
        self.updateMethodCallCount += 1
    }
}

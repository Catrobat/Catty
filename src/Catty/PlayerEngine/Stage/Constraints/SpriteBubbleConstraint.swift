/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

@objc
final class SpriteBubbleConstraint: SKConstraint {
    private let parent: SKNode
    private let bubble: SKNode
    private let bubbleWidth: CGFloat
    private let bubbleHeight: CGFloat
    private let bubbleInitialPosition: CGPoint

    @objc init(bubble: SKNode, parent: SKNode, width: CGFloat, height: CGFloat, position: CGPoint, bubbleTailHeight: CGFloat) {
        self.bubble = bubble
        self.parent = parent
        self.bubbleWidth = width
        self.bubbleHeight = height + bubbleTailHeight
        self.bubbleInitialPosition = position

        super.init()
        self.enabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init with bubble and parent")
    }

    override var enabled: Bool {
        get {
            if super.enabled {
                apply()
            }
            return super.enabled
        }
        set {
            super.enabled = newValue
        }
    }

    private func handleXCollision() {
        guard let scene = parent.scene,
              let bubbleLabel = bubble.children.first else {
            return
        }

        let isBubbleInverted = bubble.xScale < 0
        var leftBubbleBorder = parent.position.x + bubbleInitialPosition.x
        var rightBubbleBorder = parent.position.x + bubbleInitialPosition.x

        leftBubbleBorder -= isBubbleInverted ? bubbleWidth : 0
        rightBubbleBorder += isBubbleInverted ? 0 : bubbleWidth

        let rightSceneEdge = scene.size.width
        let leftSceneEdge = CGFloat(0)

        bubble.position.x = bubbleInitialPosition.x

        if (rightBubbleBorder > rightSceneEdge && !isBubbleInverted && leftBubbleBorder > leftSceneEdge) ||
            (leftBubbleBorder < leftSceneEdge && isBubbleInverted && rightBubbleBorder < rightSceneEdge) {

            bubble.xScale *= -1
            bubbleLabel.xScale *= -1
        }
    }

    private func calcRelativeSizeToParent() {
        bubble.xScale = (1 / CGFloat(parent.xScale) * copysign(1.0, bubble.xScale))
        bubble.yScale = (1 / CGFloat(parent.yScale))
    }
    private func calcRelativeRotationToParent() {
        bubble.zRotation = CGFloat(parent.zRotation) * -1
    }

    public func apply() {
        calcRelativeSizeToParent()
        calcRelativeRotationToParent()
        handleXCollision()
    }
}

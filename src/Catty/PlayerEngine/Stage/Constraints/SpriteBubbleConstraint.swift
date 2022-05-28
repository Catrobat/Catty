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
    private let bubbleInvertedInitialPosition: CGPoint

    @objc init(bubble: SKNode, parent: SKNode, width: CGFloat, height: CGFloat, position: CGPoint, invertedPosition: CGPoint, bubbleTailHeight: CGFloat) {
        self.bubble = bubble
        self.parent = parent
        self.bubbleWidth = width
        self.bubbleHeight = height + bubbleTailHeight
        self.bubbleInitialPosition = position
        self.bubbleInvertedInitialPosition = invertedPosition

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
        var leftBubbleBorder = parent.position.x
        var rightBubbleBorder = parent.position.x

        if isBubbleInverted {
            leftBubbleBorder += bubbleInvertedInitialPosition.x - bubbleWidth
            rightBubbleBorder += bubbleInvertedInitialPosition.x
            bubble.position.x = bubbleInvertedInitialPosition.x
        } else {
            leftBubbleBorder += bubbleInitialPosition.x
            rightBubbleBorder += bubbleInitialPosition.x + bubbleWidth
            bubble.position.x = bubbleInitialPosition.x
        }

        let rightSceneEdge = scene.size.width
        let leftSceneEdge = CGFloat(0)

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

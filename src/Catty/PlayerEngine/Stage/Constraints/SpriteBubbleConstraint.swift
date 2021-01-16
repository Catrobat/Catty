/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
    private let bubbleInitialePosition: CGPoint

    @objc init(bubble: SKNode, parent: SKNode, width: CGFloat, height: CGFloat, position: CGPoint, bubbleTailHeight: CGFloat) {
        self.bubble = bubble
        self.parent = parent
        self.bubbleWidth = width
        self.bubbleHeight = height + bubbleTailHeight
        self.bubbleInitialePosition = position

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

        let leftBubbleBorder = parent.position.x - bubbleInitialePosition.x - bubbleWidth
        let rightBubbleBorder = parent.position.x + bubbleInitialePosition.x + bubbleWidth

        let rightSceneEdge = scene.size.width
        let leftSceneEdge = CGFloat(0)

        if rightBubbleBorder > rightSceneEdge && bubble.xScale > 0 && leftBubbleBorder > leftSceneEdge {
            bubble.position.x = -parent.convert(bubbleInitialePosition, from: parent).x
            bubble.xScale *= -1
            bubbleLabel.xScale *= -1

        } else if  leftBubbleBorder < leftSceneEdge && bubble.xScale < 0 && rightBubbleBorder < rightSceneEdge {
            bubble.position.x = parent.convert(bubbleInitialePosition, from: parent).x
            bubble.xScale *= -1
            bubbleLabel.xScale *= -1
        }

    }

    private func handleYCollision() {
        guard let scene = parent.scene else {
            return
        }

        let topEdge = scene.size.height
        let bottomEdge = CGFloat(0)

        let topBubblePosition = CGFloat(parent.position.y + parent.yScale * bubbleInitialePosition.y + bubbleHeight)
        let botBubblePosition = CGFloat(parent.position.y + parent.yScale * bubbleInitialePosition.y)

        let xCollisionPosition = scene.convert(bubble.position, from: parent).x
        let yTopCollisionPosition = CGFloat(topEdge - bubbleHeight)

        if scene.intersects(parent) {
            bubble.position.y = parent.convert(bubbleInitialePosition, from: parent).y
            bubble.position.x = copysign(1.0, bubble.xScale) * parent.convert(bubbleInitialePosition, from: parent).x
        }

        if topBubblePosition >= topEdge {
            bubble.position = scene.convert(CGPoint(x: xCollisionPosition, y: yTopCollisionPosition), to: parent)
        } else if botBubblePosition <= bottomEdge {
            bubble.position = scene.convert(CGPoint(x: xCollisionPosition, y: CGFloat(0)), to: parent)
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
        handleYCollision()
        handleXCollision()
    }
}

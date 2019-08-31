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

import Foundation

let kMaxBubbleWidth = 200
let kSentenceLength = 10

@objc enum CBBubbleType: Int {
    case speech = 0
    case thought = 1
}

@objc class BubbleBrickHelper: NSObject {

    @objc static func addBubble(to sprite: CBSpriteNode, withText text: String, andType type: CBBubbleType) {
        let labelNode = SKNode()
        var sentencePosition = Int(0.0)
        var verticalPosition = Float(0.0)
        let verticalPadding = 20
        let horizontalPadding = 150.0
        var bubbleHeight = kSceneLabelFontSize + Float(verticalPadding)
        let fullTextNode = SKLabelNode(text: text)
        let fullTextLength = fullTextNode.frame.size.width
        var sentenceSubStringLength = Int(fullTextLength)

         if fullTextLength > CGFloat(kMaxBubbleWidth) {
             while sentencePosition + kSentenceLength < text.count {

                let sentencePosIndex = String.Index.init(encodedOffset: sentencePosition)
                let sentenceLengthIndex = String.Index.init(encodedOffset: sentencePosition + kSentenceLength)
                let sentenceRange = sentencePosIndex..<sentenceLengthIndex
                var sentenceSubString = String(text[sentenceRange])

                let lowerCharIndex = String.Index.init(encodedOffset: Int(sentencePosition + kSentenceLength))
                let UpperCharIndex = String.Index.init(encodedOffset: Int(sentencePosition + kSentenceLength + 1))
                let charRange = lowerCharIndex..<UpperCharIndex
                let nextCharInLine = String(text[charRange])

                 if nextCharInLine == " " {
                    sentenceSubString += "-"
                 }

                 addSentence(toLabel: labelNode, withSentence: sentenceSubString, andPosition: (CGFloat)(verticalPosition))
                 sentencePosition += kSentenceLength
                 verticalPosition += kSceneLabelFontSize + 5
                 bubbleHeight += kSceneLabelFontSize + 5
                 sentenceSubStringLength = Int(SKLabelNode(text: sentenceSubString).frame.size.width)
             }

            let lowerSubStringIndex = String.Index.init(encodedOffset: Int(sentencePosition))
            let UpperSubStringIndex = String.Index.init(encodedOffset: text.count)
            let subStringRange = lowerSubStringIndex..<UpperSubStringIndex
            let sentenceSubString = String(text[subStringRange])

            addSentence(toLabel: labelNode, withSentence: sentenceSubString, andPosition: (CGFloat)(verticalPosition))
         } else {
            addSentence(toLabel: labelNode, withSentence: text, andPosition: (CGFloat)(verticalPosition))
        }

        removeOldBubbleFromNode(node: sprite)

        let bubbleWidth = CGFloat(sentenceSubStringLength) + CGFloat(horizontalPadding)
        let bubble = createBubble(with: sprite, width: bubbleWidth, height: (CGFloat)(bubbleHeight), type: type)

        if type == CBBubbleType.thought {
            labelNode.position = CGPoint(x: bubble.frame.size.width / 2,
                                         y: bubble.frame.size.height - CGFloat(kSceneLabelFontSize) - CGFloat(verticalPadding / 2))
        } else {
            labelNode.position = CGPoint(x: bubble.frame.size.width / 2 + 6.0 * bubbleWidth / CGFloat(kMaxBubbleWidth),
                                         y: bubble.frame.size.height - CGFloat(kSceneLabelFontSize) - CGFloat(verticalPadding / 3 ))
        }

        bubble.addChild(labelNode)
        sprite.addChild(bubble)
    }
    private static func createBubble(with sprite: CBSpriteNode, width: CGFloat, height: CGFloat, type: CBBubbleType)
        -> SKShapeNode {

        let bubbleTailHeight = CGFloat(48.0)
        let bubble = SKShapeNode(path: bubblePathWith(width: width,
                                                      height: height,
                                                      bubbleTailHeight: bubbleTailHeight,
                                                      type: type))

        let bubbleInitialPosition = CGPoint(x: sprite.frame.size.width / 2,
                                            y: sprite.frame.size.height / (2 * sprite.yScale))

        bubble.constraints = (NSArray(object: SpriteBubbleConstraint(bubble: bubble,
                                                                     parent: sprite,
                                                                     width: width,
                                                                     height: height,
                                                                     position: bubbleInitialPosition,
                                                                     bubbleTailHeight: bubbleTailHeight)) as! [SKConstraint])
        bubble.name = kBubbleBrickNodeName
        bubble.fillColor = UIColor.white
        bubble.strokeColor = UIColor.black
        bubble.lineWidth = 3.5

        bubble.position = bubble.convert(CGPoint(x: sprite.position.x + bubbleInitialPosition.x,
                                                 y: sprite.position.y + bubbleInitialPosition.y), to: sprite)

        return bubble
    }
    private static func addSentence(toLabel label: SKNode, withSentence subString: String, andPosition verticalPosition: CGFloat) {
        let subSentenceLabel = SKLabelNode(text: subString)
        subSentenceLabel.fontName = kSceneDefaultFont
        subSentenceLabel.fontSize = CGFloat(kSceneLabelFontSize)
        subSentenceLabel.name = "bubbleText"
        subSentenceLabel.fontColor = UIColor.black
        subSentenceLabel.position = CGPoint(x: subSentenceLabel.position.x, y: subSentenceLabel.position.y - verticalPosition)
        label.addChild(subSentenceLabel)
    }
    private static func removeOldBubbleFromNode(node: SKNode) {
        if let oldBubble = node.childNode(withName: kBubbleBrickNodeName) {
            oldBubble.run(SKAction.removeFromParent())
            node.removeChildren(in: [oldBubble])
        }

    }
    private static func bubblePathWith(width: CGFloat, height: CGFloat, bubbleTailHeight: CGFloat, type: CBBubbleType) -> CGPath {
        var bubblePath: UIBezierPath
        switch type {
        case CBBubbleType.thought:
            bubblePath = UIBezierPath(roundedRect: CGRect(x: 1.5, y: 47.5, width: width, height: height),
                                      cornerRadius: CGFloat(45.0))
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: 33.5, y: 29.5, width: 18, height: 18))
            let oval2Path = UIBezierPath(ovalIn: CGRect(x: 22.5, y: 18.5, width: 14, height: 14))
            let oval3Path = UIBezierPath(ovalIn: CGRect(x: 11.5, y: 8.5, width: 12, height: 12))
            let oval4Path = UIBezierPath(ovalIn: CGRect(x: 2.5, y: 0.5, width: 7, height: 7))

            bubblePath.append(ovalPath)
            bubblePath.append(oval2Path)
            bubblePath.append(oval3Path)
            bubblePath.append(oval4Path)

        case CBBubbleType.speech:
            let tailGap = CGFloat(30.0)
            let curveLength = CGFloat(20.0)
            bubblePath = UIBezierPath()

            bubblePath.move(to: CGPoint(x: 1.5 + curveLength, y: bubbleTailHeight))
            bubblePath.addLine(to: CGPoint(x: 30.0, y: bubbleTailHeight))
            bubblePath.move(to: CGPoint(x: 30.0 + tailGap, y: bubbleTailHeight))

            bubblePath.addLine(to: CGPoint(x: 1.5 + width - curveLength, y: bubbleTailHeight))

            bubblePath.addQuadCurve(to: CGPoint(x: 1.5 + width, y: bubbleTailHeight + curveLength),
                                    controlPoint: CGPoint(x: 1.5 + width, y: bubbleTailHeight))

            bubblePath.addLine(to: CGPoint(x: 1.5 + width, y: bubbleTailHeight + curveLength))

            bubblePath.addLine(to: CGPoint(x: 1.5 + width, y: bubbleTailHeight + height - curveLength))

            bubblePath.addQuadCurve(to: CGPoint(x: 1.5 + width - curveLength, y: bubbleTailHeight + height),
                                    controlPoint: CGPoint(x: 1.5 + width, y: bubbleTailHeight + height))

            bubblePath.addLine(to: CGPoint(x: 1.5 + width - curveLength, y: bubbleTailHeight + height))

            bubblePath.addLine(to: CGPoint(x: 1.5 + curveLength, y: bubbleTailHeight + height))

            bubblePath.addQuadCurve(to: CGPoint(x: 1.5, y: bubbleTailHeight + height - curveLength ),
                                    controlPoint: CGPoint(x: 1.5, y: bubbleTailHeight + height))

            bubblePath.addLine(to: CGPoint(x: 1.5, y: bubbleTailHeight + height - curveLength ))

            bubblePath.addLine(to: CGPoint(x: 1.5, y: bubbleTailHeight + curveLength ))

            bubblePath.addQuadCurve(to: CGPoint(x: 1.5 + curveLength, y: bubbleTailHeight),
                                    controlPoint: CGPoint(x: 1.5, y: bubbleTailHeight))

            bubblePath.addLine(to: CGPoint(x: 1.5 + curveLength, y: bubbleTailHeight))

            let bubbleTail = UIBezierPath()
            bubbleTail.move(to: CGPoint(x: 30.0, y: bubbleTailHeight))
            bubbleTail.addLine(to: CGPoint(x: 0.0, y: 0.0))
            bubbleTail.addLine(to: CGPoint(x: CGFloat(30.0 + tailGap), y: bubbleTailHeight))

            bubblePath.append(bubbleTail)

        }

        return bubblePath.cgPath
    }

}

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

extension CBSpriteNode {

    @objc func drawEmbroidery() {
        let drawEmbroideryQueue = embroideryStream.drawEmbroideryQueue
        let stitchCount = drawEmbroideryQueue.count
        var lastDrawedStitchIndex = 0
        var lastColorChangeIndex = 0
        var currentColor = UIColor(red: 0, green: 0, blue: 0)
        var previousColor = UIColor(red: 0, green: 0, blue: 0)
        for (index, stitch) in drawEmbroideryQueue.enumerated() where !stitch.isDrawn {
            if stitch.isColorChange {
                previousColor = currentColor
                lastColorChangeIndex = index
            }
            currentColor = stitch.getColor()
            if !stitch.isJump && !stitch.isInterpolated {
                self.drawStitchingPoint(stitch, color: stitch.getColor())
                lastDrawedStitchIndex = index
            }
            let color = drawEmbroideryQueue[index - 1]?.getColor() ?? UIColor(red: 0, green: 0, blue: 0)
            if color != stitch.getColor() {
                self.drawStitchingLine(from: drawEmbroideryQueue[index - 1], to: stitch, color: color)
            } else if lastDrawedStitchIndex < lastColorChangeIndex {
                self.drawStitchingLine(from: drawEmbroideryQueue[index - 1], to: stitch, color: previousColor)
            } else {
                self.drawStitchingLine(from: drawEmbroideryQueue[index - 1], to: stitch, color: currentColor)
            }
        }
        if stitchCount > 1 {
            drawEmbroideryQueue.removeSubrange(0..<stitchCount - 1)
        }

        SpriteKitDefines.currentStitchingColor = UIColor(red: 0, green: 0, blue: 0)
    }

    private func drawStitchingPoint(_ stitch: Stitch, color: UIColor) {
        let point = CircleShapeNode(point: stitch.getPosition(), radius: SpriteKitDefines.stitchingCircleRadius, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: true, transform: .identity)
        point.name = SpriteKitDefines.stitchingPointShapeNodeName
        point.strokeColor = color
        point.fillColor = color
        point.lineWidth = embroideryStream.size
        point.zPosition = SpriteKitDefines.defaultStitchingZPosition

        self.scene?.addChild(point)
        stitch.isDrawn = true
    }

    private func drawStitchingLine(from start: Stitch?, to end: Stitch, color: UIColor) {
        guard let start = start else { return }

        let line = LineShapeNode(pathStartPoint: start.getPosition(), pathEndPoint: end.getPosition())
        line.name = SpriteKitDefines.stitchingLineShapeNodeName
        line.strokeColor = color
        line.lineWidth = embroideryStream.size
        line.zPosition = SpriteKitDefines.defaultStitchingZPosition
        self.scene?.addChild(line)
    }
}

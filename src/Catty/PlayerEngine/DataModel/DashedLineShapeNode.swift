/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class DashedLineShapeNode: SKShapeNode {
    let pathStartPoint: CGPoint
    let pathEndPoint: CGPoint

    init(pathStartPoint: CGPoint, pathEndPoint: CGPoint) {
        self.pathStartPoint = pathStartPoint
        self.pathEndPoint = pathEndPoint

        super.init()
        let pattern : [CGFloat] = [10.0, 10.0]

        let path = CGMutablePath()
        path.move(to: pathStartPoint)
        path.addLine(to: pathEndPoint)
        let dashed = path.copy(dashingWithPhase: 1, lengths: pattern)
        
        self.path = dashed
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

public extension CGVector {

    init(fromPoint point: CGPoint) {
      self.init(dx: point.x, dy: point.y)
    }

    init(head B: CGPoint, tail A: CGPoint) {
        self.init(dx: B.x - A.x, dy: B.y - A.y)
    }

    init(from A: CGPoint, to B: CGPoint) {
        self.init(dx: B.x - A.x, dy: B.y - A.y)
    }

    static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    static func += (lhs: inout CGVector, rhs: CGVector) { //swiftlint:disable shorthand_operator
        lhs = lhs + rhs                                   //this is a known limitation of swiftlint
    }

    static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    static func -= (lhs: inout CGVector, rhs: CGVector) { //swiftlint:disable shorthand_operator
        lhs = lhs - rhs                                   //this is a known limitation of swiftlint
    }

    static func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
        CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }

    func toCGPoint() -> CGPoint {
        CGPoint(x: dx, y: dy)
    }

    func magnitude() -> CGFloat {
        sqrt((self.dx * self.dx) + (self.dy * self.dy))
    }

    func normalized() -> CGVector {
        let l = self.magnitude()
        return CGVector(dx: self.dx / l, dy: self.dy / l)
    }

    func normals() -> (CGVector, CGVector) {
        (CGVector(dx: self.dy, dy: -self.dx), CGVector(dx: -self.dy, dy: self.dx))
    }
}

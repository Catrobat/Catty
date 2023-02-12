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

extension UIImage {
    func crop(rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        self.draw(at: CGPoint(x: rect.origin.x * -1, y: rect.origin.y * -1))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }

    func rotated(byDegrees degrees: CGFloat) -> UIImage {
            let radians = degrees * .pi / 180
            let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
            let transform = CGAffineTransform(rotationAngle: radians)
            rotatedViewBox.transform = transform
            let rotatedSize = rotatedViewBox.frame.size

            UIGraphicsBeginImageContext(rotatedSize)
            guard let context = UIGraphicsGetCurrentContext() else { return self }

            context.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.rotate(by: radians)
            draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
    }
}

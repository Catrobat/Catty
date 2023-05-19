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

extension UIImage {
    func crop(rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        self.draw(at: CGPoint(x: rect.origin.x * -1, y: rect.origin.y * -1))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }

    func overlayText(_ text: String, withFont font: UIFont, andColor color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: textStyle, .foregroundColor: color]

        let textYOffset = (self.size.height - font.lineHeight) / 2
        let textBox = CGRect(x: 0, y: textYOffset, width: self.size.width, height: font.lineHeight)

        if color == UIColor.clear {
            UIGraphicsGetCurrentContext()?.setBlendMode(.clear)
        }
        text.draw(in: textBox, withAttributes: attributes)

        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return textImage
    }
}

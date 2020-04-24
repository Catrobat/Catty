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

@objc
extension UIColor {

    /* WORK IN PROGRESS: Theming
    @nonobjc
    static let currentTheme = CattyTheme.teal

    enum CattyTheme {
        case teal //default
        case red
        case pink
    }*/

    /*
     * from: https://stackoverflow.com/a/24263296
     */
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }

    // MARK: intern Colors

    static var light: UIColor {
        /* WORK IN PROGRESS: Theming
        switch currentTheme {
        case .red:
            return UIColor(hex: 0xde746a)
        case .pink:
            return UIColor(hex: 0xe68cd8)
        default: //teal
            return UIColor(hex: 0xadeef0)
        }*/
        return UIColor(hex: 0xadeef0)
    }

    static var medium: UIColor {
        /* WORK IN PROGRESS: Theming
        switch currentTheme {
        case .red:
            return UIColor(hex: 0xad2215)
        case .pink:
            return UIColor(hex: 0xb7189f)
        default: //teal
            return UIColor(hex: 0x18a5b7)
        }*/
        return UIColor(hex: 0x18a5b7)
    }

    static var dark: UIColor {
        UIColor(hex: 0x191919)
    }

    static var whiteGray: UIColor {
        UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }

    static var textViewBorderGray: UIColor {
        UIColor(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 225.0 / 255.0, alpha: 1.0)
    }

    static var destructive: UIColor {
        UIColor(hex: 0xf26c4f)
    }

    // MARK: Global

    static var globalTint: UIColor {
        self.medium
    }

    static var utilityTint: UIColor {
        self.medium
    }

    static var navBar: UIColor {
        self.medium
    }

    static var navTint: UIColor {
        /* WORK IN PROGRESS: Dark mode
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return self.dark
            }
        }*/
        return self.light
    }

    static var navText: UIColor {
        self.background
    }

    static var toolBar: UIColor {
        self.navBar
    }

    static var toolTint: UIColor {
        self.navTint
    }

    static var tabBar: UIColor {
        self.navBar
    }

    static var tabTint: UIColor {
        self.navTint
    }

    static var buttonTint: UIColor {
        self.medium
    }

    static var textTint: UIColor {
        /* WORK IN PROGRESS: Dark mode
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return self.light
            }
        }*/
        return self.dark
    }

    static var pageIndicator: UIColor {
        UIColor(hex: 0x3ab2c1)
    }

    static var buttonHighlightedTint: UIColor {
        self.background
    }

    static var destructiveTint: UIColor {
        self.destructive
    }

    static var background: UIColor {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return self.black
            }
        }
        return self.white
    }

    // MARK: FormulaEditor

    static var formulaEditorOperator: UIColor {
        self.buttonTint
    }

    static var formulaEditorHighlight: UIColor {
        self.buttonTint
    }

    static var formulaEditorOperand: UIColor {
        self.buttonTint
    }

    static var formulaEditorBorder: UIColor {
        self.light
    }

    static var formulaButtonText: UIColor {
        self.light
    }

    // MARK: IDE

    // Bricks & Scripts Colors
    static var brickSelectionBackground: UIColor {
        UIColor(red: 13.0 / 255.0, green: 13.0 / 255.0, blue: 13.0 / 255.0, alpha: 1.0)
    }

    static var lookBrickGreen: UIColor {
        UIColor(red: 57.0 / 255.0, green: 171.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
    }

    static var lookBrickStroke: UIColor {
        UIColor(red: 185.0 / 255.0, green: 220.0 / 255.0, blue: 110.0 / 255.0, alpha: 1.0)
    }

    static var motionBrickBlue: UIColor {
        UIColor(red: 29.0 / 255.0, green: 132.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)
    }

    static var motionBrickStroke: UIColor {
        UIColor(red: 179.0 / 255.0, green: 203.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    static var controlBrickOrange: UIColor {
        UIColor(red: 255.0 / 255.0, green: 120.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    }

    static var controlBrickStroke: UIColor {
        UIColor(red: 247.0 / 255.0, green: 208.0 / 255.0, blue: 187.0 / 255.0, alpha: 1.0)
    }

    static var variableBrickRed: UIColor {
        UIColor(red: 234.0 / 255.0, green: 59.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
    }

    static var variableBrickStroke: UIColor {
        UIColor(red: 238.0 / 255.0, green: 149.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0)
    }

    static var soundBrickViolet: UIColor {
        UIColor(red: 180.0 / 255.0, green: 67.0 / 255.0, blue: 198.0 / 255.0, alpha: 1.0)
    }

    static var soundBrickStroke: UIColor {
        UIColor(red: 179.0 / 255.0, green: 137.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    static var phiroBrick: UIColor {
        UIColor(red: 234.0 / 255.0, green: 200.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
    }

    static var phiroBrickStroke: UIColor {
        UIColor(red: 179.0 / 255.0, green: 137.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    static var arduinoBrick: UIColor {
        UIColor(red: 234.0 / 255.0, green: 200.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
    }

    static var arduinoBrickStroke: UIColor {
        UIColor(red: 179.0 / 255.0, green: 137.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
}

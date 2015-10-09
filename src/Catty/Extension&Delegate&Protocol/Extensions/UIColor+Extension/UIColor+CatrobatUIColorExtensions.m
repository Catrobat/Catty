/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "UIColor+CatrobatUIColorExtensions.h"

@implementation UIColor (CatrobatUIColorExtensions)

// taken from https://github.com/anjerodesu/UIColor-ColorWithHex/blob/master/UIColor%2BColorWithHex.m
+ (UIColor *)colorWithHex:(UInt32)hexadecimal
{
	CGFloat red, green, blue;

	// bitwise AND operation
	// hexadecimal's first 2 values
	red = ( hexadecimal >> 16 ) & 0xFF;
	// hexadecimal's 2 middle values
	green = ( hexadecimal >> 8 ) & 0xFF;
	// hexadecimal's last 2 values
	blue = hexadecimal & 0xFF;

	UIColor *color = [UIColor colorWithRed: red / 255.0f green: green / 255.0f blue: blue / 255.0f alpha: 1.0f];
	return color;
}

# pragma mark Global

+ (UIColor*)globalTintColor
{
    return [UIColor colorWithRed:232.0f/255.0f green:146.0f/255.0f blue:6.0f/255.0f alpha:1.0f];
}

+ (UIColor*)utilityTintColor
{
    return [self lightTextTintColor];
}

+ (UIColor*)navBarColor
{
    return [self backgroundColor];
}

+ (UIColor*)navTintColor
{
    return [self globalTintColor];
}

+ (UIColor*)navTextColor
{
    return [self lightTextTintColor];
}

+ (UIColor*)lightTextTintColor
{
    return [UIColor colorWithRed:168.0f/255.0f green:223.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
}

+ (UIColor*)darkTextTintColor
{
    return [UIColor colorWithRed:111.0f/255.0f green:142.0f/255.0f blue:155.0f/255.0f alpha:1.0f];
}

+ (UIColor*)destructiveTintColor
{
    return [self colorWithHex: 0xF26C4F];
}

+ (UIColor*)backgroundColor
{
    return [UIColor colorWithRed:0 green:37.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
}

# pragma mark FormulaEditor
+ (UIColor*)formulaEditorOperatorColor
{
    return [self globalTintColor];
}

+ (UIColor*)formulaEditorHighlightColor
{
    return [self globalTintColor];
}

+ (UIColor*)formulaEditorOperandColor
{
    return [self lightTextTintColor];
}

# pragma mark IDE
+ (UIColor*)brickSelectionBackgroundColor
{
    return [UIColor colorWithRed:13.0f/255.0f green:13.0f/255.0f blue:13.0f/255.0f alpha:1.0f];
}

+ (UIColor*)lookBrickGreenColor
{
    return [UIColor colorWithRed:57.0f/255.0f green:171.0f/255.0f blue:45.0f/255.0f alpha:1.0f];
}

+ (UIColor*)lookBrickStrokeColor
{
    return [UIColor colorWithRed:185.0f/255.0f green:220.0f/255.0f blue:110.0f/255.0f alpha:1.0f];
}

+ (UIColor*)motionBrickBlueColor
{
    return [UIColor colorWithRed:29.0f/255.0f green:132.0f/255.0f blue:217.0f/255.0f alpha:1.0f];
}

+ (UIColor*)motionBrickStrokeColor
{
    return [UIColor colorWithRed:179.0f/255.0f green:203.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (UIColor*)controlBrickOrangeColor
{
    return [UIColor colorWithRed:255.0f/255.0f green:120.0f/255.0f blue:20.0f/255.0f alpha:1.0f];
}

+ (UIColor*)controlBrickStrokeColor
{
    return [UIColor colorWithRed:247.0f/255.0f green:208.0f/255.0f blue:187.0f/255.0f alpha:1.0f];
}

+ (UIColor*)varibaleBrickRedColor
{
    return [UIColor colorWithRed:234.0f/255.0f green:59.0f/255.0f blue:59.0f/255.0f alpha:1.0f];
}

+ (UIColor*)variableBrickStrokeColor
{
    return [UIColor colorWithRed:238.0f/255.0f green:149.0f/255.0f blue:149.0f/255.0f alpha:1.0f];
}

+ (UIColor*)soundBrickVioletColor
{
    return [UIColor colorWithRed:180.0f/255.0f green:67.0f/255.0f blue:198.0f/255.0f alpha:1.0f];
}

+ (UIColor*)soundBrickStrokeColor
{
    return [UIColor colorWithRed:179.0f/255.0f green:137.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (UIColor*)PhiroBrickColor
{
    return [UIColor colorWithRed:234.0f/255.0f green:200.0f/255.0f blue:59.0f/255.0f alpha:1.0f];
}

+ (UIColor*)PhiroBrickStrokeColor
{
    return [UIColor colorWithRed:234.0f/255.0f green:200.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
}

+ (UIColor*)ArduinoBrickColor
{
    return [UIColor colorWithRed:234.0f/255.0f green:200.0f/255.0f blue:59.0f/255.0f alpha:1.0f];
}

+ (UIColor*)ArduinoBrickStrokeColor
{
    return [UIColor colorWithRed:234.0f/255.0f green:200.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
}

@end

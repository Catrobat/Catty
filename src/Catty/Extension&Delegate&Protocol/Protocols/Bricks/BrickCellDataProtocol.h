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

@class BrickCell;
@class Brick;

@protocol BrickCellDataProtocol <NSObject>

@required
- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter;

@property (nonatomic, weak) BrickCell *brickCell;
@property (nonatomic) NSInteger lineNumber;
@property (nonatomic) NSInteger parameterNumber;

@end

@protocol BrickCellDataDelegate <NSObject>

@required
- (void)updateBrickCellData:(id<BrickCellDataProtocol>)brickCellData withValue:(id)value;
- (void)disableUserInteractionAndHighlight:(BrickCell*)brickCell;
@end

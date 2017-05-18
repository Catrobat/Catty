/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "PointToBrick.h"
#import "Script.h"

@implementation PointToBrick

- (NSString*)brickTitle
{
    return [kLocalizedPointTowards stringByAppendingString:@"\n%@"];
}

- (SpriteObject*) pointedObject
{
    if(!_pointedObject)
        _pointedObject = self.script.object;
    return _pointedObject;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Point To Brick: %@", self.pointedObject];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![self.pointedObject.name isEqualToString:((PointToBrick*)brick).pointedObject.name])
        return NO;
    return YES;
}

#pragma mark - BrickObjectProtocol
- (void)setObject:(SpriteObject *)object forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(object)
        self.pointedObject = object;
}

- (SpriteObject*)objectForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.pointedObject;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    if(spriteObject) {
        SpriteObject *firstObject = nil;
        for(SpriteObject *object in spriteObject.program.objectList) {
            if(![object.name isEqualToString:spriteObject.name] && ![object.name isEqualToString:kLocalizedBackground]) {
                firstObject = object;
                break;
            }
        }
        if(firstObject)
            self.pointedObject = firstObject;
        else
            self.pointedObject = nil;
    }
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    PointToBrick *copy = [super mutableCopyWithContext:context];
    if(self.pointedObject)
        copy.pointedObject = self.pointedObject;
    return copy;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end

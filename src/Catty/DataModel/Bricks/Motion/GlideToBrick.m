/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "GlideToBrick.h"
#import "Script.h"
#import "CBMutableCopyContext.h"
#import "Pocket_Code-Swift.h"

@interface GlideToBrick()
@end

@implementation GlideToBrick

@synthesize durationInSeconds = _durationInSeconds;
@synthesize xDestination = _xDestination;
@synthesize yDestination = _yDestination;

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        return self.durationInSeconds;
    else if(lineNumber == 1 && paramNumber == 0)
        return self.xDestination;
    else if(lineNumber == 1 && paramNumber == 1)
        return self.yDestination;
    
    return nil;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        self.durationInSeconds = formula;
    else if(lineNumber == 1 && paramNumber == 0)
        self.xDestination = formula;
    else if(lineNumber == 1 && paramNumber == 1)
        self.yDestination = formula;
}

- (NSArray*)getFormulas
{
    return @[self.durationInSeconds,self.xDestination,self.yDestination];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.durationInSeconds = [[Formula alloc] initWithInteger:1];
    self.xDestination = [[Formula alloc] initWithInteger:100];
    self.yDestination = [[Formula alloc] initWithInteger:200];
}

- (id)init
{
    if(self = [super init]) {
        self.isInitialized = NO;
    }
    return self;
}

- (NSString*)brickTitle
{
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.script.object andUseCache:NO];
    NSString* localizedSecond;
    if ([self.durationInSeconds isSingleNumberFormula] && durationInSeconds == 1.0) {
        localizedSecond = kLocalizedSecond;
    } else {
        localizedSecond = kLocalizedSeconds;
    }
    return [kLocalizedGlide stringByAppendingString:[@"%@ " stringByAppendingString:[localizedSecond stringByAppendingString:[@"\n"
        stringByAppendingString:[kLocalizedToX
        stringByAppendingString:[@"%@ "
        stringByAppendingString:[kLocalizedYLabel
        stringByAppendingString:@"%@"]]]]]]];
}

#pragma mark - Description
- (NSString*)description
{
    double xDestination = [self.xDestination interpretDoubleForSprite:self.script.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.script.object];
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %f s)", xDestination, yDestination, durationInSeconds];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![self.durationInSeconds isEqualToFormula:((GlideToBrick*)brick).durationInSeconds])
        return NO;
    if(![self.xDestination isEqualToFormula:((GlideToBrick*)brick).xDestination])
        return NO;
    if(![self.yDestination isEqualToFormula:((GlideToBrick*)brick).yDestination])
        return NO;
    return YES;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    return [self mutableCopyWithContext:context AndErrorReporting:NO];
    
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.durationInSeconds getRequiredResources]|[self.xDestination getRequiredResources]|[self.yDestination getRequiredResources];
}
@end

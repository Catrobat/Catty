/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "PlayNoteBrick.h"
#import "Script.h"
#import "CBMutableCopyContext.h"
#import "Pocket_Code-Swift.h"

@interface PlayNoteBrick()
@end

@implementation PlayNoteBrick

@synthesize pitch = _pitch;
@synthesize duration = _duration;

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        return self.pitch;
    else if(lineNumber == 0 && paramNumber == 1)
        return self.duration;
    return nil;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(lineNumber == 0 && paramNumber == 0)
        self.pitch = formula;
    else if(lineNumber == 0 && paramNumber == 1)
        self.duration = formula;
}

- (NSArray*)getFormulas
{
    return @[self.pitch,self.duration];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.pitch = [[Formula alloc] initWithInteger:60];
    self.duration = [[Formula alloc] initWithInteger:1];
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
    NSString* localizedSecond = kLocalizedSeconds;
    return [kLocalizedPlayNote stringByAppendingString:[@" %@ "
                                                    stringByAppendingString:[kLocalizedFor
                                                                                                             stringByAppendingString:[@" %@"
                                                                                                                                stringByAppendingString:kLocalizedBeats
                                                                                                                                                         
                                                                                                                                                                                  ]]]];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PlayNoteBrick"];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![self.pitch isEqualToFormula:((PlayNoteBrick*)brick).pitch])
        return NO;
    if(![self.duration isEqualToFormula:((PlayNoteBrick*)brick).duration])
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
    return [self.pitch getRequiredResources]|[self.duration getRequiredResources];
}
@end

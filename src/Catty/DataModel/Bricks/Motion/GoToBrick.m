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

#import "GoToBrick.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@interface GoToBrick()
@end

@implementation GoToBrick

- (kBrickCategoryType)category
{
    return kMotionBrick;
}

- (id)initWithChoice:(int)choice
{
    self = [super init];
    if (self)
    {
        self.spinnerSelection = choice;
    }
    return self;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.spinnerSelection = kGoToTouchPosition;
    self.goToObject = nil;
}

- (void)setChoice:(NSString*)choice forLineNumber:(NSInteger)lineNumber
andParameterNumber:(NSInteger)paramNumber
{
    if ([choice isEqualToString:kLocalizedGoToTouchPosition]) {
        self.spinnerSelection = kGoToTouchPosition;
    } else  if ([choice isEqualToString:kLocalizedGoToRandomPosition]){
        self.spinnerSelection = kGoToRandomPosition;
    } else {
        self.spinnerSelection = kGoToOtherSpritePosition;
        
        for(SpriteObject *object in self.script.object.scene.objects) {
            if([object.name isEqualToString:choice]) {
                self.goToObject = object;
            }
        }
    }
}

- (NSString *)choiceForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber {
    NSArray *choices = [self possibleChoicesForLineNumber:1 andParameterNumber:0];
    
    int choice = self.spinnerSelection - kGoToTouchPosition;
    
    if(self.spinnerSelection == kGoToOtherSpritePosition) {
        if([choices count] < 3) {
            return choices[0];
        }
 
        for(int i = 2; i < [choices count]; i++) {
            if([self.goToObject.name isEqualToString:choices[i]]) {
                choice = i;
            }
        }
    }
    
    return choices[choice];
}

- (NSArray<NSString *> *)possibleChoicesForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber {
    NSArray<NSString *> *choices = [NSArray arrayWithObjects: kLocalizedGoToTouchPosition, kLocalizedGoToRandomPosition, nil];
    
    for(SpriteObject *object in self.script.object.scene.objects) {
        if(![object.name isEqualToString:kLocalizedBackground] && ![object.name isEqualToString:self.script.object.name]) {
            choices = [choices arrayByAddingObject:object.name];
        }
    }
    
    return choices;
}

- (Brick*)cloneWithScript:(Script *)script
{
    GoToBrick *clone = [[GoToBrick alloc] init];
    clone.script = script;
    clone.spinnerSelection = self.spinnerSelection;
    clone.goToObject = self.goToObject;
    
    return clone;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GoToBrick choice: %d", self.spinnerSelection];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(self.spinnerSelection != ((GoToBrick*)brick).spinnerSelection)
        return NO;
    if(self.spinnerSelection == kGoToOtherSpritePosition && ((GoToBrick*)brick).spinnerSelection == kGoToOtherSpritePosition) {
        if(![self.goToObject.name isEqualToString:((GoToBrick*)brick).goToObject.name]) {
            return NO;
        }
    }
    return YES;
}

- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    GoToBrick *copy = [super mutableCopyWithContext:context];
    if(self.goToObject)
        copy.goToObject = self.goToObject;
    return copy;
}


@end


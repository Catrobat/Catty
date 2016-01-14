/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "SpeakBrick.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Sound.h"

@implementation SpeakBrick

- (id)init
{
    self = [super init];
    if(self) {
    }
    return self;
}

- (NSString*)brickTitle
{
    return kLocalizedSpeak;
}

- (BOOL)requiresStringFormula
{
    return YES;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    Formula *speakFormula = [Formula new];
    FormulaElement *formulaElement = [FormulaElement new];
    formulaElement.type = STRING;
    formulaElement.value = kLocalizedHello;
    speakFormula.formulaTree = formulaElement;
    self.formula = speakFormula;
}

- (void)setText:(NSString*)text
{
    Formula *speakFormula = [Formula new];
    FormulaElement *formulaElement = [FormulaElement new];
    formulaElement.type = STRING;
    formulaElement.value = text;
    speakFormula.formulaTree = formulaElement;
    self.formula = speakFormula;
}

- (NSString*)text
{
    NSError(@"This property can not be accessed and is only used for backward compatibility with ProjectParser for CatrobatLanguage < 0.93");
    return nil;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Speak: %@", self.formula];
}

-(void)setFormula:(Formula *)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(formula)
        self.formula = formula;
}

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.formula;
}

- (NSArray*)getFormulas
{
    return @[self.formula];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kTextToSpeech;
}

@end

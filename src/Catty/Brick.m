/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
#import "Brick.h"
#import "Script.h"
#import "BrickManager.h"
#import "GDataXMLNode.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "IfLogicElseBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicEndBrick.h"
#import "LoopEndBrick.h"

@interface Brick()

@property (nonatomic, readwrite) kBrickCategoryType brickCategoryType;
@property (nonatomic, readwrite) kBrickType brickType;

@end

@implementation Brick

- (id)init
{
    self = [super init];
    if (self) {
        NSString *subclassName = NSStringFromClass([self class]);
        BrickManager *brickManager = [BrickManager sharedBrickManager];
        self.brickType = [brickManager brickTypeForClassName:subclassName];
        self.brickCategoryType = [brickManager brickCategoryTypeForBrickType:self.brickType];
    }
    return self;
}

- (id)initWithSprite:(SpriteObject *)sprite
{
    self = [super init];
    if (self) {
        NSString *subclassName = NSStringFromClass([self class]);
        BrickManager *brickManager = [BrickManager sharedBrickManager];
        self.brickType = [brickManager brickTypeForClassName:subclassName];
        self.brickCategoryType = [brickManager brickCategoryTypeForBrickType:self.brickType];
        self.object = sprite;
    }
    return self;
}

- (BOOL)isSelectableForObject
{
    return YES;
}

- (GDataXMLElement*)toXML
{
    GDataXMLElement *brickXMLElement = [GDataXMLNode elementWithName:[self xmlTagName]];
    GDataXMLElement *brickToObjectReferenceXMLElement = [GDataXMLNode elementWithName:@"object"];
    [brickToObjectReferenceXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../../../../.."]];
    [brickXMLElement addChild:brickToObjectReferenceXMLElement];
    return brickXMLElement;
}

- (NSString*)xmlTagName
{
    NSString *tagName = [NSStringFromClass([self class]) firstCharacterLowercaseString];
    if ([self isKindOfClass:[SpriteObject class]]) {
        tagName = @"object";
        // TODO: how to detect "pointedObject" from SpriteObject class??
    } else if ([self isKindOfClass:[IfLogicElseBrick class]]) {
        tagName = @"ifElseBrick";
    } else if ([self isKindOfClass:[IfLogicBeginBrick class]]) {
        tagName = @"ifBeginBrick";
//        [className isEqualToString:@"IfBeginBrick"] || [className isEqualToString:@"BeginBrick"]
    } else if ([self isKindOfClass:[IfLogicEndBrick class]]) {
        tagName = @"ifEndBrick";
        //[className isEqualToString:@"IfEndBrick"]
    } else if ([self isKindOfClass:[LoopEndBrick class]]) {
        tagName = @"loopEndBrick";
        //[className isEqualToString:@"LoopEndlessBrick"]
    } else if ([self isKindOfClass:[IfLogicElseBrick class]]) {
        tagName = @"ifElseBrick";
//        [className isEqualToString:@"IfElseBrick"] || [className isEqualToString:@"ElseBrick"]
    }
    return tagName;
}

- (NSString*)description
{
    return @"Brick (NO SPECIFIC DESCRIPTION GIVEN! OVERRIDE THE DESCRIPTION METHOD!";
}

-(SKAction*)action
{
    NSError(@"%@ (NO SPECIFIC Action GIVEN! OVERRIDE THE action METHOD!", self.class);
    return nil;
}


- (void)performFromScript:(Script*)script
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(dispatch_block_t)actionBlock
{
    return ^{
        NSError(@"%@ (NO SPECIFIC Action GIVEN! OVERRIDE THE actionBlock METHOD!", self.class);
    };
}


@end

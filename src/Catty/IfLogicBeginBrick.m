//
//  IfLogicBeginBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 5/2/13.
//
//

#import "IfLogicBeginBrick.h"
#import "Formula.h"



@implementation Iflogicbeginbrick

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
}

-(BOOL)checkCondition
{
    BOOL condition = [self.ifCondition interpretBOOLForSprite:self.object];
    return condition;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"If Logic Begin Brick"];
}



@end

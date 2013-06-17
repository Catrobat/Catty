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

#import "Scene.H"
#import "Program.h"
#import "SpriteObject.h"
#import "Script.h"


@implementation Scene


- (id) initWithSize:(CGSize)size andProgram:(Program *)program
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
        
        self.program = program;
        [self startProgram];
    }
    return self;
}



-(void) startProgram
{
    
    for (SpriteObject *obj in self.program.objectList) {
        [self addChild:obj];
        for(Script* script in obj.scriptList) {
            
        }
    }
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if(!self.paused) {
    
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"menu_icon"];
            
            sprite.position = location;
            
            SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
            
            [sprite runAction:[SKAction repeatActionForever:action]];
            
            [self addChild:sprite];
        }
    }
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}



@end

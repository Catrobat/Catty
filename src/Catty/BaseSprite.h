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

#import <GLKit/GLKit.h>

@interface BaseSprite : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (assign) CGSize contentSize;
@property (assign, nonatomic) BOOL showSprite;
@property (assign, nonatomic) GLKVector3 realPosition;        // position - origin is bottom-left
@property (assign, nonatomic) float rotationInDegrees;
@property (assign, nonatomic) float alphaValue;

@property (readonly, strong, nonatomic) NSString *path;
@property (assign, nonatomic) float scaleFactor;    // scale image to fit screen


-(id)init;
-(id)initWithEffect:(GLKBaseEffect*)effect;


// getter
-(CGSize)originalImageSize;

// graphics
-(void)update:(float)dt;
-(void)render;

-(BOOL)loadImageWithPath:(NSString*)path;
-(BOOL)loadImageWithPath:(NSString*)path width:(float)width height:(float)height;
-(void)setOriginalSpriteSize;
-(void)setSpriteSizeWithWidth:(float)width andHeight:(float)height;

@end

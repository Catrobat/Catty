//
//  BrickShapeFactory.h
//  Catty
//
//  Created by luca on 09/06/14.
//
//

#import <Foundation/Foundation.h>

@interface BrickShapeFactory : NSObject

// normal square bricks
// 44px height
+ (void)drawSmallSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;
// 71px height
+ (void)drawMediumSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;
// 94px height
+ (void)drawLargeSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;

// control rounded bricks


@end

//
//  ScriptDeleteButton.m
//  Catty
//
//  Created by luca on 09/05/14.
//
//

#import "ScriptDeleteButton.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@implementation ScriptDeleteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backgroundImage = [UIImage imageNamed:@"delete"];
        backgroundImage = [backgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        self.tintColor = UIColor.redColor;
    }
    return self;
}


@end

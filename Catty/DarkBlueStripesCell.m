//
//  DarkBlueStripesCell.m
//  Catty
//
//  Created by Dominik Ziegler on 2/28/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//


#import "DarkBlueStripesCell.h"
#import "CatrobatBaseCell.h"
#import "Util.h"


#define kDarkBlueStripesCellHeight  124.0f

@implementation DarkBlueStripesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configure {
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, [self getOptimalCellHeight]);

    [self setBackgroundColor:[UIColor clearColor]];

    UIView *bg = [[UIView alloc] initWithFrame:frame];
    bg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkbluestripes"]];
    [self setBackgroundView:bg];

}

-(CGFloat)getOptimalCellHeight {
    CGFloat screenHeight = [Util getScreenHeight];
    return (kDarkBlueStripesCellHeight*screenHeight)/kIphone5ScreenHeight;
}



@end

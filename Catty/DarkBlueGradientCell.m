//
//  DarkBlueGradientCell.m
//  Catty
//
//  Created by Dominik Ziegler on 2/28/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "DarkBlueGradientCell.h"
#import "BackgroundLayer.h"
#import "Util.h"
#import "TableUtil.h"


@implementation DarkBlueGradientCell

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
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, [TableUtil getHeightForImageCell]);
    [self setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundView:[[UIView alloc] init]];
    [self.backgroundView.layer insertSublayer:[self getBackgroundLayerForFrame:frame] atIndex:0];
    
}

-(CAGradientLayer*)getBackgroundLayerForFrame:(CGRect)frame{
    
    CAGradientLayer *grad = [BackgroundLayer darkBlueGradient];
    grad.frame = frame;
    return grad;
}

@end

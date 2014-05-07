//
//  PlaceHolderView.m
//  Catty
//
//  Created by luca on 07/05/14.
//
//

#import "PlaceHolderView.h"
#import "UIDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface PlaceHolderView ()
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;

@end


@implementation PlaceHolderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initPlaceHolder];
        return self;
    }
    return nil;
}

- (void)initPlaceHolder
{
    // setup description label
    self.userInteractionEnabled = NO;
    self.placeholderDescriptionLabel = [UILabel new];
    self.placeholderDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                        UIViewAutoresizingFlexibleRightMargin |
                                                        UIViewAutoresizingFlexibleTopMargin |
                                                        UIViewAutoresizingFlexibleBottomMargin;
    self.placeholderDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.placeholderDescriptionLabel setFont:[UIFont systemFontOfSize:25]];
    self.placeholderDescriptionLabel.text = [NSString stringWithFormat:kUIViewControllerPlaceholderDescriptionStandard,
                                             kUIViewControllerPlaceholderTitleScripts];
    self.placeholderDescriptionLabel.backgroundColor = [UIColor clearColor];
    self.placeholderDescriptionLabel.textColor = UIColor.skyBlueColor;
    self.contentView = self.placeholderDescriptionLabel;
    self.shimmering = YES;
}


@end

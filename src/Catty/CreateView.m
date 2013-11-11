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

#import <QuartzCore/QuartzCore.h>
#import "CreateView.h"
#import "CatrobatProject.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "ImageCache.h"
#import "CAGradientLayer+CatrobatCAGradientExtensions.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "ButtonTags.h"
#import "TTTAttributedLabel.h"

#define kHTMLATagPattern @"(?i)<a([^>]+)>(.+?)</a>"
#define kHTMLAHrefTagPattern @"href=\"(.*?)\""


@implementation CreateView

+ (UIView*)createProgramDetailView:(CatrobatProject*)project target:(id)target {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    view.backgroundColor = [UIColor clearColor];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [self addNameLabelWithProjectName:project.projectName toView:view];
    [self addAuthorLabelWithAuthor:project.author toView:view];
    [self addProgramDescriptionLabelWithDescription:project.description toView:view target:target];
    [self addThumbnailImageWithImageUrlString:project.screenshotSmall toView:view];
    [self addBigImageWithImageUrlString:project.screenshotBig toView:view];
    [self addDownloadButtonToView:view withTarget:target];
    [self addPlayButtonToView:view withTarget:target];
    
    NSDate *projectDate = [NSDate dateWithTimeIntervalSince1970:[project.uploaded doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *uploaded = [dateFormatter stringFromDate:projectDate];
    [self addInformationLabelToView:view withAuthor:project.author downloads:project.downloads uploaded:uploaded version:project.version views:project.views];
    
    return view;
    
}

+ (void) addNameLabelWithProjectName:(NSString*)projectName toView:(UIView*)view
{
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 155, 25)];
    nameLabel.text = projectName;
    [self configureTitleLabel:nameLabel];
    [self setMaxHeightIfGreaterForView:view withHeight:10+25];
        
    [view addSubview:nameLabel];
}

+ (void) addAuthorLabelWithAuthor:(NSString*)author toView:(UIView*)view
{
    
    UILabel* authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 155, 25)];
    authorLabel.text = author;
    [self configureTextLabel:authorLabel];
    [view addSubview:authorLabel];
    [self setMaxHeightIfGreaterForView:view withHeight:30+25];
    
}

+ (CGFloat) addProgramDescriptionLabelWithDescription:(NSString*)description toView:(UIView*)view target:(id)target
{
    UILabel* descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, 155, 25)];
    [self configureTitleLabel:descriptionTitleLabel];
    descriptionTitleLabel.text = NSLocalizedString(@"Description", nil);
    [view addSubview:descriptionTitleLabel];
////////
#warning remove if webteam resolved the issue
    description = [description stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    description = [description stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
/////////
    
    if(!description || [description isEqualToString:@""]) {
        description =  NSLocalizedString(@"No Description available", nil);
        
    }
        
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);

//    CGSize expectedSize = [description sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];

    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    
    CGRect labelBounds = [description boundingRectWithSize:maximumLabelSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
    
    CGSize expectedSize = CGSizeMake(ceilf(labelBounds.size.width), ceilf(labelBounds.size.height));
    
//    CGSize expectedSize = [description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    
    
    
    TTTAttributedLabel* descriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 120, 280, expectedSize.height)];
    [self configureDescriptionLabel:descriptionLabel];
    descriptionLabel.delegate = target;
    descriptionLabel.text = description;
       
    expectedSize = [descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y, descriptionLabel.frame.size.width, expectedSize.height);
    [view addSubview:descriptionLabel];
    
    [self setMaxHeightIfGreaterForView:view withHeight:120+expectedSize.height];
    
    return descriptionLabel.frame.size.height;
}

+ (void) addThumbnailImageWithImageUrlString:(NSString*)imageUrlString toView:(UIView*)view
{
    UIImage* image = [[ImageCache sharedImageCache] getImageWithName:imageUrlString];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(20, 15, 65, 65);
    
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.borderWidth = 1.0;
    
    [view addSubview:imageView];
    
}

+ (void) addBigImageWithImageUrlString:(NSString*)imageUrlString toView:(UIView*)view
{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    CGFloat offset = view.frame.size.height + 10;
    imageView.frame = CGRectMake(82.5, offset, 155, 235);
    
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.borderWidth = 1.0;
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [view addSubview:imageView];
    
    [self setMaxHeightIfGreaterForView:view withHeight:offset + 235];
    
    UIImage* errorImage = [UIImage imageNamed:@"thumbnail_large"];
    imageView.image = [UIImage imageWithContentsOfURL:[NSURL URLWithString:imageUrlString]
                                          placeholderImage:nil
                                          errorImage:errorImage
                                         onCompletion:^(UIImage *image) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [[imageView viewWithTag:kActivityIndicator] removeFromSuperview];
                                                  imageView.image = image;
                                              });
                                         }];
    
    if(!imageView.image) {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activity.tag = kActivityIndicator;
        activity.frame = CGRectMake(imageView.frame.size.width/2.0f - 25.0f/2.0f, imageView.frame.size.height/2.0f - 25.0f/2.0f, 25.0f, 25.0f);
        [imageView addSubview:activity];
        [activity startAnimating];
    }
    

}

+ (void) addDownloadButtonToView:(UIView*)view withTarget:(id)target
{
    NSString *title = NSLocalizedString(@"Download", nil);
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.tag = kDownloadButtonTag;
    downloadButton.frame = CGRectMake(195, 55, 105, 25);
    downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [downloadButton setTitle:title forState:UIControlStateNormal];
    downloadButton.backgroundColor = [UIColor airForceBlueColor];
    [downloadButton addTarget:target action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    [downloadButton setBackgroundImage:[UIImage imageNamed:@"darkblue"] forState:UIControlStateSelected | UIControlStateHighlighted];
    CAGradientLayer *gradientLayer = [CAGradientLayer blueGradientLayerWithFrame:downloadButton.layer.bounds];
    downloadButton.layer.cornerRadius = 3.0f;
    gradientLayer.cornerRadius = downloadButton.layer.cornerRadius;
    //[downloadButton.layer insertSublayer:gradientLayer atIndex:0];
    downloadButton.layer.masksToBounds = YES;
    
    [self addShadowToTitleLabelForButton:downloadButton];
    
    downloadButton.layer.borderColor = [UIColor colorWithRed:41/255.0f green:103/255.0f blue:147/255.0f alpha:0.5f].CGColor;
    downloadButton.layer.borderWidth = 1.0f;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.tag = kActivityIndicator;
    activity.frame = CGRectMake(5, 0, 25, 25);
    [downloadButton addSubview:activity];
    
    
    [view addSubview:downloadButton];
}

+ (void) addPlayButtonToView:(UIView*)view withTarget:(id)target
{
    
    NSString *title = NSLocalizedString(@"Play", nil);
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.tag = kPlayButtonTag;
    playButton.hidden = YES;
    playButton.frame = CGRectMake(195, 55, 105, 25);
    playButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [playButton setTitle:title forState:UIControlStateNormal];
    playButton.backgroundColor = [UIColor clearColor];
    [playButton addTarget:target action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    CAGradientLayer *gradientLayer = [CAGradientLayer greenGradientLayerWithFrame:playButton.layer.bounds];
    playButton.layer.cornerRadius = 3.0f;
    gradientLayer.cornerRadius = playButton.layer.cornerRadius;
    [playButton.layer insertSublayer:gradientLayer atIndex:0];
    playButton.layer.masksToBounds = YES;
    
    [self addShadowToTitleLabelForButton:playButton];
    
    playButton.layer.borderColor = [UIColor colorWithRed:61/255.0f green:118/255.0f blue:26/255.0f alpha:0.5f].CGColor;
    playButton.layer.borderWidth = 1.0f;
    
    
    [view addSubview:playButton];
}

+ (void) addInformationLabelToView:(UIView*)view withAuthor:(NSString*)author downloads:(NSNumber*)downloads uploaded:(NSString*)uploaded version:(NSString*)version views:(NSNumber*)views
{
    CGFloat offset = view.frame.size.height + 10;
    UILabel* informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, offset, 155, 25)];
    informationLabel.text = NSLocalizedString(@"Information", nil);
    [self configureTitleLabel:informationLabel];
    [view addSubview:informationLabel];
    offset += 25.0f;
    
    
    NSArray* informationArray = [[NSArray alloc] initWithObjects:author, downloads, uploaded, version, views, nil];
    NSArray* informationTitleArray = [[NSArray alloc] initWithObjects:
                                                        NSLocalizedString(@"Author", nil),
                                                        NSLocalizedString(@"Downloads", nil),
                                                        NSLocalizedString(@"Uploaded", nil),
                                                        NSLocalizedString(@"Version", nil),
                                                        NSLocalizedString(@"Views", nil) 
                                      , nil];

    int i = 0;
    for(id info in informationArray)
    {
        UILabel* titleLabel = [self getInformationTitleLabelWithTitle:[informationTitleArray objectAtIndex:i] atYPosition:offset];
        [view addSubview:titleLabel];
        
        UILabel* infoLabel = [self getInformationDetailLabelWithTitle:info atYPosition:offset];
        [view addSubview:infoLabel];
        
        offset += 25.0f;
        i++;
    }
        
    [self setMaxHeightIfGreaterForView:view withHeight:offset];
    

}


+ (void) addShadowToTitleLabelForButton:(UIButton*)button
{
    button.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    button.titleLabel.layer.shadowOpacity = 0.3f;
    button.titleLabel.layer.shadowRadius = 1;
    button.titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
}


+ (void) configureTitleLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor blueGrayColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}


+ (void) configureTextLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blueGrayColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}


+ (UILabel*)getInformationTitleLabelWithTitle:(NSString*)title atYPosition:(CGFloat)yPosition
{
    UILabel* titleInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yPosition, 80, 25)];
    titleInformationLabel.text = title;
    titleInformationLabel.textAlignment = NSTextAlignmentRight;
    titleInformationLabel.backgroundColor = [UIColor clearColor];
    titleInformationLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    titleInformationLabel.textColor = [UIColor grayColor];
    return titleInformationLabel;
}

+ (UILabel*)getInformationDetailLabelWithTitle:(NSString*)title atYPosition:(CGFloat)yPosition
{
    UILabel* detailInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, yPosition, 155, 25)];
    detailInformationLabel.text =  [title stringByEscapingHTMLEntities];;
    detailInformationLabel.textColor = [UIColor blueGrayColor];
    detailInformationLabel.font = [UIFont systemFontOfSize:14.0f];
    detailInformationLabel.backgroundColor = [UIColor clearColor];
    return detailInformationLabel;
}

+ (void)setMaxHeightIfGreaterForView:(UIView*)view withHeight:(CGFloat)height
{
    CGRect frame = view.frame;
    if(frame.size.height < height) {
        frame.size.height = height;
        view.frame = frame;
    }
}

+ (void)configureDescriptionLabel:(TTTAttributedLabel*)label
{
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [self configureTextLabel:label];
    label.dataDetectorTypes = UIDataDetectorTypeAll;
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[UIColor brightGrayColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[UIColor whiteColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        
    label.linkAttributes = mutableLinkAttributes;
    label.activeLinkAttributes = mutableActiveLinkAttributes;
}

+ (void)parseHyperlinksForLabel:(TTTAttributedLabel*)label withText:(NSString*)text
{
    NSError* error = nil;
    NSRegularExpression *aTagRegex = [NSRegularExpression regularExpressionWithPattern:kHTMLATagPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *aTags = [aTagRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSRegularExpression *aHrefRegex = [NSRegularExpression regularExpressionWithPattern:kHTMLAHrefTagPattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMapTable* urlRangeMapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    for(int i = [aTags count]-1; i>=0; i--) {
        NSTextCheckingResult* result = [aTags objectAtIndex:i];
        NSString* href = [text substringWithRange:[result rangeAtIndex:1]];
        NSString* name = [text substringWithRange:[result rangeAtIndex:2]];
        
        
        NSTextCheckingResult* urlResult = [aHrefRegex firstMatchInString:href options:0 range:NSMakeRange(0, [href length])];
        NSString* url = [href substringWithRange:[urlResult rangeAtIndex:1]];
        
        NSRange resultRange = [result range];
        NSUInteger offset = text.length;
        text = [text stringByReplacingCharactersInRange:resultRange withString:name];
        offset -= text.length;
        
        NSEnumerator *enumerator = [urlRangeMapTable keyEnumerator];
        NSArray* keys = [enumerator allObjects];
        
        for (NSString* key in keys) {
            
            NSRange nameRange = [[urlRangeMapTable objectForKey:key ] rangeValue];
            nameRange.location = nameRange.location-offset;
            [urlRangeMapTable setObject:[NSValue valueWithRange:nameRange] forKey:key];
        }
        
        NSRange nameRange = NSMakeRange(resultRange.location, name.length);
        [urlRangeMapTable setObject:[NSValue valueWithRange:nameRange] forKey:url];
    }
    
    label.text = text;
    for( NSString* url in urlRangeMapTable)
    {
        NSRange nameRange = [[urlRangeMapTable objectForKey:url ] rangeValue];
        [label addLinkToURL:[NSURL URLWithString:url] withRange:nameRange];
    }

    
}


@end

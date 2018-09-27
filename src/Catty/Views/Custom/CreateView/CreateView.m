/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "CreateView.h"
#import "CatrobatProgram.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "ImageCache.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "ButtonTags.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "EVCircularProgressView.h"
#import "LanguageTranslationDefines.h"
#import "RoundBorderedButton.h"
#import "Util.h"

#define kHTMLATagPattern @"(?i)<a([^>]+)>(.+?)</a>"
#define kHTMLAHrefTagPattern @"href=\"(.*?)\""


@implementation CreateView

+ (CGFloat)height
{
    return [Util screenHeight];
}

+ (UIView*)createProgramDetailView:(CatrobatProgram*)project target:(id)target
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [Util screenWidth], 0)];
    view.backgroundColor = [UIColor clearColor];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self addNameLabelWithProjectName:project.projectName toView:view];
    [self addAuthorLabelWithAuthor:project.author toView:view];
    [self addThumbnailImageWithImageUrlString:project.screenshotSmall toView:view];
    //[self addBigImageWithImageUrlString:project.screenshotBig toView:view];
    [self addDownloadButtonToView:view withTarget:target];
    [self addLoadingButtonToView:view withTarget:target];
    [self addPlayButtonToView:view withTarget:target];
    [self addDownloadAgainButtonToView:view withTarget:target];
    [self addProgramDescriptionLabelWithDescription:project.projectDescription toView:view target:target];

    NSDate *projectDate = [NSDate dateWithTimeIntervalSince1970:[project.uploaded doubleValue]];
    NSString *uploaded = [[CatrobatProgram uploadDateFormatter] stringFromDate:projectDate];
    
    [self addInformationLabelToView:view withAuthor:project.author downloads:project.downloads uploaded:uploaded version:project.size views:project.views];
    
    [self addReportButtonToView:view withTarget:target];
    return view;
}

+ (void)addNameLabelWithProjectName:(NSString*)projectName toView:(UIView*)view
{
    CGFloat height = [self height];
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width/2-10,height*0.05f, 155, 25)];
    nameLabel.text = projectName;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.numberOfLines = 2;
    [self configureTitleLabel:nameLabel andHeight: height];
    [nameLabel sizeToFit];
    [self setMaxHeightIfGreaterForView:view withHeight:nameLabel.frame.origin.y+nameLabel.frame.size.height];
    
    [view addSubview:nameLabel];
}
//+ (void)addAuthorImageToView:(UIView*)view
//{
//    CGFloat height = [self height];
//    UIImageView* authorImage = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width/2-10, height*0.12f+5, 15, 15)];
//    authorImage.image = [UIImage imageNamed:@"authorIcon"];
//    [view addSubview:authorImage];
//    [self setMaxHeightIfGreaterForView:view withHeight:authorImage.frame.origin.y+authorImage.frame.size.height];
//    
//}

+ (void)addAuthorLabelWithAuthor:(NSString*)author toView:(UIView*)view
{
    CGFloat height = [self height];
    UILabel* authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width/2-10,view.frame.size.height+5, 155, 25)];
    authorLabel.text = author;
    [self configureAuthorLabel:authorLabel andHeight:height];
    [view addSubview:authorLabel];
    [self setMaxHeightIfGreaterForView:view withHeight:authorLabel.frame.origin.y+authorLabel.frame.size.height];
}


+ (CGFloat)addProgramDescriptionLabelWithDescription:(NSString*)description toView:(UIView*)view target:(id)target
{
    CGFloat height = [self height];
    [self addHorizontalLineToView:view andHeight:height*0.35-15];
    UILabel* descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width/15, height*0.35f, 155, 25)];
    [self configureTitleLabel:descriptionTitleLabel andHeight:height];
    descriptionTitleLabel.text = kLocalizedDescription;
    [view addSubview:descriptionTitleLabel];
    
    description = [description stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    description = [description stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    
    
    if ((! description) || [description isEqualToString:@""]) {
        description = kLocalizedNoDescriptionAvailable;
        
    }
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    //    CGSize expectedSize = [description sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    NSDictionary *attributes;
    if (height == kIpadScreenHeight) {
        attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:20] forKey:NSFontAttributeName];
    }else{
        attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    }
    
    
    CGRect labelBounds = [description boundingRectWithSize:maximumLabelSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
    CGSize expectedSize = CGSizeMake(ceilf(labelBounds.size.width), ceilf(labelBounds.size.height));
    //    CGSize expectedSize = [description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    TTTAttributedLabel* descriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    if (height == kIpadScreenHeight) {
        descriptionLabel.frame = CGRectMake(view.frame.size.width/15, height*0.35f+40, 540, expectedSize.height);
    }else{
        descriptionLabel.frame = CGRectMake(view.frame.size.width/15, height*0.35f+40, 280, expectedSize.height);
    }
    
    
    [self configureDescriptionLabel:descriptionLabel];
    descriptionLabel.delegate = target;
    descriptionLabel.text = description;
    
    //    expectedSize = [descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y, descriptionLabel.frame.size.width, expectedSize.height);
    [view addSubview:descriptionLabel];
    [self setMaxHeightIfGreaterForView:view withHeight:height*0.35f+40+expectedSize.height];
    return descriptionLabel.frame.size.height;
}

+ (void)addThumbnailImageWithImageUrlString:(NSString*)imageUrlString toView:(UIView*)view
{
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage* errorImage = [UIImage imageNamed:@"thumbnail_large"];
    imageView.frame = CGRectMake(view.frame.size.width/15, view.frame.size.height*0.1, view.frame.size.width/3, [Util screenHeight]/4.5f);
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
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.tag = kActivityIndicator;
        activity.frame = CGRectMake(imageView.frame.size.width/2.0f - 25.0f/2.0f, imageView.frame.size.height/2.0f - 25.0f/2.0f, 25.0f, 25.0f);
        [imageView addSubview:activity];
        [activity startAnimating];
    }

    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = 8.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor utilityTintColor].CGColor;
    imageView.layer.borderWidth = 1.0;
    
    [view addSubview:imageView];
}

//+ (void) addBigImageWithImageUrlString:(NSString*)imageUrlString toView:(UIView*)view
//{
//    CGFloat height = [self height];
//    UIImageView *imageView = [[UIImageView alloc] init];
//    CGFloat offset = view.frame.size.height + height*0.05;
//    if (height==kIpadScreenHeight) {
//        imageView.frame = CGRectMake(view.frame.size.width/2-125, offset, 255, 335);
//    }else{
//        imageView.frame = CGRectMake(view.frame.size.width/2-75, offset, 155, 235);
//    }
//
//
//    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    imageView.layer.borderWidth = 1.0;
//    imageView.layer.masksToBounds = YES;
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [view addSubview:imageView];
//
//    [self setMaxHeightIfGreaterForView:view withHeight:offset + imageView.frame.size.height];
//
//    UIImage* errorImage = [UIImage imageNamed:@"thumbnail_large"];
//    imageView.image = [UIImage imageWithContentsOfURL:[NSURL URLWithString:imageUrlString]
//                                     placeholderImage:nil
//                                           errorImage:errorImage
//                                         onCompletion:^(UIImage *image) {
//                                             dispatch_async(dispatch_get_main_queue(), ^{
//                                                 [[imageView viewWithTag:kActivityIndicator] removeFromSuperview];
//                                                 imageView.image = image;
//                                             });
//                                         }];
//
//    if(!imageView.image) {
//        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        activity.tag = kActivityIndicator;
//        activity.frame = CGRectMake(imageView.frame.size.width/2.0f - 25.0f/2.0f, imageView.frame.size.height/2.0f - 25.0f/2.0f, 25.0f, 25.0f);
//        [imageView addSubview:activity];
//        [activity startAnimating];
//    }
//
//
//}

+ (void) addDownloadButtonToView:(UIView*)view withTarget:(id)target
{
    UIButton *downloadButton = [[RoundBorderedButton alloc] initWithFrame:CGRectMake(view.frame.size.width-75,view.frame.size.height*0.1+[Util screenHeight]/4.5f-25, 70, 25) andBorder:YES];
    downloadButton.tag = kDownloadButtonTag;
    downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    downloadButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    downloadButton.titleLabel.minimumScaleFactor = 0.4;
    [downloadButton setTitle:kLocalizedDownload forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor buttonTintColor]];
    
    [downloadButton addTarget:target action:@selector(downloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.tag = kActivityIndicator;
    activity.frame = CGRectMake(5, 0, 25, 25);
    [downloadButton addSubview:activity];
    
    [view addSubview:downloadButton];
}

+ (void)addPlayButtonToView:(UIView*)view withTarget:(id)target
{
    UIButton *playButton = [[RoundBorderedButton alloc] initWithFrame:CGRectMake(view.frame.size.width-75,view.frame.size.height*0.1+[Util screenHeight]/4.5f-25, 70, 25) andBorder:YES];
    playButton.tag = kPlayButtonTag;
    playButton.hidden = YES;
    playButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    playButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    playButton.titleLabel.minimumScaleFactor = 0.4;
    [playButton setTitle:kLocalizedOpen forState:UIControlStateNormal];
    [playButton addTarget:target action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [playButton setTintColor:[UIColor buttonTintColor]];
    
    
    [view addSubview:playButton];
}

+ (void)addDownloadAgainButtonToView:(UIView*)view withTarget:(id)target
{
    RoundBorderedButton *downloadAgainButton = [[RoundBorderedButton alloc] initWithFrame:CGRectMake(view.frame.size.width/2-10,view.frame.size.height*0.1+[Util screenHeight]/4.5f-25, 100, 25) andBorder:NO];
    downloadAgainButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [downloadAgainButton setTitleColor:[UIColor buttonTintColor] forState:UIControlStateNormal];
    [downloadAgainButton setTitleColor:[UIColor buttonHighlightedTintColor] forState:UIControlStateHighlighted];
    [downloadAgainButton setTitle:kLocalizedDownload forState:UIControlStateNormal];
    downloadAgainButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    downloadAgainButton.titleLabel.minimumScaleFactor = 0.4;
    [downloadAgainButton addTarget:target action:@selector(downloadAgain) forControlEvents:UIControlEventTouchUpInside];
    downloadAgainButton.tag = kDownloadAgainButtonTag;
    downloadAgainButton.hidden = YES;
    
    [view addSubview:downloadAgainButton];
}

+ (void)addLoadingButtonToView:(UIView*)view withTarget:(id)target
{
    EVCircularProgressView *button = [[EVCircularProgressView alloc] init];
    button.tag = kStopLoadingTag;
    button.tintColor = [UIColor buttonTintColor];
    button.frame = CGRectMake(view.frame.size.width-40,view.frame.size.height*0.1+[Util screenHeight]/4.5f-25, 28, 28);
    button.hidden = YES;
    [button addTarget:target action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

+ (void)addInformationLabelToView:(UIView*)view withAuthor:(NSString*)author downloads:(NSNumber*)downloads uploaded:(NSString*)uploaded version:(NSString*)version views:(NSNumber*)views
{
    CGFloat height = [self height];
    CGFloat offset = view.frame.size.height + height*0.05f;
    [self addHorizontalLineToView:view andHeight:offset-15];
    UILabel* informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width/15, offset, 155, 25)];
    informationLabel.text = kLocalizedInformation;
    [self configureTitleLabel:informationLabel andHeight:height];
    [view addSubview:informationLabel];
    offset += height*0.075;
        
    version = [version stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
    version = [version stringByAppendingString:@" MB"];

    NSArray* informationArray = [[NSArray alloc] initWithObjects:[views stringValue], uploaded, version, [downloads stringValue], nil];
    NSArray* informationTitleArray = [[NSArray alloc] initWithObjects:
                                      [UIImage imageNamed:@"viewsIcon"],
                                      [UIImage imageNamed:@"timeIcon"],
                                      [UIImage imageNamed:@"sizeIcon"],
                                      [UIImage imageNamed:@"downloadIcon"],
                                      nil];
    NSUInteger counter = 0;
    for (id info in informationArray) {
        UIImageView* titleIcon = [self getInformationTitleLabelWithTitle:[informationTitleArray objectAtIndex:counter] atXPosition:view.frame.size.width/12 atYPosition:offset andHeight:height];
        [view addSubview:titleIcon];
        
        UILabel* infoLabel = [self getInformationDetailLabelWithTitle:info atXPosition:view.frame.size.width/12+25  atYPosition:offset andHeight:height];
        [view addSubview:infoLabel];
        
        offset += + height*0.04;
        ++counter;
    }
    [self setMaxHeightIfGreaterForView:view withHeight:offset];
}

+ (void)addReportButtonToView:(UIView*)view withTarget:(id)target
{
    CGFloat height = [self height];
    [self addHorizontalLineToView:view andHeight:view.frame.size.height + height*0.01f-15];
    RoundBorderedButton *reportButton = [[RoundBorderedButton alloc] initWithFrame:CGRectMake(view.frame.size.width/15,view.frame.size.height + height*0.01f, 130, 25) andBorder:NO];
    reportButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [reportButton.titleLabel setTintColor:[UIColor globalTintColor]];
    [reportButton setTitle:kLocalizedReportProgram forState:UIControlStateNormal];
    [reportButton addTarget:target action:@selector(reportProgram) forControlEvents:UIControlEventTouchUpInside];
    [reportButton sizeToFit];
    [reportButton setTintColor:[UIColor buttonTintColor]];
    [reportButton setTitleColor:[UIColor buttonTintColor] forState:UIControlStateNormal];
    [view addSubview:reportButton];
    [self setMaxHeightIfGreaterForView:view withHeight:view.frame.size.height + reportButton.frame.size.height];
}

+ (void)addHorizontalLineToView:(UIView*)view andHeight:(CGFloat)height
{
    [self setMaxHeightIfGreaterForView:view withHeight:height];
    CGFloat offset = view.frame.size.height + 1;
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width/15 -10, offset,view.frame.size.width , 1)];
    lineView.backgroundColor = [UIColor utilityTintColor];
    [view addSubview:lineView];
}

+ (void) addShadowToTitleLabelForButton:(UIButton*)button
{
    button.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    button.titleLabel.layer.shadowOpacity = 0.3f;
    button.titleLabel.layer.shadowRadius = 1;
    button.titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
}


+ (void) configureTitleLabel:(UILabel*)label andHeight:(CGFloat)height
{
    label.backgroundColor = [UIColor clearColor];
    if (height == kIpadScreenHeight) {
        label.font = [UIFont boldSystemFontOfSize:24];
    }else{
        label.font = [UIFont boldSystemFontOfSize:17];
    }
    label.textColor = [UIColor globalTintColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}


+ (void) configureTextLabel:(UILabel*)label andHeight:(CGFloat)height
{
    label.backgroundColor = [UIColor clearColor];
    if (height == kIpadScreenHeight) {
        label.font = [UIFont boldSystemFontOfSize:18];
    }else{
        label.font = [UIFont boldSystemFontOfSize:12];
    }
    label.textColor = [UIColor textTintColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}
+ (void) configureAuthorLabel:(UILabel*)label andHeight:(CGFloat)height
{
    label.backgroundColor = [UIColor clearColor];
    if (height == kIpadScreenHeight) {
        label.font = [UIFont boldSystemFontOfSize:18];
    }else{
        label.font = [UIFont boldSystemFontOfSize:12];
    }
    label.textColor = [UIColor textTintColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
}

+ (UIImageView*)getInformationTitleLabelWithTitle:(UIImage*)icon atXPosition:(CGFloat)xPosition atYPosition:(CGFloat)yPosition andHeight:(CGFloat)height
{
    UIImageView* titleInformation = [[UIImageView alloc] initWithFrame:CGRectMake(xPosition, yPosition, 15, 15)];
    titleInformation.image = icon;
    
    return titleInformation;
}

+ (UILabel*)getInformationDetailLabelWithTitle:(NSString*)title atXPosition:(CGFloat)xPosition atYPosition:(CGFloat)yPosition andHeight:(CGFloat)height
{
    UILabel* detailInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, yPosition, 155, 25)];
    detailInformationLabel.text =  [title stringByEscapingHTMLEntities];
    detailInformationLabel.textColor = [UIColor textTintColor];
    if (height == kIpadScreenHeight) {
        detailInformationLabel.font = [UIFont systemFontOfSize:18.0f];
    }else{
        detailInformationLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    detailInformationLabel.backgroundColor = [UIColor clearColor];
    [detailInformationLabel sizeToFit];
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
    CGFloat height = [self height];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [self configureTextLabel:label andHeight:height];
    label.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[UIColor textTintColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[UIColor brownColor] forKey:(NSString*)kCTForegroundColorAttributeName];
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
    
    for (NSInteger index = ([aTags count] - 1); index >= 0; --index) {
        NSTextCheckingResult* result = [aTags objectAtIndex:index];
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
    for (NSString* url in urlRangeMapTable) {
        NSRange nameRange = [[urlRangeMapTable objectForKey:url ] rangeValue];
        [label addLinkToURL:[NSURL URLWithString:url] withRange:nameRange];
    }
}

@end

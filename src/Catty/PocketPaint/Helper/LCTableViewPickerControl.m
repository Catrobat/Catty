//
//  LCTableViewPickerControl.m
//  InsurancePig
//
//  Created by Leo Chang on 10/21/13.
//  Copyright (c) 2013 Good-idea Consunting Inc. All rights reserved.
//

#import "LCTableViewPickerControl.h"
#import "LanguageTranslationDefines.h"
#import "Pocket_Code-Swift.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kNavBarHeight 44
#define cellIdentifier @"itemPickerCellIdentifier"

@interface LCTableViewPickerControl () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) actionType currentVale;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *aTableView;
@property (nonatomic, assign) NSInteger screenHeight;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) NSInteger navBarOffset;

@end

@implementation LCTableViewPickerControl

@dynamic tag;

- (id)initWithFrame:(CGRect)frame title:(NSString*)title value:(actionType)value items:(NSArray *)array screenHeight:(NSInteger)screenHeight navBarOffset:(NSInteger)navbarOffset
{
    if (self = [super initWithFrame:frame])
    {
        self.currentVale = value;
        self.items = [NSArray arrayWithArray:array];
        self.title = title;
        self.screenHeight = screenHeight;
        self.navBarOffset = navbarOffset;
        
        [self initializeControlWithFrame:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initializeControlWithFrame:(CGRect)frame
{
    /*
     create navigation bar
     */
    self.navBar = [[UINavigationBar alloc] init];
    [_navBar setFrame:CGRectMake(0, 0, frame.size.width, 44)];
    if ([_navBar respondsToSelector:@selector(setBarTintColor:)])
    {
        _navBar.barTintColor = UIColor.navBar;
    }
    else
    {
        _navBar.tintColor = UIColor.navBar;
    }
    /*
     create dismissItem
     */

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    rightButton.tintColor = UIColor.navTint;
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:_title];
    item.rightBarButtonItem = rightButton;
    item.hidesBackButton = YES;
    item.titleView.tintColor = UIColor.globalTint;
    [_navBar pushNavigationItem:item animated:NO];
    self.aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, frame.size.width, frame.size.height - kNavBarHeight-self.navBarOffset) style:UITableViewStylePlain];
    self.aTableView.backgroundColor = UIColor.background;
    self.aTableView.separatorColor = UIColor.globalTint;
    [_aTableView setDelegate:self];
    [_aTableView setDataSource:self];
    [self addSubview:_navBar];
    [self addSubview:_aTableView];
    
    //add UIPanGesture
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self.panRecognizer setMinimumNumberOfTouches:1];
    [self.panRecognizer setMaximumNumberOfTouches:1];
    [self.panRecognizer setDelegate:self];
    [_navBar addGestureRecognizer:self.panRecognizer];

}

- (void)showInView:(UIView *)view
{
    //add mask
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width, view.bounds.size.height+self.height)];
    [_maskView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0]];
    [view insertSubview:_maskView atIndex:0];
    
    //add a Tap gesture in maskView
    if (!_tapGesture)
    {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_maskView addGestureRecognizer:_tapGesture];
    }
    
    [_maskView addGestureRecognizer:_tapGesture];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self setFrame:CGRectMake(0, self.screenHeight - self.height - 10, self.frame.size.width, self.height)];
        [self->_maskView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
    } completion:^(BOOL finished){
        //scroll to currentValue
        [UIView animateWithDuration:0.2 animations:^{
            [self setFrame:CGRectMake(0, self.screenHeight - self.height + 5, self.frame.size.width, self.height)];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.1 animations:^{
                [self setFrame:CGRectMake(0, self.screenHeight - self.height, self.frame.size.width, self.height)];
            } completion:^(BOOL finished){
                //configure your settings after view animation completion
            }];
        }];

        NSInteger index = [self->_items indexOfObject:@(self->_currentVale)];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self->_aTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
}

- (void)tap:(UITapGestureRecognizer*)sender
{
    //common delegate way
    if ([self.delegate respondsToSelector:@selector(selectControl:didCancelWithItem:)])
        [self.delegate selectControl:self didCancelWithItem:@(self.currentVale)];
}

- (void)dismiss
{
    //animation to dismiss
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self setFrame:CGRectMake(0, SCREEN_HEIGHT, self.height, self.frame.size.width)];
        [self->_maskView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0]];
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        [self->_maskView removeFromSuperview];
        self.panRecognizer.enabled = NO;
    }];

}

- (void)dismissPickerView:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(selectControl:didSelectWithItem:)])
        [self.delegate selectControl:self didSelectWithItem:[NSString stringWithFormat:@""]];
}

#pragma mark - handle PanGesture
- (void)move:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gestureRecognizer translationInView:self];
        
        if(translation.y < 0)
            return;
        
        CGPoint translatedCenter = CGPointMake([self center].x, [self center].y + translation.y);
        [self setCenter:translatedCenter];
        [gestureRecognizer setTranslation:CGPointZero inView:self];
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        CGPoint translation = [gestureRecognizer translationInView:self];
        if(translation.y < 0)
            return;
        if ([self.delegate respondsToSelector:@selector(selectControl:didCancelWithItem:)])
            [self.delegate selectControl:self didCancelWithItem:@(self.currentVale)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = [indexPath row];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    actionType item = [[_items objectAtIndex:row] intValue];
    if (item == _currentVale) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.tintColor = UIColor.globalTint;
    cell.textLabel.textColor = UIColor.buttonTint;
    cell.backgroundColor = UIColor.background;
    UIView *selectionView = [UIView new];
    selectionView.backgroundColor = UIColor.navTint;
    [[UITableViewCell appearance] setSelectedBackgroundView:selectionView];

    switch (item) {
        case brush:{
            [cell.textLabel setText:kLocalizedPaintBrush];
            cell.imageView.image = [UIImage imageNamed:@"paintbrush.pointed.fill"];
        }
            break;
        case eraser:{
            [cell.textLabel setText:kLocalizedPaintEraser];
            cell.imageView.image = [UIImage imageNamed:@"eraser.fill"];
        }
            break;
        case resize:{
            [cell.textLabel setText:kLocalizedPaintResize];
            cell.imageView.image = [UIImage imageNamed:@"crop"];
        }
            break;
        case pipette:{
            [cell.textLabel setText:kLocalizedPaintPipette];
            cell.imageView.image = [UIImage imageNamed:@"eyedropper"];
        }
            break;
        case mirror:{
            [cell.textLabel setText:kLocalizedPaintMirror];
            cell.imageView.image = [UIImage imageNamed:@"trapezoid.and.line.vertical"];
        }
            break;
        case image:{
            [cell.textLabel setText:kLocalizedPaintImage];
            cell.imageView.image = [UIImage imageNamed:@"photo"];
        }
            break;
        case line:{
            [cell.textLabel setText:kLocalizedPaintLine];
            cell.imageView.image = [UIImage imageNamed:@"line.diagonal"];
        }
            break;
        case rectangle:{
            [cell.textLabel setText:kLocalizedPaintRect];
            cell.imageView.image = [UIImage imageNamed:@"square.dashed.inset.filled"];
        }
            break;
        case ellipse:{
            [cell.textLabel setText:kLocalizedPaintCircle];
            cell.imageView.image = [UIImage imageNamed:@"circle.dashed.inset.filled"];
        }
            break;
        case stamp:{
            [cell.textLabel setText:kLocalizedPaintStamp];
            cell.imageView.image = [UIImage imageNamed:@"star.square.on.square"];
        }
            break;
        case rotate:{
            [cell.textLabel setText:kLocalizedPaintRotate];
            cell.imageView.image = [UIImage imageNamed:@"rotate.right"];
        }
            break;
        case fillTool:{
            [cell.textLabel setText:kLocalizedPaintFill];
            cell.imageView.image = [UIImage imageNamed:@"oilcan.fill"];
        }
            break;
        case zoom:{
            [cell.textLabel setText:kLocalizedPaintZoom];
            cell.imageView.image = [UIImage imageNamed:@"magnifyingglass"];
        }
            break;
        case pointer:{
            [cell.textLabel setText:kLocalizedPaintPointer];
            cell.imageView.image = [UIImage imageNamed:@"dot.squareshape.split.2x2"];
        }
            break;
        case text:{
            [cell.textLabel setText:kLocalizedPaintTextTool];
            cell.imageView.image = [UIImage imageNamed:@"textformat"];
        }
        default:
            break;
    }
    
    cell.imageView.image = [UIImage imageWithImage:cell.imageView.image scaledToMaxWidth:25 maxHeight:25];
    cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selectControl:didSelectWithItem:)])
        [self.delegate selectControl:self didSelectWithItem:[_items objectAtIndex:indexPath.row]];
}

- (void)cancel
{
    if ([self.delegate respondsToSelector:@selector(selectControl:didCancelWithItem:)])
        [self.delegate selectControl:self didCancelWithItem:@(self.currentVale)];
}


@end

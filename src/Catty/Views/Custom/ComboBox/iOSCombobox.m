/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "iOSCombobox.h"
#import "BSKeyboardControls.h"
#import "UIColor+CatrobatUIColorExtensions.h"

#define BORDER_WIDTH 1.0f
#define BORDER_OFFSET (BORDER_WIDTH / 2)
#define ARROW_BOX_WIDTH 20.0f
#define ARROW_WIDTH 10.0f
#define ARROW_HEIGHT 10.0f

#define FONT_NAME @"Helvetica"
#define TEXT_LEFT 5.0f

#define PICKER_VIEW_HEIGHT 216.0f // This is fixed by Apple, and Stack Overflow reports some bugs can be introduced if it's changed.

@implementation iOSCombobox
@synthesize values = _values;
@synthesize currentValue = _currentValue;

/***********************************************************
 **  INITIALIZATION
 **********************************************************/
- (void)initialize
{
    active = NO;
    self.backgroundColor = [UIColor clearColor];
    CGFloat pickerY = [[UIScreen mainScreen] bounds].size.height - PICKER_VIEW_HEIGHT;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, pickerY, screenWidth, PICKER_VIEW_HEIGHT)];
    [self.pickerView setShowsSelectionIndicator:YES];
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    [self.pickerView selectRow:[self.values indexOfObject:[self currentValue]] inComponent:0 animated:NO];
    self.keyboard = [[BSKeyboardControls alloc] initWithFields:@[self]];
    [self.keyboard setDelegate:self];
    
    self.inputView = self.pickerView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

/***********************************************************
 **  DRAWING
 **********************************************************/
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    

    
    // ============================
    // Background gradient
    // ============================
    CGRect newRect = CGRectMake(rect.origin.x + BORDER_OFFSET,
                                rect.origin.y + BORDER_OFFSET,
                                rect.size.width - BORDER_WIDTH,
                                rect.size.height - BORDER_WIDTH);
    CGPathRef background = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0f].CGPath;
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, background);
    CGContextClip(ctx);
    CGContextRestoreGState(ctx);
    
    // ===========================
    // Background behind arrow
    // ===========================
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, background);
    CGContextClip(ctx);
    CGContextClipToRect(ctx, CGRectMake(rect.size.width - ARROW_BOX_WIDTH,
                                        BORDER_OFFSET,
                                        ARROW_BOX_WIDTH - BORDER_OFFSET,
                                        rect.size.height - BORDER_WIDTH));

    CGContextRestoreGState(ctx);
    
    // ===========================
    // Border around the combobox
    // ===========================
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, BORDER_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextAddPath(ctx, background);
    if (active) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor lightBlueColor].CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    }
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRestoreGState(ctx);
    
    // ============================
    // Line separating arrow / text
    // ============================
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, BORDER_WIDTH);
    if (active) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor lightBlueColor].CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    }
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,
                         rect.size.width - ARROW_BOX_WIDTH,
                         BORDER_WIDTH);
    CGContextAddLineToPoint(ctx,
                            rect.size.width - ARROW_BOX_WIDTH,
                            rect.size.height - BORDER_WIDTH);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    // ============================
    // Draw the arrow
    // ============================
    CGContextSaveGState(ctx);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // the height of the triangle should be probably be about 40% of the height
    // of the overall rectangle, based on the Safari dropdown
    CGFloat centerX = rect.size.width - (ARROW_BOX_WIDTH / 2) - BORDER_OFFSET;
    CGFloat centerY = rect.size.height / 2 + BORDER_OFFSET;
    CGFloat arrowY = centerY - (ARROW_HEIGHT / 2);
    
    CGPathMoveToPoint(path, NULL, centerX - (ARROW_WIDTH / 2), arrowY);
    CGPathAddLineToPoint(path, NULL, centerX + (ARROW_WIDTH / 2), arrowY);
    CGPathAddLineToPoint(path, NULL, centerX, arrowY + ARROW_HEIGHT);
    CGPathCloseSubpath(path);
    
  if (active) {
        CGContextSetFillColorWithColor(ctx, [[UIColor lightBlueColor] CGColor]);
  }
  else {
       CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
  }

    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
    
    // ==============================
    // Draw the text
    // ==============================
    if (self.currentValue == nil && [self.values count] > 0)
    {
        [self setCurrentValue:[[self values] objectAtIndex:0]];
    }
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:FONT_NAME size:rect.size.height/2], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.currentValue drawInRect:CGRectMake(TEXT_LEFT, rect.size.height/2 - rect.size.height/3,
                                             rect.size.width - ARROW_BOX_WIDTH - TEXT_LEFT,
                                             rect.size.height - BORDER_WIDTH)
                         withAttributes:attributes];
    
}

/***********************************************************
 **  DATA SOURCE FOR UIPICKERVIEW
 **********************************************************/
- (void)setValues:(NSArray *)values
{
    _values = values;
    [_pickerView reloadAllComponents];
    if ([_values indexOfObject:_currentValue] != NSNotFound)
    {
        [_pickerView selectRow:[_values indexOfObject:_currentValue] inComponent:0 animated:NO];
    }
}

- (void)setCurrentValue:(NSString *)currentValue
{
    _currentValue = currentValue;
    [self setNeedsDisplay];
    if ([_values indexOfObject:currentValue] != NSNotFound)
    {
        [_pickerView selectRow:[_values indexOfObject:currentValue] inComponent:0 animated:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.values count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.values objectAtIndex:row];
}

/***********************************************************
 **  UIPICKERVIEW DELEGATE COMMANDS
 **********************************************************/
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setCurrentValue:[self.values objectAtIndex:row]];
    [self setNeedsDisplay];
    
    if ([self.delegate respondsToSelector:@selector(comboboxChanged:toValue:)])
    {
        [self.delegate comboboxChanged:self toValue:[self.values objectAtIndex:row]];
    }
}

/***********************************************************
 **  FIRST RESPONDER AND USER INTERFACE
 **********************************************************/
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    [self becomeFirstResponder];
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    
    active = YES;
    [self.keyboard setActiveField:self];
    [self setNeedsDisplay];
    
    if ([[self delegate] respondsToSelector:@selector(comboboxOpened:)])
    {
        [[self delegate] comboboxOpened:self];
    }
    
    return YES;
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    
    active = NO;
    [self setNeedsDisplay];
    
    return YES;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [[keyboardControls activeField] resignFirstResponder];
    [self resignFirstResponder];
}

@end

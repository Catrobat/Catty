/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "ComboBoxView.h"

@interface ComboBoxView () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UIPickerView *pickerView;
@property (nonatomic, weak) UIImageView *arrowImageView;

@end

@implementation ComboBoxView

#pragma mark - getters and setters
- (NSArray*)items
{
    if (! _items) {
        _items = [[NSArray alloc] init];
    }
    return _items;
}

- (NSString*)selectedItem
{
    return self.textField.text;
}

- (void)setEnabled:(BOOL)enabled
{
    self.textField.enabled = enabled;
    _enabled = enabled;
}

- (void)preselectItemAtIndex:(NSUInteger)index
{
    if (index < [self.items count]) {
        self.textField.text = [self.items objectAtIndex:index];
    }
}

- (UITextField*)textField
{
    if (! _textField) {
        CGRect frame = self.frame;
        frame.origin.x = 0.0f;
        frame.origin.y = 0.0f;
        UITextField *textField = [[UITextField alloc] initWithFrame:frame];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:textField];
        _textField = textField;
    }
    return _textField;
}

- (UIPickerView*)pickerView
{
    if (! _pickerView) {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        pickerView.backgroundColor = [UIColor clearColor];
        [self addSubview:pickerView];
        _pickerView = pickerView;
    }
    return _pickerView;
}

- (UIImageView*)arrowImageView
{
    if (! _arrowImageView) {
        UIImage *image = [UIImage imageNamed:@"comboBoxArrow"];
        // TODO: outsource consts
        CGRect frame = CGRectMake((self.frame.size.width - image.size.width), 0.0f, image.size.width, self.frame.size.height);
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:frame];
        arrowImageView.image = image;
        arrowImageView.hidden = NO;
        arrowImageView.layer.cornerRadius = self.textField.layer.cornerRadius;
        [self addSubview:arrowImageView];
        [self bringSubviewToFront:arrowImageView];
        _arrowImageView = arrowImageView;
    }
    return _arrowImageView;
}

- (void)setup
{
    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar sizeToFit];
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                               style:UIBarButtonItemStyleDone target:self
                                                              action:@selector(doneClicked:)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, button, nil]];
    self.pickerView.hidden = YES;
    self.textField.inputView = self.pickerView;
    self.textField.inputAccessoryView = toolbar;
    self.textField.delegate = self;
    [self arrowImageView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self setup];
    }
    return self;
}

#pragma mark - subview lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.textField.text = [self.items objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [self.items count];
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    UILabel *label = (UILabel *)view;
//    if (! label) {
//        CGRect frame = view.frame;
//        label = [[UILabel alloc] initWithFrame:frame];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.backgroundColor = [UIColor clearColor];
//        label.font = [UIFont boldSystemFontOfSize:16];
//        label.textColor = [UIColor whiteColor];
//    }
//    label.text = [self.items objectAtIndex:row];
//    return label;
//}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    [UIMenuController sharedMenuController].menuVisible = NO;
//    [self resignFirstResponder];
//    return NO;
//}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [self.items objectAtIndex:row];
}

- (void)doneClicked:(id) sender
{
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField
{
    self.pickerView.hidden = NO;
    [[self.textField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
    return YES;
}

@end

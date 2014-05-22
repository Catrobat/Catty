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

//
//  EVCircularProgressView.h
//  Test
//
//  Created by Ethan Vaughan on 8/18/13.
//  Copyright (c) 2013 Ethan James Vaughan. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 
 
 EVCircularProgressView is a UIControl subclass that mimics the circular progress view found in iOS 7,
 
 such as the one that is displayed when downloading an app from the App Store. The progress view
 
 initally spins around indeterminately, but then displays a determinate value when the progress property is set
 
 to a non-zero value. To be notified when the user taps the stop button, use addTarget:action:forControlEvents:
 
 with UIControlEventTouchUpInside.
 
 */

@interface EVCircularProgressView : UIControl

// A value from 0 to 1 that indicates how much progress has been made
// When progress is zero, the progress view functions as an indeterminate progress indicator (a spinner)

@property (nonatomic) double progress;

// On iOS 7, progressTintColor sets and gets the tintColor property, and therefore defaults to the value of tintColor
// On iOS 6, defaults to [UIColor blackColor]

@property (nonatomic, strong) UIColor *progressTintColor;

// Set the value of the progress property, optionally animating the change

- (void)setProgress:(double)progress animated:(BOOL)animated;

@end

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

#import "UploadViewController.h"
#import "NetworkDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"

@interface UploadViewController ()

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizedUpload;
    self.view.backgroundColor = [UIColor darkBlueColor];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor lightOrangeColor]
                                                        } forState:UIControlStateSelected];
    
    //[selfsizeLabel setText:[NSString stringWithFormat:@"%@", kLocalizedUsername]];
    [self.sizeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
    self.sizeLabel.textColor = [UIColor lightOrangeColor];
    //[self.passwordLabel setText:kLocalizedPassword];
    [self.programLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
    self.programLabel.textColor = [UIColor lightOrangeColor];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
    self.descriptionLabel.textColor = [UIColor lightOrangeColor];
    
    [self.uploadButton setTitle:kLocalizedUpload forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)uploadButtonClicked:(id)sender {
}

@end

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

#import "AboutPoketCodeOptionTableViewController.h"
#import "LanguageTranslationDefines.h"
#import "NetworkDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "Util.h"

@implementation AboutPoketCodeOptionTableViewController

- (void)setup {
    self.title = kLocalizedAboutPocketCode;
    self.view.backgroundColor = [UIColor backgroundColor];
    self.view.tintColor = [UIColor globalTintColor];
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOTableViewCell cellWithTitle:kLocalizedAboutPocketCodeDescription key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.backgroundColor = [UIColor backgroundColor];
        }]];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        [section addCell:[BOButtonTableViewCell cellWithTitle:kLocalizedSourceCodeLicenseButtonLabel key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
            cell.actionBlock = ^{
                [weakSelf openSourceCodeLicenseURL];
                
            };
        }]];
        [section addCell:[BOButtonTableViewCell cellWithTitle:kLocalizedAboutPocketCode key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.backgroundColor = [UIColor backgroundColor];
            cell.mainColor = [UIColor globalTintColor];
            cell.actionBlock = ^{
                [weakSelf openAboutURL];
            };
        }]];
    }]];
}

- (void)openAboutURL
{
    if (IS_OS_10_OR_LATER) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAboutCatrobatURL] options:[NSDictionary dictionary] completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAboutCatrobatURL]];
    }
}
- (void)openSourceCodeLicenseURL
{
    if (IS_OS_10_OR_LATER) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSourceCodeLicenseURL] options:[NSDictionary dictionary] completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSourceCodeLicenseURL]];
    }
}
@end

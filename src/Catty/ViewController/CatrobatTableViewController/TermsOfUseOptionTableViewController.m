/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "TermsOfUseOptionTableViewController.h"
#import "LanguageTranslationDefines.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"

@implementation TermsOfUseOptionTableViewController

- (void)setup {
    self.title = kLocalizedTermsOfUse;
    self.view.backgroundColor = UIColor.background;
    self.view.tintColor = UIColor.globalTint;
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOTableViewCell cellWithTitle:kLocalizedTermsOfUseDescription key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.backgroundColor = UIColor.background;
        }]];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        [section addCell:[BOButtonTableViewCell cellWithTitle:kLocalizedTermsOfUse key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.backgroundColor = UIColor.background;
            cell.mainColor = UIColor.globalTint;
            cell.actionBlock = ^{
                [weakSelf openTermsOfUse];
                
            };
        }]];
    }]];
}

- (void)openTermsOfUse
{
    [Util openUrlExternal:[NSURL URLWithString:NetworkDefines.termsOfUseUrl]];
}


@end

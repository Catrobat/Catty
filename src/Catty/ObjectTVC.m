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

#import "ObjectTVC.h"
#import "ObjectScriptsCVC.h"
#import "ObjectLooksTVC.h"
#import "ObjectSoundsTVC.h"
#import "SpriteObject.h"
#import "SegueDefines.h"

@interface ObjectTVC ()

@end

@implementation ObjectTVC
# pragma memory for our pointer-properties
@synthesize object = _object;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.object) {
      self.title = self.object.name;
      if (self.navigationItem)
        self.navigationItem.title = self.object.name;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"BackgroundCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  switch (indexPath.row) {
    case 0:
      cell.textLabel.text = @"Scripts";
      break;
    case 1:
      cell.textLabel.text = @"Backgrounds";
      break;
    case 2:
      cell.textLabel.text = @"Sounds";
      break;
  }
  return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Pass the selected object to the new view controller.
  static NSString *toScriptsSegueID = kSegueToScripts;
  static NSString *toLooksSegueID = kSegueToLooks;
  static NSString *toSoundsSegueID = kSegueToSounds;

  if ([sender isKindOfClass:[UITableViewCell class]]) {
    if ([segue.identifier isEqualToString:toScriptsSegueID]) {
      if ([segue.destinationViewController respondsToSelector:@selector(setScripts:)])
        [segue.destinationViewController performSelector:@selector(setScripts:) withObject:self.object.scriptList];
    } else if ([segue.identifier isEqualToString:toLooksSegueID]) {
      if ([segue.destinationViewController respondsToSelector:@selector(setLooks:)])
        [segue.destinationViewController performSelector:@selector(setLooks:) withObject:self.object.lookList];
    } else if ([segue.identifier isEqualToString:toSoundsSegueID]) {
      if ([segue.destinationViewController respondsToSelector:@selector(setSounds:)])
        [segue.destinationViewController performSelector:@selector(setSounds:) withObject:self.object.soundList];
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Pass the selected object to the new view controller.
  static NSString *toScriptsSegueID = kSegueToScripts;
  static NSString *toLooksSegueID = kSegueToLooks;
  static NSString *toSoundsSegueID = kSegueToSounds;

  if (indexPath.row == 0)
    [self performSegueWithIdentifier:toScriptsSegueID sender:self];
  else if (indexPath.row == 1)
    [self performSegueWithIdentifier:toLooksSegueID sender:self];
  else if (indexPath.row == 2)
    [self performSegueWithIdentifier:toSoundsSegueID sender:self];
}

@end

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

#import "BackgroundObjectTVC.h"
#import "BackgroundScriptsCVC.h"
#import "BackgroundLooksTVC.h"
#import "BackgroundSoundsTVC.h"

#define kBackgroundObjectTVCTitle @"Background Objects"

@interface BackgroundObjectTVC ()

@end

@implementation BackgroundObjectTVC
# pragma memory for our pointer-properties
@synthesize backgroundBackgrounds = _backgroundBackgrounds;
@synthesize backgroundScripts = _backgroundScripts;
@synthesize backgroundSounds = _backgroundSounds;

# pragma getters & setters
- (NSMutableArray*)getBackgroundBackgrounds
{
  // lazy instantiation
  if (! _backgroundBackgrounds)
    _backgroundBackgrounds = [NSMutableArray array];
  return _backgroundBackgrounds;
}

- (NSMutableArray*)getBackgroundScripts
{
  // lazy instantiation
  if (! _backgroundScripts)
    _backgroundScripts = [NSMutableArray array];
  return _backgroundScripts;
}

- (NSMutableArray*)getBackgroundSounds
{
  // lazy instantiation
  if (! _backgroundSounds)
    _backgroundSounds = [NSMutableArray array];
  return _backgroundSounds;
}

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
    self.title = kBackgroundObjectTVCTitle;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([sender isKindOfClass:[UITableViewCell class]]) {
    if ([segue.identifier isEqualToString:@"Scripts"]) {
      if ([segue.destinationViewController respondsToSelector:@selector(setScripts:)]) {
        [segue.destinationViewController performSelector:@selector(setScripts:) withObject:self.backgroundScripts];
      }
    }
    
    
    else if ([segue.destinationViewController respondsToSelector:@selector(setSounds:)] && [segue.identifier isEqualToString:@"Sounds"]) {
      [segue.destinationViewController performSelector:@selector(setSounds:) withObject:self.backgroundSounds];
    }
    
    else if ([segue.destinationViewController respondsToSelector:@selector(setLooks:)] && [segue.identifier isEqualToString:@"Looks"]) {
      [segue.destinationViewController performSelector:@selector(setLooks:) withObject:self.backgroundBackgrounds];
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
    [self performSegueWithIdentifier:@"Scripts" sender:self];
  
  else if (indexPath.row == 1)
    [self performSegueWithIdentifier:@"Looks" sender:self];
  
  else if (indexPath.row == 2)
    [self performSegueWithIdentifier:@"Sounds" sender:self];
}

@end

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

#import "NewProgramTVC.h"
#import "BackgroundObjectTVC.h"
#import "SegueDefines.h"
#import "Program.h"
#import "Look.h"
#import "Sound.h"
#import "Brick.h"

enum NewProgramTVCSections
{
    kBackground_Section = 0,
    kObjects_Section
};

#define kBackgroundKey @"backgroundKey"
#define kBackgroundTitleKey @"Background"
#define kBackgroundScriptsKey @"backgroundScriptsKey"
#define kBackgroundLooksKey @"backgroundLooksKey"
#define kBackgroundSoundsKey @"backgroundSoundsKey"

#define kObjectKey @"objectKey"
#define kObjectTitleKey @"Object(s)"
#define kObjectScriptsKey @"objectScriptsKey"
#define kObjectsLooksKey @"objectLooksKey"
#define kObjectSoundsKey @"objectSoundsKey"
#define kObjectName @"objectName"

#define kBackgroundIndex 0
#define kObjectIndex 1


@interface NewProgramTVC () <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate,
                                                                        UINavigationBarDelegate>
@property (strong, nonatomic)NSMutableArray *background;
@property (strong, nonatomic)NSMutableArray *objectsList;
@property (strong, nonatomic)NSString *objectName, *programName;
@property (strong, nonatomic)Program *program;

@property (weak, nonatomic) UIBarButtonItem *play;
@property (weak, nonatomic) UIBarButtonItem *add;

- (IBAction)editProgram:(id)sender;

@end

@implementation NewProgramTVC

- (NSMutableArray *)getObjectList
{
    if (self.dataSourceArray)
        return [self.dataSourceArray objectAtIndex:kObjectIndex];
    else return nil;
}

- (NSMutableArray *)getBackground
{
    if (self.dataSourceArray)
        return [self.dataSourceArray objectAtIndex:kBackgroundIndex];
    else return  nil;
}


/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
*/

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if (![self.programName length])[self newProgramInputView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self.navigationController setToolbarHidden:NO];
    [self setupToolBar];
    
    self.dataSourceArray = [[NSMutableArray alloc]initWithCapacity:2];
    
    self.background = [[NSMutableArray alloc]initWithCapacity:1];
    self.objectsList = [[NSMutableArray alloc]initWithCapacity:5];
   
    self.objectName = @"Start Object";
    self.background = [self createBackground];
    
    [self addObjectToObjectList:[self createNewObject]];
    
    [self.dataSourceArray addObject:self.background];
    [self.dataSourceArray addObject:self.objectsList];
}



#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSourceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kBackgroundIndex:
            return 1;
            break;
        
        case kObjectIndex:
            return [self.objectsList count];
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [[self.background objectAtIndex:indexPath.row] valueForKey:kBackgroundTitleKey];
        //cell.imageView.image = [UIImage imageNamed:@"programs"];
    }
    
    else if (indexPath.section == 1) {
        //        cell = [tableView dequeueReusableCellWithIdentifier:@"kObjectCell" forIndexPath:indexPath];
        cell.textLabel.text = [[self.objectsList objectAtIndex:indexPath.row] valueForKey:kObjectName];
        //cell.imageView.image = [UIImage imageNamed:@"forum"];
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return kBackgroundTitleKey;
    
    else return kObjectTitleKey;
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        }
}


#pragma mark - IBActions

- (IBAction)editProgram:(id)sender
{
    [self sceneActionSheet];
}



#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && actionSheet.tag == 1)
        [self newObjectView];

    else if (buttonIndex == 3 && actionSheet.tag == 2)
        [self newProgramInputView];
}

#pragma mark - UIActionSheet

- (void)sceneActionSheet
{
    UIActionSheet *edit = [[UIActionSheet alloc]initWithTitle:@"Edit Program"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:@"Delete Object(s)"
                                               otherButtonTitles:@"Add Object",
                                                                 @"Save Program", nil];
    [edit setTag:1];
    edit.actionSheetStyle = UIActionSheetStyleDefault;
    //edit.destructiveButtonIndex = 3;
    [edit showInView:self.view];
}

- (void)warningActionSheet
{
    UIActionSheet *warning = [[UIActionSheet alloc]initWithTitle:@"No program name entered, try again."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Ok", nil];
    [warning setTag:2];
    warning.actionSheetStyle = UIActionSheetStyleDefault;
    // [warning setTintColor:[UIColor orangeColor]];
    [warning showInView:self.view];
}

- (void)warningObjectActionSheet
{
    UIActionSheet *warning = [[UIActionSheet alloc]initWithTitle:@"No Object name entered, aborted."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Ok", nil];
    [warning setTag:3];
    warning.actionSheetStyle = UIActionSheetStyleDefault;
    [warning showInView:self.view];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 2) {
        // create a new object
        self.objectName = [[alertView textFieldAtIndex:0]text];
        
        if ([self.objectName length]) {
            [self addObjectToObjectList:[self createNewObject]];
        }
        
        else {
            [self warningObjectActionSheet];
        }
    }
    else if (buttonIndex == 1 && alertView.tag == 1) {
        self.programName = [[alertView textFieldAtIndex:0] text];
        if ([self.programName length]) {
            self.title = self.programName;
        }
        else {
            [self warningActionSheet];
        }
    }

    else if (buttonIndex == 0 && alertView.tag == 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - UIAlertView

- (void)newObjectView
{
    UIAlertView *newObjectAlert = [[UIAlertView alloc]initWithTitle:@"Add Object"
                                                   message:@"Object name:"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Ok", nil];
    [newObjectAlert setTag:2];
    newObjectAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[newObjectAlert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    [newObjectAlert show];
}

- (void)newProgramInputView
{
    UIAlertView *newProgramAlert = [[UIAlertView alloc]initWithTitle:@"Create a new Program"
                                                   message:@"Program name:"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Ok", nil];
    [newProgramAlert setTag:1];
    newProgramAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[newProgramAlert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    [newProgramAlert show];
}


#pragma mark - Helper Methods

- (void)addObjectToObjectList:(NSDictionary *)object
{
    if (self.objectsList) {
        [self.objectsList addObject:object];
    }
    [self.tableView reloadData];
}


- (void)removeObjectFromObjectsListAtIndex:(NSUInteger)index
{
    if (self.objectsList) {
        [self.objectsList removeObjectAtIndex:index];
    }
}


- (void)replaceObject:(NSMutableArray *)object inDataSourceArrayAtIndex:(NSUInteger)index
{
    if ([self.dataSourceArray count])
        [self.dataSourceArray replaceObjectAtIndex:index withObject:object];
    [self.tableView reloadData];
}


- (void)addObjectAction:(id)sender
{
    
}

- (void)playScene:(id)sender
{
    
}

- (void)setupToolBar
{
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = [UIColor orangeColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:self
                                                                             action:nil];
    /*
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                              target:self
                                                              action:@selector(addObjectAction:)];
    
    UIBarButtonItem *play = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                             target:self
                                                             action:@selector(playScene:)];
     */
    NSMutableArray *items = [NSMutableArray arrayWithObjects:self.add, flexItem, self.play, nil];
    
    self.navigationController.toolbarItems = items;

    
    //[self.navigationController setToolbarItems:@[self.add, flexItem, self.play]animated:NO];
}


- (NSDictionary *) createNewObject
{
    NSDictionary *object = @{ kObjectTitleKey: @"Objects",
                                  kObjectName: self.objectName,
                                  kObjectScriptsKey: [NSMutableArray array],
                                  kObjectsLooksKey: [NSMutableArray array],
                                  kObjectSoundsKey: [NSMutableArray array] };
    return object;
}

- (NSMutableArray *)createBackground
{
    NSArray *initArrayBG = @[
                             @{ kBackgroundTitleKey: @"Background",
                                kBackgroundScriptsKey: [NSMutableArray array],
                                kBackgroundLooksKey: [NSMutableArray array],
                                kBackgroundSoundsKey: [NSMutableArray array] }
                             ];
    return [initArrayBG mutableCopy];
}

@end

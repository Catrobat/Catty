/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "ProgramTableViewController.h"
#import "TableUtil.h"
#import "ObjectTableViewController.h"
#import "SegueDefines.h"
#import "Look.h"
#import "Brick.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "Util.h"
#import "UIUtil.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "ProgramUpdateDelegate.h"
#import "CellTagDefines.h"
#import "ProgramTableHeaderView.h"
#import "RuntimeImageCache.h"
#import "NSMutableArray+CustomExtensions.h"
#import "LooksTableViewController.h"
#import "ViewControllerDefines.h"
#import "DescriptionViewController.h"
#import "PlaceHolderView.h"
#import "Pocket_Code-Swift.h"


@interface ProgramTableViewController () <UINavigationBarDelegate, SetDescriptionDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic) BOOL deletionMode;
@end

@implementation ProgramTableViewController

#pragma mark - data helpers
static NSCharacterSet *blockedCharacterSet = nil;
- (NSCharacterSet*)blockedCharacterSet
{
    if (! blockedCharacterSet) {
        blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                               invertedSet];
    }
    return blockedCharacterSet;
}

#pragma mark - getter and setters
- (void)setProgram:(Program *)program
{
    [program setAsLastUsedProgram];
    _program = program;
}

#pragma mark - initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedEdit
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

#pragma mark - view events
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsObjectsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsObjectsKey];
    self.useDetailCells = [showDetailsObjectsValue boolValue];
    [self initNavigationBar];
    [self.tableView registerClass:[ProgramTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.editableSections = @[@(kObjectSectionIndex)];
    if (self.program.header.programName) {
        self.navigationItem.title = self.program.header.programName;
        self.title = self.program.header.programName;
    }
    self.placeHolderView.title = kLocalizedObject;
    [self showPlaceHolder:!(BOOL)[self.program numberOfNormalObjects]];
    [self setupToolBar];
    if(self.showAddObjectActionSheetAtStart) {
        [self addObjectAction:nil];
    }
}

#pragma mark - actions
- (void)addObjectAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    [[[[[[[[AlertControllerBuilder textFieldAlertWithTitle:kLocalizedAddObject message:[NSString stringWithFormat:@"%@:", kLocalizedObjectName]]
     placeholder:kLocalizedEnterYourObjectNameHere]
     addCancelActionWithTitle:kLocalizedCancel handler:^{
         [self cancelAddingObjectFromScriptEditor];
     }]
     addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *name) {
         [self addObjectActionWithName:name];
     }]
     characterValidator:^BOOL(NSString *character) {
         return [kTextFieldAllowedCharacters containsString:character];
     }]
     valueValidator:^InputValidationResult *(NSString *name) {
         InputValidationResult *result = [Util validationResultWithName:name
                                                              minLength:kMinNumOfObjectNameCharacters
                                                              maxlength:kMaxNumOfObjectNameCharacters];
         if (!result.valid) {
             return result;
         }
         if ([[self.program allObjectNames] containsObject:name]) {
             return [InputValidationResult invalidInputWithLocalizedMessage:kLocalizedObjectNameAlreadyExistsDescription];
         }
         return [InputValidationResult validInput];
     }] build]
     showWithController:self];
}

-(void)cancelAddingObjectFromScriptEditor
{
    if (self.afterSafeBlock) {
        self.afterSafeBlock(nil);
    }
}

- (void)addObjectActionWithName:(NSString*)objectName
{
    [self showLoadingView];
    [self.program addObjectWithName:[Util uniqueName:objectName existingNames:[self.program allObjectNames]]];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:kObjectSectionIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:kObjectSectionIndex];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:(([self.program numberOfNormalObjects] == 1) ? UITableViewRowAnimationFade : UITableViewRowAnimationBottom)];

    LooksTableViewController *ltvc = [self.storyboard instantiateViewControllerWithIdentifier:kLooksTableViewControllerIdentifier];
    [ltvc setObject:[self.program.objectList objectAtIndex:(kBackgroundObjectIndex + indexPath.section + indexPath.row)]];
    ltvc.showAddLookActionSheetAtStartForObject = YES;
    ltvc.showAddLookActionSheetAtStartForScriptEditor = NO;
    ltvc.afterSafeBlock =  ^(Look* look) {
        [self.navigationController popViewControllerAnimated:YES];
        if (!look) {
            NSUInteger index = (kBackgroundObjects + indexPath.row);
            SpriteObject *object = (SpriteObject*)[self.program.objectList objectAtIndex:index];
            [self.program removeObjectFromList:object];
            [self.program saveToDiskWithNotification:NO];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:((indexPath.row != 0) ? UITableViewRowAnimationTop : UITableViewRowAnimationFade)];
        }
        if (self.afterSafeBlock && look ) {
            NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:kObjectSectionIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:kObjectSectionIndex];
            self.afterSafeBlock([self.program.objectList objectAtIndex:(kBackgroundObjectIndex + indexPath.section + indexPath.row)]);
        }else if (self.afterSafeBlock && !look){
            self.afterSafeBlock(nil);
        }
        [self showPlaceHolder:!(BOOL)[self.program numberOfNormalObjects]];
    };
    [self.navigationController pushViewController:ltvc animated:NO];
    [self showPlaceHolder:!(BOOL)[self.program numberOfNormalObjects]];
    [self hideLoadingView];
}

- (void)renameProgramActionForProgramWithName:(NSString*)newProgramName
{
    if ([newProgramName isEqualToString:self.program.header.programName])
        return;

    [self showLoadingView];
    NSString *oldProgramName = self.program.header.programName;
    newProgramName = [Util uniqueName:newProgramName existingNames:[Program allProgramNames]];
    [self.program renameToProgramName:newProgramName];
    [self.delegate renameOldProgramWithName:oldProgramName
                                  programID:self.program.header.programID
                           toNewProgramName:self.program.header.programName];
    self.navigationItem.title = self.title = self.program.header.programName;
    [self hideLoadingView];
}

- (void)copyObjectActionWithSourceObject:(SpriteObject*)sourceObject
{
    [self showLoadingView];
    NSString *nameOfCopiedObject = [Util uniqueName:sourceObject.name existingNames:[self.program allObjectNames]];
    [self.program copyObject:sourceObject withNameForCopiedObject:nameOfCopiedObject];

    // create new cell
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:kObjectSectionIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:kObjectSectionIndex];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self hideLoadingView];
}

- (void)renameObjectActionToName:(NSString*)newObjectName spriteObject:(SpriteObject*)spriteObject
{
    if ([newObjectName isEqualToString:spriteObject.name])
        return;

    [self showLoadingView];
    newObjectName = [Util uniqueName:newObjectName existingNames:[self.program allObjectNames]];
    [self.program renameObject:spriteObject toName:newObjectName];
    NSUInteger spriteObjectIndex = [self.program.objectList indexOfObject:spriteObject];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(spriteObjectIndex - kBackgroundObjects)
                                                inSection:kObjectSectionIndex];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self hideLoadingView];
}

- (void)editAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];

    id<AlertControllerBuilding> actionSheet = [[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditProgram]
                                               addCancelActionWithTitle:kLocalizedCancel handler:nil];
    

    if ([self.program numberOfNormalObjects]) {
        [actionSheet addDestructiveActionWithTitle:kLocalizedDeleteObjects handler:^{
            self.deletionMode = YES;
            [self setupEditingToolBar];
            [super changeToEditingMode:sender];
        }];
    }
    if ([self.program numberOfNormalObjects] >= 2) {
        [actionSheet addDefaultActionWithTitle:kLocalizedMoveObjects handler:^{
            self.deletionMode = NO;
            [super changeToMoveMode:sender];
        }];
    }

    NSString *detailActionTitle = self.useDetailCells ? kLocalizedHideDetails : kLocalizedShowDetails;
    
    [[[[[actionSheet
     addDefaultActionWithTitle:kLocalizedRenameProgram handler:^{
         NSMutableArray *unavailableNames = [[Program allProgramNames] mutableCopy];
         [unavailableNames removeString:self.program.header.programName];
         [Util askUserForUniqueNameAndPerformAction:@selector(renameProgramActionForProgramWithName:)
                                             target:self
                                        promptTitle:kLocalizedRenameProgram
                                      promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                        promptValue:((! [self.program.header.programName isEqualToString:kLocalizedNewProgram])
                                                     ? self.program.header.programName : nil)
                                  promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                     minInputLength:kMinNumOfProgramNameCharacters
                                     maxInputLength:kMaxNumOfProgramNameCharacters
                                blockedCharacterSet:[self blockedCharacterSet]
                           invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                      existingNames:unavailableNames];
    }]
    addDefaultActionWithTitle:detailActionTitle handler:^{
        [self toggleDetailCellsMode];
    }]
    addDefaultActionWithTitle:kLocalizedDescription handler:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
        DescriptionViewController * dViewController = [storyboard instantiateViewControllerWithIdentifier:@"DescriptionViewController"];
        dViewController.delegate = self;
        [self.navigationController presentViewController:dViewController animated:YES completion:nil];
    }] build]
    showWithController:self];
}

- (void)toggleDetailCellsMode {
    self.useDetailCells = !self.useDetailCells;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *showDetails = [defaults objectForKey:kUserDetailsShowDetailsKey];
    NSMutableDictionary *showDetailsMutable = nil;
    if (! showDetails) {
        showDetailsMutable = [NSMutableDictionary dictionary];
    } else {
        showDetailsMutable = [showDetails mutableCopy];
    }
    [showDetailsMutable setObject:[NSNumber numberWithBool:self.useDetailCells]
                           forKey:kUserDetailsShowDetailsObjectsKey];
    [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
    [defaults synchronize];
    [self.tableView reloadData];
}

- (void)confirmDeleteSelectedObjectsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self deleteSelectedObjectsAction];
}

- (void)deleteSelectedObjectsAction
{
    [self showLoadingView];
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *objectsToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        // sanity check
        if (selectedRowIndexPath.section != kObjectSectionIndex) {
            continue;
        }
        SpriteObject *object = (SpriteObject*)[self.program.objectList objectAtIndex:(kObjectSectionIndex + selectedRowIndexPath.row)];
        [objectsToRemove addObject:object];
    }
    [self.program removeObjects:objectsToRemove];
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:(([self.program numberOfNormalObjects] != 0) ? UITableViewRowAnimationTop : UITableViewRowAnimationFade)];
    [self showPlaceHolder:!(BOOL)[self.program numberOfNormalObjects]];
    [self hideLoadingView];
}

- (void)deleteObjectForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
    NSUInteger index = (kBackgroundObjects + indexPath.row);
    SpriteObject *object = (SpriteObject*)[self.program.objectList objectAtIndex:index];
    [self.program removeObject:object];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:((indexPath.row != 0) ? UITableViewRowAnimationTop : UITableViewRowAnimationFade)];
    [self showPlaceHolder:!(BOOL)[self.program numberOfNormalObjects]];
    [self hideLoadingView];
}

- (void)deleteProgramAction
{
    [self.delegate removeProgramWithName:self.program.header.programName programID:self.program.header.programID];
    [self.program removeFromDisk];
    self.program = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInProgramTableViewController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kBackgroundSectionIndex:
            return [self.program numberOfBackgroundObjects];
        case kObjectSectionIndex:
            return [self.program numberOfNormalObjects];
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    static NSString *DetailCellIdentifier = kDetailImageCell;
    UITableViewCell *cell = nil;
    if (! self.useDetailCells) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
    }

    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)] || ! [cell isKindOfClass:[CatrobatBaseCell class]]) {
        return cell;
    }

    CatrobatBaseCell<CatrobatImageCell> *imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    NSInteger index = (kBackgroundSectionIndex + indexPath.section + indexPath.row);
    SpriteObject *object = [self.program.objectList objectAtIndex:index];
    imageCell.iconImageView.image = nil;
    [imageCell.iconImageView setBorder:[UIColor utilityTintColor] Width:kDefaultImageCellBorderWidth];

    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = [UIColor textTintColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedScripts,
                                              (unsigned long)[object numberOfScripts]];
        detailCell.topRightDetailLabel.textColor = [UIColor textTintColor];
        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedBricks,
                                               (unsigned long)[object numberOfTotalBricks]];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor textTintColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedLooks,
                                                 (unsigned long)[object numberOfLooks]];
        detailCell.bottomRightDetailLabel.textColor = [UIColor textTintColor];
        detailCell.bottomRightDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedSounds,
                                                  (unsigned long)[object numberOfSounds]];
    }

    if (! [object.lookList count]) {
        imageCell.titleLabel.text = object.name;
        return imageCell;
    }

    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    NSString *previewImagePath = [object previewImagePath];
    NSString *imagePath = [object pathForLook:[object.lookList firstObject]];
    imageCell.iconImageView.image = nil;
    imageCell.indexPath = indexPath;
    
    UIImage *image = [imageCache cachedImageForPath:previewImagePath];
    if (! image) {
        [imageCache loadThumbnailImageFromDiskWithThumbnailPath:previewImagePath
                                                      imagePath:imagePath
                                             thumbnailFrameSize:CGSizeMake(kPreviewImageWidth, kPreviewImageHeight)
                                                   onCompletion:^(UIImage *img, NSString* path){
                                                       // check if cell still needed
                                                       if ([imageCell.indexPath isEqual:indexPath]) {
                                                           imageCell.iconImageView.image = img;
                                                           [imageCell setNeedsLayout];
                                                       }
                                                   }];
    } else {
        imageCell.iconImageView.image = image;
    }
    imageCell.titleLabel.text = object.name;
    return imageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil heightForImageCell];
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // INFO: NEVER REMOVE THIS EMPTY METHOD!!
    // This activates the swipe gesture handler for TableViewCells.
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    if(self.deletionMode) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger index = (kBackgroundSectionIndex + sourceIndexPath.section + sourceIndexPath.row);
    NSInteger destIndex = (kBackgroundSectionIndex + destinationIndexPath.section + destinationIndexPath.row);
    SpriteObject* itemToMove = self.program.objectList[index];
    [self.program.objectList removeObjectAtIndex:index];
    [self.program.objectList insertObject:itemToMove atIndex:destIndex];
    [self.program saveToDiskWithNotification:NO];
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView
                editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewRowAction *moreAction = [UIUtil tableViewMoreRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // More button was pressed
        NSInteger spriteObjectIndex = (kBackgroundSectionIndex + indexPath.section + indexPath.row);
        
        SpriteObject *spriteObject = [self.program.objectList objectAtIndex:spriteObjectIndex];
        
        [[[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditObject]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedCopy handler:^{
             [self copyObjectActionWithSourceObject:spriteObject];
         }]
         addDefaultActionWithTitle:kLocalizedRename handler:^{
             NSMutableArray *unavailableNames = [[self.program allObjectNames] mutableCopy];
             [unavailableNames removeString:spriteObject.name];
             [Util askUserForUniqueNameAndPerformAction:@selector(renameObjectActionToName:spriteObject:)
                                                 target:self
                                           cancelAction:nil
                                             withObject:spriteObject
                                            promptTitle:kLocalizedRenameObject
                                          promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedObjectName]
                                            promptValue:spriteObject.name
                                      promptPlaceholder:kLocalizedEnterYourObjectNameHere
                                         minInputLength:kMinNumOfObjectNameCharacters
                                         maxInputLength:kMaxNumOfObjectNameCharacters
                                    blockedCharacterSet:[self blockedCharacterSet]
                               invalidInputAlertMessage:kLocalizedObjectNameAlreadyExistsDescription
                                          existingNames:unavailableNames];
         }] build]
         viewWillDisappear:^{
             [self.tableView setEditing:false animated:YES];
         }]
         showWithController:self];
    }];
    moreAction.backgroundColor = [UIColor globalTintColor];
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete button was pressed
        // check just to ensure that background object can never be deleted!!
        if (indexPath.section != kObjectSectionIndex) {
            return;
        }
        [[[[[AlertControllerBuilder alertWithTitle:kLocalizedDeleteThisObject message:kLocalizedThisActionCannotBeUndone]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedYes handler:^{
             [self deleteObjectForIndexPath:indexPath];
         }] build]
         showWithController:self];
    }];
    return @[deleteAction, moreAction];
}

#pragma mark - Header View
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 45.0;
        case 1:
            return 50.0;
        default:
            return 45.0;
    }
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    ProgramTableHeaderView *headerView = (ProgramTableHeaderView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    if (section == 0) {
        headerView.textLabel.text = [kLocalizedBackground uppercaseString];
    } else {
        headerView.textLabel.text = (([self.program numberOfNormalObjects] != 1)
                                                    ? [kLocalizedObjects uppercaseString]
                                                    : [kLocalizedObject uppercaseString]);
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    static NSString *segueToObject = kSegueToObject;
    if (! self.editing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self shouldPerformSegueWithIdentifier:segueToObject sender:cell]) {
            [self performSegueWithIdentifier:segueToObject sender:cell];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    ProgramTableHeaderView *headerView = (ProgramTableHeaderView*)view;
    headerView.textLabel.textColor = [UIColor globalTintColor];
}

#pragma mark - segue handler
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass the selected object to the new view controller.
    static NSString *toObjectSegueID = kSegueToObject;

    UIViewController *destController = segue.destinationViewController;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*) sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if ([segue.identifier isEqualToString:toObjectSegueID]) {
            if ([destController isKindOfClass:[ObjectTableViewController class]]) {
                ObjectTableViewController *tvc = (ObjectTableViewController*) destController;
                if ([tvc respondsToSelector:@selector(setObject:)]) {
                    SpriteObject* object = [self.program.objectList objectAtIndex:(kBackgroundObjectIndex + indexPath.section + indexPath.row)];
                    [destController performSelector:@selector(setObject:) withObject:object];
                }
            }
        }
    }
}

#pragma mark - helpers
- (void)setupToolBar
{
    [super setupToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addObjectAction:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, invisibleButton, add, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem, nil];
}

- (void)setupEditingToolBar
{
    [super setupEditingToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(confirmDeleteSelectedObjectsAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, invisibleButton, flexItem,
                         invisibleButton, deleteButton, nil];
}


#pragma mark description delegate
- (void)setDescription:(NSString *)description
{
    [self.program updateDescriptionWithText:description];
}

@end

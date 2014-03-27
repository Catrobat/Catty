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

#import "MyProgramsViewController.h"
#import "Util.h"
#import "ProgramLoadingInfo.h"
#import "Program.h"
#import "ProgramTableViewController.h"
#import "AppDelegate.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "CatrobatImageCell.h"
#import "Logger.h"
#import "SegueDefines.h"
#import "ProgramUpdateDelegate.h"
#import "QuartzCore/QuartzCore.h"
#import "Program.h"
#import "UIDefines.h"
#import "ActionSheetAlertViewTags.h"

@interface MyProgramsViewController () <ProgramUpdateDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *assertCache;
@property (nonatomic, strong) NSMutableArray *programLoadingInfos;
@property (nonatomic, strong) Program *selectedProgram;
@property (nonatomic, strong) Program *defaultProgram;
@end

@implementation MyProgramsViewController

#pragma mark - getters and setters
- (NSMutableDictionary*)assertCache
{
    // lazy instantiation
    if (! _assertCache) {
        _assertCache = [NSMutableDictionary dictionaryWithCapacity:[self.programLoadingInfos count]];
    }
    return _assertCache;
}

#pragma mark - initialization
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.defaultProgram = nil;
    self.selectedProgram = nil;
    [self initTableView];
    [TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"Programs", nil)];
    [self setupToolBar];
    [self loadPrograms];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.defaultProgram = nil;
    self.selectedProgram = nil;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self.tableView reloadData];
}

#pragma mark - system events
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.assertCache = nil;
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.programLoadingInfos = nil;
    
}

#pragma mark - actions
- (void)addProgramAction:(id)sender
{
    static NSString *segueToNewProgram = kSegueToNewProgram;
    if ([self shouldPerformSegueWithIdentifier:segueToNewProgram sender:self]) {
        [self performSegueWithIdentifier:segueToNewProgram sender:sender];
    }
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.programLoadingInfos count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
        [self configureImageCell:imageCell atIndexPath:indexPath];
    }
    NSString *patternName = @"pattern";
    UIColor* color = [self.assertCache objectForKey:patternName];
    if (! color) {
        color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
        [self.assertCache setObject:color forKey:patternName];
    }
    cell.backgroundColor = color;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil getHeightForImageCell];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ProgramLoadingInfo *programLoadingInfo = [self.programLoadingInfos objectAtIndex:indexPath.row];
        [Program removeProgramFromDiskWithProgramName:programLoadingInfo.visibleName];
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        [appDelegate.fileManager deleteDirectory:programLoadingInfo.basePath];
        [self.programLoadingInfos removeObject:programLoadingInfo];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - table view delegate
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - table view helpers
-(void)configureImageCell:(UITableViewCell<CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    ProgramLoadingInfo *info = [self.programLoadingInfos objectAtIndex:indexPath.row];
    cell.titleLabel.text = info.visibleName;
//    cell.iconImageView.image = [UIImage imageNamed:@"programs"];
    NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/small_screenshot.png", info.basePath];
    UIImage* image = [self.assertCache objectForKey:imagePath];
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;

    if (! image) {
        cell.iconImageView.image = nil;
        cell.indexPath = indexPath;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
            NSString *newImagePath = nil;
            //image = [UIImage imageWithContentsOfFile:imagePath];
            if (! image) {
                newImagePath = [[NSString alloc] initWithFormat:@"%@/screenshot.png", info.basePath];
                image = [UIImage imageWithContentsOfFile:newImagePath];
            }

            if (! image) {
                newImagePath = [[NSString alloc] initWithFormat:@"%@/manual_screenshot.png", info.basePath];
                image = [UIImage imageWithContentsOfFile:newImagePath];
            }

            if (! image) {
                newImagePath = [[NSString alloc] initWithFormat:@"%@/automatic_screenshot.png", info.basePath];
                image = [UIImage imageWithContentsOfFile:newImagePath];
            }

            if (! image) {
                image = [UIImage imageNamed:@"programs"];
            }
            //    CGSize imageSize = image.size;
            //    UIGraphicsBeginImageContext(imageSize);
            //    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
            //    image = UIGraphicsGetImageFromCurrentImageContext();
            //    UIGraphicsEndImageContext();

            // perform UI stuff on main queue (UIKit is not thread safe!!)
            dispatch_sync(dispatch_get_main_queue(), ^{
                // check if cell still needed
                if ([cell.indexPath isEqual:indexPath]) {
                    cell.iconImageView.image = image;
                    [cell setNeedsLayout];
                    [self.assertCache setObject:image forKey:imagePath];
                }
            });
        });
    } else {
        cell.iconImageView.image = image;
    }

//    dispatch_queue_t imageQueue = dispatch_queue_create("at.tugraz.ist.catrobat.ImageLoadingQueue", NULL);
//    dispatch_async(imageQueue, ^{
//        
//        NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/screenshot.png", info.basePath];
//        
//        UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
//        if(!image) {
//            imagePath = [[NSString alloc] initWithFormat:@"%@/manual_screenshot.png", info.basePath];
//            image = [UIImage imageWithContentsOfFile:imagePath];
//        }
//        if(!image) {
//            image = [UIImage imageNamed:@"programs"];
//        }
//        
//        
//        CGSize imageSize = image.size;
//        UIGraphicsBeginImageContext(imageSize);
//        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
//        image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView beginUpdates];
//            UITableViewCell <CatrobatImageCell>* cell = (UITableViewCell <CatrobatImageCell>*)[self.tableView cellForRowAtIndexPath:indexPath];
//            if(cell) {
//                cell.iconImageView.image = image;
//            }
//            [self.tableView endUpdates];
//        });
//        
//    });

}

#pragma mark - segue handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    static NSString *segueToContinue = kSegueToContinue;
    static NSString *segueToNewProgram = kSegueToNewProgram;
    if ([identifier isEqualToString:segueToContinue]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *path = [self.tableView indexPathForCell:sender];
            // check if program loaded successfully -> not nil
            self.selectedProgram = [Program programWithLoadingInfo:[self.programLoadingInfos objectAtIndex:path.row]];
            if (self.selectedProgram) {
                return YES;
            }

            // program failed loading...
            [Util alertWithText:kMsgUnableToLoadProgram];
            return NO;
        }
    } else if ([identifier isEqualToString:segueToNewProgram]) {
        // if there is no program name, abort performing this segue and ask user for program name
        // after user entered a valid program name this segue will be called again and accepted
        if (! self.defaultProgram) {
            [Util promptWithTitle:kTitleNewProgram
                          message:kMsgPromptProgramName
                         delegate:self
                      placeholder:kProgramNamePlaceholder
                              tag:kNewProgramAlertViewTag];
            return NO;
        }
        return YES;
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    static NSString *segueToContinue = kSegueToContinue;
    static NSString *segueToNewProgram = kSegueToNewProgram;
    if ([segue.identifier isEqualToString:segueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
                programTableViewController.delegate = self;
                programTableViewController.program = self.selectedProgram;

                // TODO: remove this after persisting programs feature is fully implemented...
                programTableViewController.isNewProgram = NO;
            }
        }
    } else if ([segue.identifier isEqualToString:segueToNewProgram]) {
        ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
        programTableViewController.delegate = self;
        programTableViewController.program = self.defaultProgram;

        // TODO: remove this after persisting programs feature is fully implemented...
        programTableViewController.isNewProgram = YES;
    }
}

#pragma mark - alert view handlers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    static NSString *segueToNewProgramIdentifier = kSegueToNewProgram;
    if (alertView.tag == kNewProgramAlertViewTag) {
        NSString *input = [alertView textFieldAtIndex:0].text;
        if ((buttonIndex == alertView.cancelButtonIndex) || (buttonIndex != kAlertViewButtonOK)) {
            return;
        }
        kProgramNameValidationResult validationResult = [Program validateProgramName:input];
        if (validationResult == kProgramNameValidationResultInvalid) {
            [Util alertWithText:kMsgInvalidProgramName
                       delegate:self
                            tag:kInvalidProgramNameWarningAlertViewTag];
        } else if (validationResult == kProgramNameValidationResultAlreadyExists) {
            [Util alertWithText:kMsgInvalidProgramNameAlreadyExists
                       delegate:self
                            tag:kInvalidProgramNameWarningAlertViewTag];
        } else if (validationResult == kProgramNameValidationResultOK) {
            self.defaultProgram = [Program defaultProgramWithName:input];
            if ([self shouldPerformSegueWithIdentifier:segueToNewProgramIdentifier sender:self]) {
                [self addProgram:input];
                [self performSegueWithIdentifier:segueToNewProgramIdentifier sender:self];
            }
        }
    } else if (alertView.tag == kInvalidProgramNameWarningAlertViewTag) {
        // title of cancel button is "OK"
        if (buttonIndex == alertView.cancelButtonIndex) {
            [Util promptWithTitle:kTitleNewProgram
                          message:kMsgPromptProgramName
                         delegate:self
                      placeholder:kProgramNamePlaceholder
                              tag:kNewProgramAlertViewTag];
        }
    }
}

#pragma mark - program handling
- (void)loadPrograms
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *programLoadingInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    self.programLoadingInfos = [[NSMutableArray alloc] initWithCapacity:[programLoadingInfos count]];
    for (NSString *programLoadingInfo in programLoadingInfos) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([programLoadingInfo isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
        info.basePath = [NSString stringWithFormat:@"%@%@/", basePath, programLoadingInfo];
        info.visibleName = programLoadingInfo;
        NSDebug(@"Adding loaded program: %@", info.basePath);
        [self.programLoadingInfos addObject:info];
    }
}

- (void)addProgram:(NSString *)programName
{
    NSString *basePath = [Program basePath];

    // check if program already exists, then update
    BOOL exists = NO;
    for (ProgramLoadingInfo *programLoadingInfo in self.programLoadingInfos) {
        if ([programLoadingInfo.visibleName isEqualToString:programName])
            exists = YES;
    }
    // add if not exists
    if (! exists) {
        ProgramLoadingInfo *programLoadingInfo = [[ProgramLoadingInfo alloc] init];
        programLoadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", basePath, programName];
        programLoadingInfo.visibleName = programName;
        NSLog(@"Adding program: %@", programLoadingInfo.basePath);
        [self.programLoadingInfos addObject:programLoadingInfo];

        // create new cell
        NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)removeProgram:(NSString *)programName
{
    NSInteger rowIndex = 0;
    for (ProgramLoadingInfo *info in self.programLoadingInfos) {
        if ([info.visibleName isEqualToString:programName]) {
            [self.programLoadingInfos removeObjectAtIndex:rowIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        ++rowIndex;
    }
}

- (void)renameOldProgramName:(NSString *)oldProgramName ToNewProgramName:(NSString *)newProgramName
{
    NSInteger rowIndex = 0;
    for (ProgramLoadingInfo *info in self.programLoadingInfos) {
        if ([info.visibleName isEqualToString:oldProgramName]) {
            ProgramLoadingInfo *newInfo = [[ProgramLoadingInfo alloc] init];
            newInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], newProgramName];
            newInfo.visibleName = newProgramName;
            [self.programLoadingInfos replaceObjectAtIndex:rowIndex withObject:newInfo];

             // flush assert/image cache
            self.assertCache = nil;

            // update table
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        ++rowIndex;
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
                                                                         action:@selector(addProgramAction:)];
    self.toolbarItems = @[flexItem, add, flexItem];
}

@end

//
//  MyProjectsViewController.m
//  Catty
//
//  Created by Christof Stromberger on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "MyProjectsViewController.h"
#import "Util.h"
#import "LevelLoadingInfo.h"
#import "StageViewController.h"

@interface MyProjectsViewController ()

@property (nonatomic, strong) NSMutableArray *levelLoadingInfos;

@end

@implementation MyProjectsViewController

@synthesize levelLoadingInfos = _levelLoadingInfos;

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

    //background image
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"startBackground"]];
    self.view.backgroundColor = background;
    [self.tableView setBackgroundView:nil];
   
    
    //loading levels
    NSString *documentsDirectoy = [Util applicationDocumentsDirectory];
    NSString *levelFolder = @"levels";
    NSString *levelsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectoy, levelFolder];
    
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:levelsPath error:&error];
    [Util log:error];
    
    NSLog(@"my levels: %@", levels);
    
    
    self.levelLoadingInfos = [[NSMutableArray alloc] initWithCapacity:[levels count]];
    for (NSString *level in levels) {
        LevelLoadingInfo *info = [[LevelLoadingInfo alloc] init];
        info.basePath = [NSString stringWithFormat:@"%@/%@/", levelsPath, level];
        info.visibleName = level;
        
        NSLog(@"Adding level: %@", info.basePath);
        
        [self.levelLoadingInfos addObject:info];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.levelLoadingInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];// forIndexPath:indexPath];
    
    LevelLoadingInfo *info = [self.levelLoadingInfos objectAtIndex:indexPath.row];
    
    cell.textLabel.text = info.visibleName;
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([segue.identifier isEqualToString:@"SEGUE_TO_STAGE"])
    {
        //get selected row index
        NSIndexPath *selectedRowIndexPath = self.tableView.indexPathForSelectedRow;
                
        //check if it's the same class
        if ([segue.destinationViewController isKindOfClass:[StageViewController class]])
        {            
            StageViewController *destination = segue.destinationViewController;
            destination.levelLoadingInfo = [self.levelLoadingInfos objectAtIndex:selectedRowIndexPath.row];
        }
        
    }
    
}

@end

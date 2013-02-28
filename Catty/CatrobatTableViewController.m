//
//  CatrobatTableViewController.m
//  Catty
//
//  Created by Dominik Ziegler on 2/27/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "CatrobatTableViewController.h"
#import "CellTags.h"
#import "BackgroundLayer.h"


#define IPHONE5_SCREEN_HEIGHT 568
#define CONTINUE_CELL_HEIGHT  124.0f
#define IMAGE_CELL_HEIGHT     79.0f

@interface CatrobatTableViewController ()

@property (nonatomic, strong) NSArray* cells;
@property (nonatomic, strong) NSArray* images;

@end

@implementation CatrobatTableViewController


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
    
    [self initTableView];
//    self.title = @"Catrobat";
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"catrobat"]];

    UILabel* title = [[UILabel alloc] init];
    title.textColor = [UIColor colorWithRed:111.0f/255.0f green:142.0f/255.0f blue:155.0f/255.0f alpha:1.0f];
    title.font = [UIFont boldSystemFontOfSize:18.0f];
    title.text = @"Catrobat";
    title.backgroundColor = [UIColor clearColor];
    [title sizeToFit];
    
    
    self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:[[UIBarButtonItem alloc] initWithCustomView:imageView], [[UIBarButtonItem alloc] initWithCustomView:title], nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma marks init
-(void)initTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cells = [[NSArray alloc] initWithObjects:@"continue", @"new", @"programs", @"forum", @"download", @"upload", nil];
    //self.images = [[NSArray alloc] initWithObjects:@"continue.png", nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (indexPath.row == 0) ? START_CONTINUE_CELL : START_IMAGE_CELL;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    

    UILabel* titleLabel = (UILabel*)[cell viewWithTag:START_TITLE_TAG];
    titleLabel.text = NSLocalizedString([[self.cells objectAtIndex:indexPath.row] capitalizedString], nil);
    titleLabel.textColor = [UIColor colorWithRed:168.0f/255.0f green:223.0f/255.0f blue:244/255.0f alpha:1.0f];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:START_IMAGE_TAG];
    imageView.image = [UIImage imageNamed: [self.cells objectAtIndex:indexPath.row]];

    
    if(indexPath.row == 0) {
        UILabel* subtitleLabel = (UILabel*)[cell viewWithTag:START_SUBTITLE_TAG];
        subtitleLabel.textColor = [UIColor colorWithRed:212.0f/255.0f green:219.0f/255.0f blue:222.0f/255.0f alpha:1.0f];
        subtitleLabel.text = @"My Zoo";
    }
    

    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self getHeightForCellAtIndexPath:indexPath];
}


#pragma mark Helper

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*) indexPath {
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundView:[[UIView alloc] init]];
    CGRect frame = CGRectMake(0, 0, cell.bounds.size.width, [self getHeightForCellAtIndexPath:indexPath]);
    [cell.backgroundView.layer insertSublayer:[self getBackgroundLayerForCell:cell atIndexPath:indexPath withFrame:frame] atIndex:0];
        
    [cell setSelectedBackgroundView:[self getSelectedBackground]];
}


-(CAGradientLayer*)getBackgroundLayerForCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*) indexPath withFrame:(CGRect)frame{
    
    CAGradientLayer *grad = [BackgroundLayer darkBlueGradient];
    grad.frame = frame;
    
    return grad;
}



-(UIView*)getSelectedBackground{
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.15f]];
    return bgColorView;
}


-(CGFloat)getHeightForCellAtIndexPath:(NSIndexPath*) indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return (indexPath.row == 0) ? (CONTINUE_CELL_HEIGHT*screenHeight)/IPHONE5_SCREEN_HEIGHT : (IMAGE_CELL_HEIGHT*screenHeight)/IPHONE5_SCREEN_HEIGHT;
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

@end

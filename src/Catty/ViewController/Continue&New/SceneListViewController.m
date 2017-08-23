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

#import "SceneListViewController.h"
#import "TableUtil.h"
#import "CatrobatBaseCell.h"
#import "CatrobatImageCell.h"
#import "Scene.h"
#import "SegueDefines.h"
#import "ObjectListViewController.h"

@interface SceneListViewController ()
@property (nonatomic) Scene *selectedScene;
@end

@implementation SceneListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSParameterAssert([segue.identifier isEqualToString:kSegueToObjectList]);
    
    ObjectListViewController *controller = [segue destinationViewController];
    controller.scene = self.selectedScene;
    controller.delegate = self.delegate;
}

- (NSInteger)numberOfScenes {
    return [self.program.scenes count];
}

- (Scene *)sceneAtIndex:(NSInteger)index {
    return self.program.scenes[index];
}

- (Scene *)sceneAtIndexPath:(NSIndexPath *)indexPath {
    return [self sceneAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfScenes];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    if (! [cell isKindOfClass:[CatrobatBaseCell class]] || ! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }
    
    CatrobatBaseCell<CatrobatImageCell> *imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    [self configureImageCell:imageCell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureImageCell:(CatrobatBaseCell<CatrobatImageCell> *)imageCell atIndexPath:(NSIndexPath *)indexPath {
    imageCell.indexPath = indexPath;
    imageCell.titleLabel.text = [self sceneAtIndexPath:indexPath].name;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TableUtil heightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedScene = [self sceneAtIndexPath:indexPath];
    if ([self shouldPerformSegueWithIdentifier:kSegueToObjectList sender:nil]) {
        [self performSegueWithIdentifier:kSegueToObjectList sender:nil];
    }
}

@end

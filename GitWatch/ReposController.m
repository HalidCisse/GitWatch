//
//  ReposController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/10/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ReposController.h"
#import "RepositoryCell.h"
#import "Helper.h"

@interface ReposController ()

@property NSMutableArray *repositories;

@end

@implementation ReposController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common_bg"]];
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    self.title = [NSString stringWithFormat:@"%@ Repositories", self.Organisation.name];
    
    self.repositories = [[NSMutableArray alloc] init];
    
    RACSignal *request = [self.GitClient fetchRepositoriesForOrganization:self.Organisation];
    
    [[request deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTRepository *repository) {
         
         [self.repositories insertObject:repository atIndex:0];
     }
     error:^(NSError *error)
     {
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Something went wrong."] preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
         
         [alert addAction:defaultAction];
         [self presentViewController:alert animated:YES completion:nil];
     } completed:^{
         [self.tableView reloadData];
     } ];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"RepositoryCell";
    
    RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RepositoryCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    OCTRepository *repo =[self.repositories objectAtIndex:indexPath.row];
    
    
    cell.repositoryName.text = repo.name;
    cell.repositoryImage.image = [UIImage imageNamed:@"repoIcon.png"];;
    cell.isFavoriteRepository.on = [Helper IsFavorite:repo.name];
    
    //cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    // Assign our own background image for the cell
//    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
//    
//    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
//    cellBackgroundView.image = background;
//    cell.backgroundView = cellBackgroundView;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
        return nil;
    }
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


//- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
//    NSInteger rowIndex = indexPath.row;
//    UIImage *background = nil;
//    
//    if (rowIndex == 0) {
//        background = [UIImage imageNamed:@"cell_top.png"];
//    } else if (rowIndex == rowCount - 1) {
//        background = [UIImage imageNamed:@"cell_bottom.png"];
//    } else {
//        background = [UIImage imageNamed:@"cell_middle.png"];
//    }
//    
//    return background;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //array is your db, here we just need how many they are
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.repositories count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //this is the space
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    [view setAlpha:0.0F];
    return view;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(RepositoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//        cell.contentView.backgroundColor = [UIColor clearColor];
//        UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.tableView.frame.size.width - 10,100)];
//        whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
//        whiteRoundedCornerView.layer.masksToBounds = NO;
//        whiteRoundedCornerView.layer.cornerRadius = 3.0;
//        whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
//        whiteRoundedCornerView.layer.shadowOpacity = 0.5;
//        [cell.contentView addSubview:whiteRoundedCornerView];
//        [cell.contentView sendSubviewToBack:whiteRoundedCornerView];
//        
//    
//}

@end

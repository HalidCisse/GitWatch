//
//  ReposController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/10/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepositoriesController.h"
#import "RepositoryCell.h"
#import "Helper.h"
#import "ColorHelper.h"

@interface RepositoriesController ()

@property NSMutableArray *repositories;

@end

@implementation RepositoriesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UIImage *temp = [[UIImage imageNamed:@"BackChevron"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStyleBordered target:self action:@selector(onBackClick)];
    self.navigationController.navigationBar. = backButton;
    
    self.navigationController.navigationBar.backgroundColor = [ColorHelper colorFromHexString:@"313B47"];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    self.title = [NSString stringWithFormat:@"%@ Repositories", self.organisation.name];
    
    self.repositories = [[NSMutableArray alloc] init];
    
    RACSignal *request = [self.gitClient fetchRepositoriesForOrganization:self.organisation];
    
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
    
    cell.contentView.userInteractionEnabled = true;
    
    [cell.checkbox setImage:[UIImage imageNamed:@"normalCheckbox"] forState:UIControlStateNormal];
    
    [cell.checkbox setImage:[UIImage imageNamed:@"selectedCheckbox"] forState:UIControlStateSelected];
    
    [cell.checkbox setImage:[UIImage imageNamed:@"selectedCheckbox"] forState:UIControlStateHighlighted];
    
    [cell.checkbox setImage:[UIImage imageNamed:@"selectedCheckbox"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    
    OCTRepository *repo =[self.repositories objectAtIndex:indexPath.row];
    
    cell.repositoryName.text = repo.name;
    cell.repositoryImage.image = [UIImage imageNamed:@"repoIcon.png"];
    
    [cell.checkbox setSelected:[Helper isFavorite:repo.name]];
        
    cell.repositoryImage.layer.cornerRadius = 5;
    cell.repositoryImage.layer.masksToBounds = YES;
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;
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
    return 64;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.repositories count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    [view setAlpha:0.0F];
    return view;
}

- (void)onBackClick:(id)sender{
    
    HomeController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
    view.gitClient = self.gitClient;
    [self.navigationController pushViewController:view animated:YES];
}


@end

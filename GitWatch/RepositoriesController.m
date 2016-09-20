//
//  ReposController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/10/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepositoriesController.h"
#import "RepositoryCell.h"
#import "OrganisationsController.h"
#import "Helper.h"
#import "ColorHelper.h"
#import "Dashboard.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface RepositoriesController ()

- (IBAction)onDone:(id)sender;

@property NSMutableArray *repositories;

@end

@implementation RepositoriesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.repositories = [NSMutableArray new];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0,0,12.5,21)];
    [backButton setImage:[UIImage imageNamed:@"BackChevron"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self setEmptyState:self.organisation.name description:[NSString stringWithFormat:@"When you add repos to %@, they will show up here!", self.organisation.name]];
    self.title = [NSString stringWithFormat:@"%@ Repositories", self.organisation.name];
    
    [self showBusyState];
    [self fetchRepos];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf fetchRepos];
    }];
}

- (void) fetchRepos {
    
    [self.repositories removeAllObjects];
    
    [[[self.gitClient fetchRepositoriesForOrganization:self.organisation] deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTRepository *repository) {
         [self.repositories insertObject:repository atIndex:self.repositories.count > 0 ? self.repositories.count-1 : 0];
         [self hideBusyState];
     }
     error:^(NSError *error)
     {
         [self hideBusyState];
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Something went wrong."] preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
         
         [alert addAction:defaultAction];
         [self presentViewController:alert animated:YES completion:nil];
     } completed:^{}];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *identifier = @"RepositoryCell";
    
    RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RepositoryCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell.checkbox setImage:[UIImage imageNamed:@"normalCheckbox"] forState:UIControlStateNormal];
    [cell.checkbox setImage:[UIImage imageNamed:@"selectedCheckbox"] forState:UIControlStateSelected];
    [cell.checkbox setImage:[UIImage imageNamed:@"selectedCheckbox"] forState:UIControlStateHighlighted];
    [cell.checkbox setImage:[UIImage imageNamed:@"selectedCheckbox"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    OCTRepository *repo;
    if([self.repositories count] != 0){
        repo = [self.repositories objectAtIndex:indexPath.row];
    }
   
    cell.repositoryName.text        = repo.name;
    cell.repositoryDescription.text = repo.repoDescription;
    cell.repositoryImage.image      = [UIImage imageNamed:@"repoIcon.png"];
    
    [cell.checkbox setSelected:[Helper isFavorite:repo.name]];
        
    cell.repositoryImage.layer.cornerRadius  = 5;
    cell.repositoryImage.layer.masksToBounds = YES;
    
    cell.layoutMargins                   = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.accessoryType                   = UITableViewCellAccessoryNone;
    cell.selectionStyle                  = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RepositoryCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [self handleClick:cell];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RepositoryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self handleClick:cell];
}

- (void)onBackClick:(id)sender{
    OrganisationsController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"OrganisationsController"];
    view.gitClient = self.gitClient;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender {
    Dashboard *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Dashboard"];
    view.refresh = true;
    
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    
    [self.navigationController pushViewController:view animated:YES];
    [UIView commitAnimations];
}

- (void) handleClick:(RepositoryCell*)cell {
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"FavoriteRepository.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"FavoriteRepository" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableArray *favoritesRepos = [[NSMutableArray alloc] initWithContentsOfFile:destPath];
    
    if (favoritesRepos == nil) {
        favoritesRepos = [[NSMutableArray alloc] init];
    }
    
    NSString *key =[[NSString alloc]initWithFormat:@"%@",cell.repositoryName.text];
    
    if (cell.checkbox.selected != YES) {
        cell.checkbox.selected = NO;
        if ([favoritesRepos indexOfObject:key] == NSNotFound) {
            [favoritesRepos addObject:key];
        }
    } else {
        cell.checkbox.selected = YES;
        if ([favoritesRepos indexOfObject:key] != NSNotFound) {
            [favoritesRepos removeObject:key];
        }
    }
    
    cell.checkbox.selected = !cell.checkbox.selected;
    [favoritesRepos writeToFile:destPath atomically:YES];
}

@end

//
//  ViewController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Dashboard.h"
#import "ViewController.h"
#import <OctoKit/OctoKit.h>
#import "OrganisationsController.h"
#import "Helper.h"
#import "HomeController.h"
#import <AMSmoothAlert/AMSmoothAlertView.h>
#import "MWKProgressIndicator.h"
#import "Dashboard.h"
#import <FSNetworking/FSNConnection.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]


@interface ViewController () 

@property NSString* kCloseSafariViewControllerNotification;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property SFSafariViewController* safariVC;
@property MBProgressHUD* hud;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.loginButton.layer.cornerRadius = 27.5;
    self.loginButton.clipsToBounds = YES;
    
    _kCloseSafariViewControllerNotification = @"kCloseSafariViewControllerNotification";
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(safariLogin:) name:_kCloseSafariViewControllerNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (IBAction)OnLogin_Click:(id)sender
{
    [self displaySafari];
}

- (void)displaySafari {
    
    NSString *baseURLString = @"https://github.com";
    NSString *clientID      = @"84291409629d7f93ab31";
    NSString *scope         = @"repo";   //@"read:org%20repo:status";
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    CFRelease(uuid);
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@/login/oauth/authorize?client_id=%@&scope=%@&state=%@", baseURLString, clientID, scope, uuidString];
    
    _safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:URLString] entersReaderIfAvailable:NO];
    _safariVC.delegate = self;
    //[self presentViewController:_safariVC animated:YES completion:nil];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:_safariVC];
    [navigationController setNavigationBarHidden:YES animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void) safariLogin: (NSNotification*) notification{
    
    NSURL *url = (NSURL*)notification.object;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *split = [url.absoluteString componentsSeparatedByString:@"&"];
    for (NSString *str in split){
        NSArray *split2 = [str componentsSeparatedByString:@"="];
        [params setObject:split2[1] forKey:split2[0]];
    }
    
    Dashboard *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Dashboard"];
    view.code  = params[@"gitwatch://oauth?code"];
    view.fromLogin  = true;
    [self.navigationController pushViewController:view animated:YES];
    
    [self.safariVC dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - SFSafariViewController delegate methods
-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // Load finished
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end

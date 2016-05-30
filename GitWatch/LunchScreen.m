//
//  LunchScreen.m
//  GitWatch
//
//  Created by Halid Cisse on 5/30/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "LunchScreen.h"

@interface LunchScreen ()

@end

@implementation LunchScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Splash Screen"]];
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  Trash.m
//  GitWatch
//
//  Created by Halid Cisse on 6/24/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>







//    [[[OCTClient
//       signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepositoryStatus|OCTClientAuthorizationScopesOrgRead] deliverOnMainThread]
//     subscribeNext:^(OCTClient *client) {
//         //[MWKProgressIndicator showSuccessMessage:@"success"];
//         [Helper saveCredentials:client];
//
//         Dashboard *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Dashboard"];
//         view.gitClient  = client;
//         view.fromLogin  = true;
//         [self.navigationController pushViewController:view animated:YES];
//     } error:^(NSError *error) {
//
//         if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
//
//             [MWKProgressIndicator dismiss];
//             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"This app does not support 2FA authentication" andCancelButton:false forAlertType:AlertFailure ];
//
//             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
//             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
//             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
//
//             [alert show];
//         } else {
//             [MWKProgressIndicator dismiss];
//             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please retry again" andCancelButton:false forAlertType:AlertFailure ];
//
//             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
//             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
//             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
//
//             [alert show];
//         }
//     }];



//- (void)fetchLastCommit
//{
//    self.lastCommitLabel.text       = @"";
//    self.lastCommitDate.text        = @"";
//    self.lastCommiterName.text      = @"";
//    self.lastCommiterImage.image    = [UIImage imageNamed:@"Octocat"];
//
//    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
//    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/branches", repoPath];
//
//    FSNConnection *connection =
//    [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
//                    method:FSNRequestMethodGET
//                   headers:self.headers
//                parameters:self.parameters
//                parseBlock:^id(FSNConnection *c, NSError **error) {
//                    return [c.responseData arrayFromJSONWithError:error];
//                }
//           completionBlock:^(FSNConnection *c) {
//               NSArray *branches = (NSArray *) c.parseResult;
//               for (NSDictionary *branch in branches) {
//                   if ([[branch objectForKey:@"name"]  isEqual: @"master"]) {
//
//                       NSDictionary *commit = [branch objectForKey:@"commit"];
//                       if (commit == nil) {
//                           return;
//                       }
//                       NSString *commitLink = [commit objectForKey:@"url"];
//                       if (commitLink == nil) {
//                           return;
//                       }
//
//                       FSNConnection *connection =
//                       [FSNConnection withUrl:[[NSURL alloc] initWithString:commitLink]
//                                       method:FSNRequestMethodGET
//                                      headers:self.headers
//                                   parameters:self.parameters
//                                   parseBlock:^id(FSNConnection *c, NSError **error) {
//                                       return [c.responseData dictionaryFromJSONWithError:error];
//                                   }
//                              completionBlock:^(FSNConnection *c) {
//
//                                  @try {
//
//                                      NSDictionary *commitDic = (NSDictionary *) c.parseResult;
//                                      if (commitDic == nil) {
//                                          return;
//                                      }
//
//                                      NSDictionary *commitCommit = [commitDic objectForKey:@"commit"];
//                                      if (commitCommit != nil) {
//                                          NSDictionary *commitCommitter = [commitCommit objectForKey:@"committer"];
//
//                                          if (commitCommitter != nil) {
//                                              self.lastCommitLabel.text =[NSString stringWithFormat:@"%@", [commitCommit objectForKey:@"message"]];
//
//                                              NSString *dateAgo =[[NSDate dateFromString:[commitCommitter objectForKey:@"date"] withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"] timeAgoSinceNow];
//                                              self.lastCommitDate.text = [NSString  stringWithFormat:@"committed %@", dateAgo];
//                                          }
//                                      }
//
//                                      NSDictionary *author = [commitDic objectForKey:@"author"];
//                                    if (author != nil && [author objectForKey:@"avatar_url"] != nil) {
//                                          self.lastCommiterName.text =[author objectForKey:@"login"];
//
//                                          dispatch_async(dispatch_get_global_queue(0,0), ^{
//                                              NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [author objectForKey:@"avatar_url"]]];
//                                              if ( data == nil )
//                                                  return;
//                                              dispatch_async(dispatch_get_main_queue(), ^{
//                                                  self.lastCommiterImage.image = [UIImage imageWithData: data];
//                                              });
//                                          });
//                                          // [self.lastCommiterImage sd_setImageWithURL:[NSURL URLWithString:[author objectForKey:@"avatar_url"]] placeholderImage:[UIImage imageNamed:@"Octocat"]];
//                                      }
//                                  }
//                                  @catch (NSException *exception) {
//
//                                  }
//                              } progressBlock:^(FSNConnection *c) {}];
//                       [connection start];
//                       break;
//                   }
//               }
//           } progressBlock:^(FSNConnection *c) {}];
//    [connection start];
//}


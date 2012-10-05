/**
 * SURFnetConextIOSClient AppDelegate
 * Created by Jochem  Knoops.
 
 * LICENSE
 *
 * Copyright 2012 SURFnet bv, The Netherlands
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and limitations under the License.
 */

#import "AppDelegate.h"
#import "RetrieveRefreshAndAccessTokenTask.h"
#import "AuthenticationDbService.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSURL *urlToParse = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (urlToParse) {
        [self application:application handleOpenURL:urlToParse];
    } 
    
    return YES;
}
	

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    AuthenticationDbService *dbService = [AuthenticationDbService sharedInstance];
    NSString *scheme = [dbService getScheme];
    
    if ([[ url scheme] isEqualToString:scheme] ) {
        if (dbService.isDebugLogEnabled) {
            NSLog(@"found %@", scheme);
        }
        AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
        
        NSString *text = [url absoluteString];

        if ([[ dbService getResponseType] isEqualToString:@"code"]) {
            if (dbService.isTraceLogEnabled) {
                NSLog(@"Response type = code");
            }
            NSArray *param_s = [text componentsSeparatedByString:@"?"];
            NSString *param_1 = [param_s objectAtIndex:1];
            
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSArray *parameters = [param_1 componentsSeparatedByString:@"&"];
            for (NSString *parameter in parameters)
            {
                NSArray *parts = [parameter componentsSeparatedByString:@"="];
                NSString *key = [[parts objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if ([parts count] > 1)
                {
                    id value = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [result setObject:value forKey:key];
                }
            }
            if (dbService.isDebugLogEnabled) {
                NSLog(@"code = %@", [result objectForKey:@"code"]);
            }
            AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
            [dbService setAuthorizationCode:[result objectForKey:@"code"]];
            
            RetrieveRefreshAndAccessTokenTask *task = [[RetrieveRefreshAndAccessTokenTask alloc] init];
            [task executeRetrieveTask];
            
        }
    }

    return YES; //if everything went well
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end

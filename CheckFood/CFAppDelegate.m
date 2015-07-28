//
//  CFAppDelegate.m
//  CheckFood
//
//  Copyright 2014 5emeGauche
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CFAppDelegate.h"
#import "CFNavigationController.h"
#import "CFMyProductsViewController.h"
#import "CFAlertesViewController.h"

@implementation CFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    CFMyProductsViewController *productsVC = [[CFMyProductsViewController alloc] initWithNibName:@"CFMyProductsViewController" bundle:nil];
    
    self.mainNavigationController = [[CFNavigationController alloc] initWithRootViewController:productsVC];
    self.mainNavigationController.navigationBarHidden = YES;
    self.window.rootViewController = self.mainNavigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    UIApplicationState state = [application applicationState];
    NSDictionary *userInfo = notification.userInfo;
    if (state == UIApplicationStateActive) {
        
        NSMutableDictionary *notificationInfo = [userInfo objectForKey:@"notificationInfo"];
        NSMutableDictionary *product = [notificationInfo objectForKey:@"product"];
        NSString *jourRestant = [notificationInfo objectForKey:@"jourRestant"];
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        NSString *msg = @"Le produit ";
        msg = [msg stringByAppendingString:[product objectForKey:@"name"]];
        msg = [msg stringByAppendingString:@" périme dans "];
        msg = [msg stringByAppendingString:jourRestant];
        msg = [msg stringByAppendingString:@" jour(s)"];
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Product Alert"
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:@"Fermer"
                                               otherButtonTitles: @"Afficher", nil];
        [alert show];
        
        NSLog(@"notification %@ user info %@",notification.fireDate,notification.userInfo);
        
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *eventArray = [app scheduledLocalNotifications];
        NSLog(@" new count %d",eventArray.count);
        
    }
    
    else {
        
        CFAlertesViewController *alertVC = [[CFAlertesViewController alloc]initWithNibName:@"CFAlertesViewController" bundle:nil];
        self.mainNavigationController = [[CFNavigationController alloc] initWithRootViewController:alertVC];
        self.mainNavigationController.navigationBarHidden = YES;
        self.window.rootViewController = self.mainNavigationController;
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1)
    {
        CFAlertesViewController *alertVC = [[CFAlertesViewController alloc]initWithNibName:@"CFAlertesViewController" bundle:nil];
        self.mainNavigationController = [[CFNavigationController alloc] initWithRootViewController:alertVC];
        self.mainNavigationController.navigationBarHidden = YES;
        self.window.rootViewController = self.mainNavigationController;
        
        
    }
}

@end

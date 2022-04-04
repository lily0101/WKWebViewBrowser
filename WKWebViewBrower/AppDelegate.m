//
/*
 * AppDelegate.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    

#import "AppDelegate.h"
#import "TapBars/CustomWKWebViewController.h"

@interface AppDelegate () <UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    CustomWKWebViewController *customWebview = [[CustomWKWebViewController alloc]init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:customWebview];
    
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = UIColor.whiteColor;
    [self.window makeKeyAndVisible];
    return YES;
}

@end

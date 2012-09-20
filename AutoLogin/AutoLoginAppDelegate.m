//
//  AutoLoginAppDelegate.m
//  AutoLogin
//
//  Created by Camilo Andrés Vera Bezmalinovic on 6/15/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import "AutoLoginAppDelegate.h"

#import "AutoLoginViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation AutoLoginAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSArray *ssidArray = @[@"usm_alumnos",@"usm_alumnos2",@"usm_visitas",@"usm_profesores",@"usm_magister"];
    CNSetSupportedSSIDs((CFArrayRef)ssidArray);
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end

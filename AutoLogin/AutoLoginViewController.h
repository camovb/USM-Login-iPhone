//
//  AutoLoginViewController.h
//  AutoLogin
//
//  Created by Camilo Andrés Vera Bezmalinovic on 6/15/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "InfoViewController.h"
#import "NSString+AESCrypt.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface AutoLoginViewController : UIViewController <UIWebViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource> {
    IBOutlet UITextField *textFieldUser;
    IBOutlet UITextField *textFieldPass;

    IBOutlet UISwitch *switchAutoConnect;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;    
    //se usa un webView para aceptar las alertas que envian las páginas
    IBOutlet UIWebView *webHidden;
    
    IBOutlet UITableView *tableViewAccounts;
    
    BOOL timeOut;
    
    BOOL tryWithAll;
    
    BOOL notificationSlot[8];
    
}

- (IBAction)saveAccountButtonDidPress:(id)sender;

- (IBAction)buttonLogoutPressed:(id)sender;

- (IBAction)hideKeyboard:(id)sender;

- (IBAction)switchAutoConnectChangeValue:(id)sender;

- (IBAction)infoButtonDidPress:(id)sender;

- (void)showNotificationWithMessage:(NSString*)message;

- (void)tryToConnectWithAccountAtIndex:(NSInteger)index;

-(void)animationStart:(UIButton*)button;
-(void)animationFinish:(UIButton*)button;

-(BOOL)isUsmNetwork;

@end

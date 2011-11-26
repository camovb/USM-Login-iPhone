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

@interface AutoLoginViewController : UIViewController 
<UIWebViewDelegate,UITextFieldDelegate> 
{
    UIWebView *webHidden;
    BOOL timeOut;
            
}
@property(nonatomic,retain) IBOutlet UITextField *textFieldUser;
@property(nonatomic,retain) IBOutlet UITextField *textFieldPass;
@property(nonatomic,retain) IBOutlet UISwitch *rememberOption;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain) IBOutlet UIControl *containerView;;
@property(nonatomic,retain) IBOutlet UIImageView *logo;
@property(nonatomic,retain) IBOutlet UIButton *extensionButton;
@property(nonatomic,retain) IBOutlet UIButton *loginButton;
@property(nonatomic,retain) IBOutlet UIButton *logoutButton; 

@property(nonatomic,retain) IBOutlet UIControl *notificationView;
@property(nonatomic,retain) IBOutlet UILabel   *notificationLabel;
@property(nonatomic,retain) IBOutlet UIImageView *notificationImage;

@property(nonatomic,retain) IBOutlet UIView *rememberView;
@property(nonatomic,retain) IBOutlet UILabel *rememberLabel;
@property(nonatomic,retain) IBOutlet UISwitch *rememberSwitch;

- (IBAction)hideKeyboard:(id)sender;

- (IBAction)loginButtonDidPress:(id)sender;

- (IBAction)extensionButtonDidPress:(id)sender;

- (IBAction)buttonLogoutPressed:(id)sender;

- (IBAction)infoButtonDidPress:(id)sender;

- (IBAction)rememberOptionDidChange:(id)sender;
- (IBAction)rememberSwitchDidChange:(id)sender;


- (IBAction)notificationDidPress:(id)sender;

- (void)showNotificationMessage:(NSString*)message isSuccess:(BOOL)success;


- (void)tryToConnect;

- (BOOL)isUsmNetwork;

@end

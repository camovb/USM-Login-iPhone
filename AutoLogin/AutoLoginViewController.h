//
//  AutoLoginViewController.h
//  AutoLogin
//
//  Created by Camilo Andrés Vera Bezmalinovic on 6/15/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AutoLoginViewController : UIViewController <UIWebViewDelegate,UITextFieldDelegate> {
    IBOutlet UITextField *textFieldUser;
    IBOutlet UITextField *textFieldPass;
    IBOutlet UISwitch *switchRemember;
    IBOutlet UISwitch *switchAutoConnect;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UINavigationBar *navBar;
    
    //se usa un webView para aceptar las alertas que envian las páginas
    IBOutlet UIWebView *webHidden;
    
    BOOL timeOut;
}

- (IBAction)buttonLoginPressed:(id)sender;
- (IBAction)buttonLogoutPressed:(id)sender;

- (IBAction)hideKeyboard:(id)sender;

- (IBAction)switchSaveChangeValue:(id)sender;

- (IBAction)switchAutoConnectChangeValue:(id)sender;
@end

//
//  InfoViewController.m
//  AutoLogin
//
//  Created by Camilo Vera on 8/11/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import "InfoViewController.h"
#import <QuartzCore/QuartzCore.h>

const NSString* urlGithub  = @"https://github.com/camitox/USM-Login-iPhone";

@implementation InfoViewController

@synthesize buttonEmailCamo,
            buttonEmailCan,
            buttonURL,
            labelCreatedBy,
            labelBody;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *buttons = [NSArray arrayWithObjects:buttonURL, buttonEmailCan, buttonEmailCamo, nil];
    
    // Localize strings
    self.labelBody.text = LS(@"info-body", @"El código de la aplicación se encuentra disponible en github:");
    self.labelCreatedBy.text = LS(@"info-createdby", @"Creado por:");
    
    for (UIButton *button in buttons)
    {
        button.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1.0];
        button.layer.cornerRadius = 16.0;
        button.clipsToBounds = YES;
        button.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
}

- (void)infoButtonDidPress:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)URLButtonDidPress:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:(NSString*)urlGithub]];
}

- (void)mailButtonDidPress:(id)sender
{
    const NSString* mailFormat  = @"mailto:jose.canepa@alumnos.usm.cl,camilo.verab@alumnos.usm.cl?subject=%@&body=%@";
    const NSString* mailBody    = LS(@"info-mail-body", @"Camo, Can:\n\nLuego de ver la App USMWifi, pensaba que");
    const NSString* mailSubject = LS(@"info-mail-subject", @"Sobre la app USMWifi");
    
    NSString *urlString = [NSString stringWithFormat:(NSString*)mailFormat,[mailSubject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[mailBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:url];
}

@end

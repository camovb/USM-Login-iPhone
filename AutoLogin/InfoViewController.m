//
//  InfoViewController.m
//  AutoLogin
//
//  Created by Camilo Vera on 8/11/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController

- (IBAction)infoButtonDidPress:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)URLButtonDidPress:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSString *urlString = button.titleLabel.text;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}
@end

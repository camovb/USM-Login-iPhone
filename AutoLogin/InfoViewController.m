//
//  InfoViewController.m
//  AutoLogin
//
//  Created by Camilo Vera on 8/11/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController

- (void)infoButtonDidPress:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)URLButtonDidPress:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSString *urlString = button.titleLabel.text;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

- (void)mailButtonDidPress:(id)sender
{
    NSString *body = @"Camo, Can:\n\nLuego de ver la App USMWifi, pensaba que";
    NSString *title = @"Sobre la app USMWifi";
    
    NSString *urlString = [NSString stringWithFormat:@"mailto:jose.canepa@alumnos.usm.cl,camilo.verab@alumnos.usm.cl?subject=%@&body=%@",[title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:url];
}

@end

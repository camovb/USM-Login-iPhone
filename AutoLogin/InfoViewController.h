//
//  InfoViewController.h
//  AutoLogin
//
//  Created by Camilo Vera on 8/11/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

@property (nonatomic,retain) IBOutlet UIButton *buttonURL;
@property (nonatomic,retain) IBOutlet UIButton *buttonEmailCan;
@property (nonatomic,retain) IBOutlet UIButton *buttonEmailCamo;

- (IBAction)infoButtonDidPress:(id)sender;
- (IBAction)URLButtonDidPress:(id)sender;
- (IBAction)mailButtonDidPress:(id)sender;

@end


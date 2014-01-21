//
//  WelcomeViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 9/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectWalkViewController.h"
#import "CreateWalkViewController.h"
#import "TownCreateViewController.h"
#import "TownWalkViewController.h"

@interface WelcomeViewController : UIViewController <UIAlertViewDelegate>
@property (nonatomic, retain) NSString *username;
@property BOOL hasPriveleges;
-(IBAction)logoutChosen:(id)sender;
-(IBAction)walkChosen:(id)sender;
@end

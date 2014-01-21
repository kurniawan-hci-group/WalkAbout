//
//  LoginViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 9/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeViewController.h"

@interface LoginViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
-(IBAction)loginPressed;
-(IBAction)logoutPressed:(id)sender;
@end

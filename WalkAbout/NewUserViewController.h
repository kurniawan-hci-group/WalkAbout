//
//  NewUserViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 9/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewUserViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *authenticationField;
-(IBAction)joinPressed;
@end

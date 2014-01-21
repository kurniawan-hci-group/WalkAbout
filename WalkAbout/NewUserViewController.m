//
//  NewUserViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "NewUserViewController.h"

@interface NewUserViewController ()

@end

@implementation NewUserViewController
@synthesize usernameField;
@synthesize passwordField;
@synthesize emailField;
@synthesize authenticationField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    passwordField.secureTextEntry = YES;
    authenticationField.secureTextEntry = YES;
}

-(IBAction)joinPressed
{
    //load the current plist. Add a dictionary item with all the user's info, then save that dictionary into the docs directory
    //We need to load up a plist of users and their passwords
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString *usersPlist = [[NSMutableString alloc] initWithString:documentsDirectory];
    [usersPlist appendString:@"/usersPlist.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *usersArray;
    
    if ([fileManager fileExistsAtPath: usersPlist])
    {
        usersArray = [[NSMutableArray alloc] initWithContentsOfFile:usersPlist];
    }
    else
    {
        usersArray = [NSMutableArray new];
    }
    
    //create the new dictionary
    NSDictionary *newUser;
    if ([authenticationField.text isEqualToString:@"karuk2013"])
    {
        newUser = [[NSDictionary alloc] initWithObjectsAndKeys:usernameField.text, @"Username", passwordField.text, @"Password", emailField.text, @"Email", [NSNumber numberWithBool:TRUE], @"Native", nil];
    }
    else
    {
        newUser = [[NSDictionary alloc] initWithObjectsAndKeys:usernameField.text, @"Username", passwordField.text, @"Password", emailField.text, @"Email", [NSNumber numberWithBool:FALSE], @"Native", nil];
    }
    [usersArray addObject:newUser];
    [usersArray writeToFile:usersPlist atomically:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [emailField resignFirstResponder];
    [authenticationField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

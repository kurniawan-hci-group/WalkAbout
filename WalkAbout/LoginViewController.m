//
//  LoginViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
{
    NSString *documentsDirectory;
    NSMutableArray *usersArray;
    NSString *username;
    NSString *password;
    BOOL hasPriveleges;
}
@end

@implementation LoginViewController
@synthesize usernameField;
@synthesize passwordField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    passwordField.secureTextEntry = YES;
    [usernameField becomeFirstResponder];
    hasPriveleges = false;
    self.navigationController.navigationBar.translucent = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    usernameField.text = @"";
    passwordField.text = @"";
    
    //We need to load up a plist of users and their passwords
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSMutableString *usersPlist = [[NSMutableString alloc] initWithString:documentsDirectory];
    [usersPlist appendString:@"/usersPlist.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: usersPlist])
    {
        usersArray = [[NSMutableArray alloc] initWithContentsOfFile:usersPlist];
    }
    else
    {
        usersArray = [NSMutableArray new];
    }
    
    //now check to see if username is in this plist
}

-(IBAction)logoutPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Logout?" message:@"Are you sure you want to logout?" delegate:self
                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //The OK button is at buttonIndex = 1.
    if (buttonIndex == 0)
    {
        //cancel button
    }
    
    if (buttonIndex == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)loginPressed
{
    username = usernameField.text;
    password = passwordField.text;
    BOOL isUser = false;
    //here we check if the username is in the plist
    for (int i = 0; i < [usersArray count]; i++)
    {
        if ([[[usersArray objectAtIndex:i] objectForKey:@"Username"] isEqualToString:username] && [[[usersArray objectAtIndex:i] objectForKey:@"Password"] isEqualToString:password])
        {
            isUser = true;
            hasPriveleges = [[[usersArray objectAtIndex:i] objectForKey:@"Native"] boolValue];
        }
    }
    
    if (isUser)
    {
        //perform segue to walkAbout
        [self performSegueWithIdentifier:@"loginSuccess" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"loginError" sender:self];
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"loginSuccess"])
    {
        WelcomeViewController *welcome = [segue destinationViewController];
        [welcome setUsername:username];
        [welcome setHasPriveleges:hasPriveleges];
    }
    
    /*else if ([[segue identifier] isEqualToString:@"loginError"])
    {
        
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

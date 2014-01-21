//
//  WelcomeViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController
@synthesize username;
@synthesize hasPriveleges;
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
    
    //self.navigationController.title = [NSString stringWithFormat:@"Welcome %@", username];
    self.navigationItem.title = [NSString stringWithFormat:@"Welcome %@", username];
    if (!hasPriveleges) {
        
    }
}

-(IBAction)logoutChosen:(id)sender
{
    //display uialertview
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Logout?" message:@"Are you sure you want to logout?" delegate:self
                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

-(IBAction)walkChosen:(id)sender
{
    if (hasPriveleges)
    {
        //perform the segue
        [self performSegueWithIdentifier:@"createWalk" sender:self];
    }
    else
    {
        //display a UIAlertView saying the user does not have priveleges to creat walks
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Don't have priveleges" message:@"Sorry but you don't have privleges to create a walk. You may go on others' walks instead." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goOnWalk"])
    {
        TownWalkViewController *walkAbout = [segue destinationViewController];
        [walkAbout setUserName:username];
    }
    else if ([[segue identifier] isEqualToString:@"createWalk"])
    {
        TownCreateViewController *createWalk = [segue destinationViewController];
        [createWalk setUserName:username];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

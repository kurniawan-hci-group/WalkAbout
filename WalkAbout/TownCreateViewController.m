//
//  TownCreateViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/24/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "TownCreateViewController.h"

@interface TownCreateViewController ()

@end

@implementation TownCreateViewController
@synthesize userName;
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
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"createWalk"])
    {
        CreateWalkViewController *create = [segue destinationViewController];
        [create setUserName:userName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

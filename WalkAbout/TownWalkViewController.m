//
//  TownWalkViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/24/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "TownWalkViewController.h"

@interface TownWalkViewController ()

@end

@implementation TownWalkViewController
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
    if ([[segue identifier] isEqualToString:@"goOnWalk"])
    {
        SelectWalkViewController *walk = [segue destinationViewController];
        [walk setUsername:userName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

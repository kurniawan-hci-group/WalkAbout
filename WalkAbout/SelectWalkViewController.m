//
//  SelectWalkViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 8/14/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "SelectWalkViewController.h"

@interface SelectWalkViewController ()
{
    NSString *uniqueID;
    NSArray *plistArray;
}
@end

@implementation SelectWalkViewController
@synthesize username;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[self.tableView setDelegate:self];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Lets add a background to this uiview
    
    
    //Here we need to initilaize the array based on the walk names from the plist
    
    //Go ahead and initialize our walkArray
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"walkList.plist"];
    
    if ([fileManager fileExistsAtPath:path])
    {
        plistArray = [[NSArray alloc] initWithContentsOfFile:path];
    }
    else
    {
        plistArray = [NSArray new];
    }

    _walkArray = [NSMutableArray new];
    _detailArray = [NSMutableArray new];
    _difficultyArray = [NSMutableArray new];
    _userArray = [NSMutableArray new];
    _directionsArray = [NSMutableArray new];
    
    for (int i = 0; i<[plistArray count]; i++)
    {
        [_walkArray insertObject:[[plistArray objectAtIndex:i] objectForKey:@"walkName"] atIndex:i];
        [_detailArray insertObject:[[plistArray objectAtIndex:i] objectForKey:@"description"] atIndex:i];
        [_difficultyArray insertObject:[[plistArray objectAtIndex:i] objectForKey:@"difficulty"] atIndex:i];
        [_userArray insertObject:[[plistArray objectAtIndex:i] objectForKey:@"userName"] atIndex:i];
        [_directionsArray insertObject:[[plistArray objectAtIndex:i] objectForKey:@"directions"] atIndex:i];
    }
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GoOnWalk"])
    {
        WalkAboutViewController *walkAbout = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView
                                    indexPathForSelectedRow];
        //int row = [indexPath row];
        //[walkAbout setWalkID:[[NSNumber alloc] initWithInt:row]];
        uniqueID = [[plistArray objectAtIndex:[indexPath row]] objectForKey:@"uniqueID"];
        [walkAbout setUniqueID:uniqueID];
        [walkAbout setUserName:username];
        [walkAbout setWalkUserName:_userArray[[indexPath row]]];
        [walkAbout setDirections:_directionsArray[[indexPath row]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _walkArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"walkTableCell";
    SelectWalkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    int row = [indexPath row];
    cell.textLabel.text = _walkArray[row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@. %@. %@", _detailArray[row], _difficultyArray[row], _userArray[row]];
    //cell.walkLabel.text = _walkArray[row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
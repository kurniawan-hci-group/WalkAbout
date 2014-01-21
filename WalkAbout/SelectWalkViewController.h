//
//  SelectWalkViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 8/14/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectWalkCell.h"
#import "WalkAboutViewController.h"

@interface SelectWalkViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *walkArray;
@property (nonatomic, retain) NSMutableArray *detailArray;
@property (nonatomic, retain) NSMutableArray *difficultyArray;
@property (nonatomic, retain) NSMutableArray *userArray;
@property (nonatomic, retain) NSMutableArray *directionsArray;
@property (nonatomic, retain) NSString *username;
@end

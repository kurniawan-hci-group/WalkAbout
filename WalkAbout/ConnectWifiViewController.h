//
//  ConnectWifiViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 8/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ConnectWifiViewController : UIViewController
{
    Reachability *internetReachableFoo;
}
@property (nonatomic, retain) IBOutlet UILabel *connectLabel;
-(BOOL)testInternetConnection;
@end

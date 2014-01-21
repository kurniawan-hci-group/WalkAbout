//
//  WalkAboutViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 6/14/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "Clue.h"
#import "ClueViewController.h"
#import "CreateClueViewController.h"

@interface WalkAboutViewController : UIViewController <UIScrollViewDelegate, UIAccelerometerDelegate,CLLocationManagerDelegate, UIAlertViewDelegate>
{
    IBOutlet UIScrollView *scrollView;
    //UIButton *createClueButton;
    UIImageView *imageView;
    double px;
    double py;
    double pz;
    
    int numSteps;
    int accuracyCounter;
    int dummyIndex;
    int passingID;
    BOOL isChange;
    CMMotionManager *motionManager;
    CLLocationManager *locationManager;
    
    //Need to find out better what variables these are
    double oldRad;
	double newRad;
    double xx;
    double yy;
    double zz;
    
    double dot;
    double a;
    double b;
    
    //variables for current location
    double currLatitude;//Latitude is Y value
    double currLongitude;//Longitude is X value
    
    //double path_x_coords[573];
    //double path_y_coords[573];
    //double distance[573];
    double path_x_coords[341];
    double path_y_coords[341];
    double distance[341];
    
    Clue *dolphin;
    Clue *lady_bug;
    Clue *pine_tree;
    
    IBOutlet UIButton *directionsButton;
    UIView *directionsView;
}
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *barButton;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *foreImage;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *walkUserName;
@property (nonatomic, retain) NSString *directions;
-(IBAction)startWalk:(id)sender;
-(IBAction)endWalk:(id)sender;
-(IBAction)createClue:(id)sender;
@end
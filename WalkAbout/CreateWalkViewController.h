//
//  CreateWalkViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 7/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Clue.h"
#import "CreateClueViewController.h"

@interface CreateWalkViewController : UIViewController <UIScrollViewDelegate, UIAccelerometerDelegate,CLLocationManagerDelegate, UIAlertViewDelegate, UIPickerViewDelegate>
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
    int pickerIndex;
    BOOL isChange;
    BOOL isSleeping;
    BOOL saveWalk;
    BOOL showNameAlert;
    BOOL viewIsShowing;
    BOOL descriptionAlert;
    BOOL walkStarted;
    //BOOL didPush;
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
    
    double path_x_coords[341];
    double path_y_coords[341];
    double distance[341];
    
    NSMutableArray *clueArray;
    NSMutableArray *walkArray;
    NSNumber *walkID;
    
    NSString *uniqueKey;
    
    UILabel *difficultyLabel;
    UILabel *descriptionLabel;
    UITextView *descriptionTextView;
    UIPickerView *difficultyPickerView;
    UILabel *walkingLabel;
    UIButton *startButton;
    UIButton *directionsButton;
    UITextView *textField;
    NSMutableString *directions;
    UIView *directionsView;
}
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
//@property (nonatomic, retain) UIButton *createClueButton;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *foreImage;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *walkName;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *startBarButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *directionsBarButton;
-(IBAction)createClue:(id)sender;
@end
//
//  EnterQuestionViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 9/25/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface EnterQuestionViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextField *questionTextField;
@property (nonatomic, retain) IBOutlet UITextField *aAnswerTextField;
@property (nonatomic, retain) IBOutlet UITextField *bAnswerTextField;
@property (nonatomic, retain) IBOutlet UITextField *cAnswerTextField;
@property (nonatomic, retain) IBOutlet UITextField *dAnswerTextField;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSNumber *clueID;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSString *clueTitle;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *pointValue;
@property (nonatomic, retain) NSString *description;
@property bool isClueQuestion;
@property BOOL isNewClue;
-(IBAction)saveButtonPressed;
@end

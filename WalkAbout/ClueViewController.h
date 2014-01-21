//
//  ClueViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 7/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "CreateClueViewController.h"
#import "EditClueViewController.h"
#import "AnswerClueViewController.h"

@interface ClueViewController : UIViewController <AVAudioPlayerDelegate, UIAlertViewDelegate>
{
    NSString *clueTitle;
    NSString *descriptionString;
    NSString *audioFile;
    UILabel *clueLabel;
    UILabel *description;
    UIImage *image;
    UIImageView *imageView;
    UIButton *button;
    AVAudioPlayer *audioPlayer;
    //AVAudioPlayer *answerAudioPlayer;
    //AVAudioRecorder *audioRecorder;
    BOOL isQuestionAnswered;
}
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *clueID;
@property (nonatomic, retain) NSNumber *isQuestion;
@property (nonatomic, retain) NSString *clueTitle;
@property (nonatomic, retain) NSString *descriptionString;
@property (nonatomic, retain) NSString *audioFile;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@property (nonatomic, retain) IBOutlet UILabel *description;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *button;
//@property (nonatomic, retain) IBOutlet UIButton *recordAnswerButton;
@property (nonatomic, retain) IBOutlet UIButton *answerButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *barButton;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSString *userUserName;
@property (nonatomic, retain) NSString *walkUserName;
-(IBAction)doneButton:(id)sender;
-(IBAction)playButton:(id)sender;
-(IBAction)editClue:(id)sender;
-(IBAction)recordAnswer;
@end
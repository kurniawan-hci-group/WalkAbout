//
//  CreateClueViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 7/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "EnterQuestionViewController.h"


@interface CreateClueViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate, UIAlertViewDelegate>
{
    UIButton *takePictureButton;
    UIButton *recordSoundButton;
    UIButton *playButton;
    UIButton *doneButton;
    UIButton *stopButton;
    UITextField *textField;
    //UIImageView *imageView;
    //BOOL newMedia;
}
@property BOOL newMedia;
@property BOOL isNewClue;
@property double longitude;
@property double latitude;
@property (nonatomic, retain) UITextField IBOutlet *textField;
@property (nonatomic, retain) UITextField IBOutlet *descriptionField;
@property (nonatomic, retain) UITextField IBOutlet *pointValueField;
@property (nonatomic, retain) UIButton IBOutlet *takePictureButton;
@property (nonatomic, retain) UIButton IBOutlet *recordSoundButton;
@property (nonatomic, retain) UIButton IBOutlet *doneButton;
@property (nonatomic, retain) UIButton IBOutlet *playButton;
@property (nonatomic, retain) UIButton IBOutlet *stopButton;
@property (nonatomic, retain) UIButton IBOutlet *isQuestionButton;
@property (nonatomic, retain) UILabel IBOutlet *recordTime;
@property (nonatomic, retain) UILabel IBOutlet *recordingLabel;
@property (nonatomic, retain) UILabel IBOutlet *playingLabel;
@property (nonatomic, retain) UIImageView IBOutlet *imageView;
@property (nonatomic, retain) NSNumber *walkID;
@property (nonatomic, retain) NSNumber *clueID;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSString *userName;
-(IBAction)donePressed:(id)sender;
-(IBAction)takePicture:(id)sender;
-(IBAction)recordAudio:(id)sender;
-(IBAction)playAudio:(id)sender;
-(IBAction)stopAudio:(id)sender;
-(IBAction)isQuestionPressed;
@end
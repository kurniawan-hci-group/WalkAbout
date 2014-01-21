//
//  EditClueViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 9/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface EditClueViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextField *descriptionField;
@property (nonatomic, retain) IBOutlet UIButton *takePictureButton;
@property (nonatomic, retain) IBOutlet UIButton *recordSoundButton;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *isQuestionButton;
@property (nonatomic, retain) IBOutlet UILabel *recordTime;
@property (nonatomic, retain) IBOutlet UILabel *recordingLabel;
@property (nonatomic, retain) IBOutlet UILabel *playingLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
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
-(IBAction)deletePressed;
@end

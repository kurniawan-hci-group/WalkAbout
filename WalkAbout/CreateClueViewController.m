//
//  CreateClueViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 7/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "CreateClueViewController.h"

@interface CreateClueViewController ()
{
    NSMutableArray *data;
    //NSNumber *clueID;
    UIImage *clueImage;
    BOOL isClueQuestion;
    int secondsElapsed;
    NSTimer *timer;
    NSNumber *pointValue;
    AVAudioSession *audioSession;
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
}
@end

@implementation CreateClueViewController
@synthesize longitude;
@synthesize latitude;
@synthesize takePictureButton;
@synthesize recordSoundButton;
@synthesize doneButton;
@synthesize isQuestionButton;
@synthesize textField;
@synthesize descriptionField;
@synthesize playButton;
@synthesize stopButton;
@synthesize clueID;
@synthesize walkID;
@synthesize uniqueID;
@synthesize recordTime;
@synthesize recordingLabel;
@synthesize userName;
@synthesize playingLabel;
@synthesize pointValueField;
@synthesize isNewClue;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];

    playButton.enabled = NO;
    stopButton.enabled = NO;
    isClueQuestion = NO;
    recordingLabel.hidden = TRUE;
    playingLabel.hidden = TRUE;
    //We need to load up the plist here, because we will need to know what the current clueID is so we can save the files appropriately when the time comes for it
    
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"walkList.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: path])
    {
        data = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    else
    {
        data = [NSMutableArray new];
    }
    */
    //clueID = [[NSNumber alloc] initWithInt:[data count]];
    
    //check to see if there is a sound directory before we create the sound
    
    //secondsElapsed = 0;
    //recordTime.text = [NSString stringWithFormat:@"%d", secondsElapsed];
    
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    
    
    NSMutableString *testSoundFilePath = [[NSMutableString alloc] initWithString:docsDir];
    [testSoundFilePath appendString:@"/sound/"];
    
        NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Check that the sound directory exists; if not, create it
    BOOL isSoundDir;
    BOOL soundExists = [fileManager fileExistsAtPath:testSoundFilePath isDirectory:&isSoundDir];
    if (!(soundExists && isSoundDir))
    {
        /* file exists */
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:testSoundFilePath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
    
    //we won't be using the walkID anymore, what we will use now is the uniqueID
    
    [testSoundFilePath appendString:uniqueID];
    [testSoundFilePath appendString:@"-"];
    [testSoundFilePath appendString:[NSString stringWithFormat:@"%06d", [clueID integerValue]]];
    [testSoundFilePath appendString:@"sound.caf"];

    NSURL *soundFileURL = [NSURL fileURLWithPath:testSoundFilePath];
    //NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey, [NSNumber numberWithInt:16], AVEncoderBitRateKey, [NSNumber numberWithInt:2], AVNumberOfChannelsKey, [NSNumber numberWithFloat:44100.0], AVSampleRateKey, nil];
    NSDictionary *recordSettings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
      AVEncoderAudioQualityKey: @(AVAudioQualityLow),
      AVNumberOfChannelsKey: @1,
      AVSampleRateKey: @22050.0f};
    NSError *error = nil;
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    
    if(error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    else
    {
        [audioRecorder prepareToRecord];
    }
    /*
    CGRect frameRect = pointValueField.frame;
    frameRect.size.height = 49;
    pointValueField.frame = frameRect;*/
}

- (bool)stringIsNumeric:(NSString *)str
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    return !!number; // If the string is not numeric, number will be nil
}

-(IBAction)donePressed:(id)sender
{
    bool isNumber = [self stringIsNumeric:pointValueField.text];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    NSNumber *number = [formatter numberFromString:pointValueField.text];
    if (!isNumber && !(([number integerValue] <= 100) && ([number integerValue] >= 1)))
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not a number" message:@"Please enter a point value between 1 and 100" delegate:nil
                              cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        //Set up the image path to be saved in the images directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSMutableString *imagePath = [[NSMutableString alloc] initWithString:documentsDirectory];
        [imagePath appendString:@"/images/"];
        [imagePath appendString:uniqueID];
        [imagePath appendString:@"-"];
        [imagePath appendString:[NSString stringWithFormat:@"%06d", [clueID integerValue]]];
        [imagePath appendString:@"image.jpg"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        
        //check that the images directory exists; if it doesn't, create it (this will only happen the first time the app is used
        NSMutableString *imageDir = [[NSMutableString alloc] initWithString:documentsDirectory];
        [imageDir appendString:@"/images/"];
        BOOL isImageDir;
        BOOL imageExists = [fileManager fileExistsAtPath:imageDir isDirectory:&isImageDir];
        if (!(imageExists && isImageDir))
        {
            /* file exists */
            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:imageDir
                                           withIntermediateDirectories:NO
                                                            attributes:nil
                                                                 error:&error])
            {
                NSLog(@"Create directory error: %@", error);
            }
        }
        
        //save the image to the documents directory
        NSData *jpgImage = UIImageJPEGRepresentation(clueImage, .05);
        [jpgImage writeToFile:imagePath atomically:YES];
        
        if (!isClueQuestion)
        {
            //Create the new entry for the clue plist
            NSMutableDictionary *clueDictionary = [NSMutableDictionary dictionary];
            NSNumber *clueLat = [[NSNumber alloc] initWithDouble:latitude];
            NSNumber *clueLong = [[NSNumber alloc] initWithDouble:longitude];
            [clueDictionary setValue:clueID forKey:@"ClueID"];
            [clueDictionary setValue:textField.text forKey:@"ClueTitle"];
            [clueDictionary setValue:clueLat forKey:@"ClueLat"];
            [clueDictionary setValue:clueLong forKey:@"ClueLong"];
            [clueDictionary setValue:descriptionField.text forKey:@"Description"];
            [clueDictionary setValue:[NSNumber numberWithBool:isClueQuestion] forKey:@"QuestionAnswer"];
            [clueDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"IsAnswered"];
            [clueDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"IsDeleted"];
            
            //Check that the plists directory exists; if it doesn't, create it
            NSMutableString *path = [[NSMutableString alloc] initWithString:documentsDirectory];
            [path appendString:@"/plists/"];
            BOOL isDir;
            BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDir];
            if (!(exists && isDir))
            {
                /* file exists */
                NSError *error;
                if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                               withIntermediateDirectories:NO
                                                                attributes:nil
                                                                     error:&error])
                {
                    NSLog(@"Create directory error: %@", error);
                }
            }

            [path appendString:uniqueID];
            [path appendString:@".plist"];
            
            //initialize the array with the clue plist
            NSMutableArray *clueArray = [NSMutableArray new];
            
            if ([fileManager fileExistsAtPath:path])
            {
                clueArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
            }
            else
            {
                clueArray = [NSMutableArray new];
            }
            
            [clueArray addObject:clueDictionary];
            [clueArray writeToFile:path atomically:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if (isClueQuestion)
        {
            [self performSegueWithIdentifier:@"isQuestion" sender:self];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"isQuestion"])
    {
        EnterQuestionViewController *question = [segue destinationViewController];
        [question setUniqueID:uniqueID];
        [question setClueID:clueID];
        [question setLatitude:[NSNumber numberWithDouble:latitude]];
        [question setLongitude:[NSNumber numberWithDouble:longitude]];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *number = [formatter numberFromString:pointValueField.text];
        [question setPointValue:number];
        [question setIsNewClue:isNewClue];
        [question setIsClueQuestion:isClueQuestion];
    }
}

-(IBAction)takePicture:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = YES;
    }
}

-(IBAction)recordAudio:(id)sender
{
    if(!audioRecorder.recording)
    {
        playButton.enabled = NO;
        stopButton.enabled = YES;
        [audioRecorder record];
    }
    //start a timer here that we will display as a label
    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    secondsElapsed = 0;
    recordingLabel.hidden = FALSE;
}

-(void)updateCountdown
{
    int seconds;
    secondsElapsed++;
    seconds = (secondsElapsed % 3600) % 60;
    recordTime.text = [NSString stringWithFormat:@"%02d", seconds];
    //secondsLeft--;
    //hours = secondsLeft / 3600;
    //minutes = (secondsLeft % 3600) / 60;
    //seconds = (secondsLeft %3600) % 60;
    //countDownlabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

-(IBAction)playAudio:(id)sender
{
    if(!audioRecorder.recording)
    {
        //The recorded audio is played here
        stopButton.enabled = YES;
        recordSoundButton.enabled = NO;
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:&error];
        NSLog(@"The audio URL: %@", audioRecorder.url);
        audioPlayer.delegate = self;
        if(error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
        else
        {
            [audioPlayer play];
        }
    }
    playingLabel.hidden = FALSE;
}

-(IBAction)stopAudio:(id)sender
{
    stopButton.enabled = NO;
    playButton.enabled = YES;
    recordSoundButton.enabled = YES;
    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
        recordingLabel.hidden = TRUE;
    }
    else if (audioPlayer.playing)
    {
        [audioPlayer stop];
    }
    
    //we need to stop the timer
    [timer invalidate];
}

-(IBAction)isQuestionPressed
{
    if (isClueQuestion)
    {
        isClueQuestion = NO;
        [isQuestionButton setTitle:@"No" forState:UIControlStateNormal];
    }
    else
    {
        isClueQuestion = YES;
        [isQuestionButton setTitle:@"Yes" forState:UIControlStateNormal];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    recordSoundButton.enabled = YES;
    stopButton.enabled = NO;
    playingLabel.hidden = TRUE;
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode error occurred");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encoding error did occur");
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        clueImage = info[UIImagePickerControllerOriginalImage];
        
        _imageView.image = clueImage;
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [textField resignFirstResponder];
    [descriptionField resignFirstResponder];
    [pointValueField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

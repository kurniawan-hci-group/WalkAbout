//
//  EditClueViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "EditClueViewController.h"

@interface EditClueViewController ()
{
    NSMutableArray *data;
    //NSNumber *clueID;
    UIImage *clueImage;
    BOOL isQuestion;
    BOOL newAudio;
    BOOL newPhoto;
    int secondsElapsed;
    NSTimer *timer;
    AVAudioSession *audioSession;
}
@end

@implementation EditClueViewController
@synthesize titleField;
@synthesize descriptionField;
@synthesize takePictureButton;
@synthesize recordSoundButton;
@synthesize doneButton;
@synthesize isQuestionButton;
@synthesize playButton;
@synthesize stopButton;
@synthesize recordTime;
@synthesize recordingLabel;
@synthesize playingLabel;
@synthesize walkID;
@synthesize uniqueID;
@synthesize userName;
@synthesize clueID;
@synthesize imageView;
@synthesize image;
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
    isQuestion = NO;
    recordingLabel.hidden = TRUE;
    playingLabel.hidden = TRUE;
    newAudio = FALSE;
    newPhoto = FALSE;
    
    //we need to at least initialize the title and description text to what's in the plist
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSMutableString *path = [[NSMutableString alloc] initWithString:docsDir];
    [path appendString:@"/plists/"];
    [path appendString:uniqueID];
    [path appendString:@".plist"];
    NSMutableArray *clueArray = [NSMutableArray new];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path])
    {
        clueArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    else
    {
        clueArray = [NSMutableArray new];
    }
    titleField.text = [clueArray[[clueID integerValue]] objectForKey:@"ClueTitle"];
    descriptionField.text = [clueArray[[clueID integerValue]] objectForKey:@"Description"];
    
    //we also need to initialize the uiimage to the right image
    NSString *imagePath = [NSString stringWithFormat:@"%@/images/%@-%@image.jpg", docsDir, uniqueID, [NSString stringWithFormat:@"%06d", [clueID integerValue]]];
    imageView.image = [UIImage imageWithContentsOfFile:imagePath];
}

-(IBAction)donePressed:(id)sender
{
    //we need to edit the plist back into the documents directory
    //first load up the walk's plist
    //Check that the plists directory exists; if it doesn't, create it
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSMutableString *path = [[NSMutableString alloc] initWithString:docsDir];
    [path appendString:@"/plists/"];
    [path appendString:uniqueID];
    [path appendString:@".plist"];
    NSMutableArray *clueArray = [NSMutableArray new];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path])
    {
        clueArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    else
    {
        clueArray = [NSMutableArray new];
    }
    
    //now we edit the entry
    [clueArray[[clueID integerValue]] setObject:titleField.text forKey:@"ClueTitle"];
    [clueArray[[clueID integerValue]] setObject:descriptionField.text forKey:@"Description"];
    //finally edit the IsAnswered and QuestionAnswer keys. IsAnswered will automatically be no, but QuestionAnswer will be the isQuestion bool
    [clueArray[[clueID integerValue]] setObject:[NSNumber numberWithBool:isQuestion] forKey:@"QuestionAnswer"];
    
    //if there is a new photo, save it to the directory. The audio is automatically saved
    if (newPhoto)
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
        
        NSData *jpgImage = UIImageJPEGRepresentation(clueImage, .05);
        [jpgImage writeToFile:imagePath atomically:YES];
    }

    
    //save the plist back into the documents/plists directory
    [clueArray writeToFile:path atomically:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
    }
}

-(IBAction)recordAudio:(id)sender
{
    newAudio = TRUE;
    //prepare the audio recorder to start recording. This should actually go in the place where the record button is...that way the audio file won't get automatically overwritten
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
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey, [NSNumber numberWithInt:16], AVEncoderBitRateKey, [NSNumber numberWithInt:2], AVNumberOfChannelsKey, [NSNumber numberWithFloat:44100.0], AVSampleRateKey, nil];
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    
    if(error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    else
    {
        [_audioRecorder prepareToRecord];
    }
    
    if(!_audioRecorder.recording)
    {
        playButton.enabled = NO;
        stopButton.enabled = YES;
        [_audioRecorder record];
    }
    //start a timer here that we will display as a label
    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    secondsElapsed = 0;
    recordingLabel.hidden = FALSE;
}

-(IBAction)playAudio:(id)sender
{
    if(!_audioRecorder.recording)
    {
        //The recorded audio is played here
        stopButton.enabled = YES;
        recordSoundButton.enabled = NO;
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_audioRecorder.url error:&error];
        NSLog(@"The audio URL: %@", _audioRecorder.url);
        _audioPlayer.delegate = self;
        if(error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
        else
        {
            [_audioPlayer play];
        }
    }
    playingLabel.hidden = FALSE;
}

-(IBAction)stopAudio:(id)sender
{
    stopButton.enabled = NO;
    playButton.enabled = YES;
    recordSoundButton.enabled = YES;
    
    if (_audioRecorder.recording)
    {
        [_audioRecorder stop];
        recordingLabel.hidden = TRUE;
    }
    else if (_audioPlayer.playing)
    {
        [_audioPlayer stop];
    }
    
    //we need to stop the timer
    [timer invalidate];
}

-(IBAction)isQuestionPressed
{
    if (isQuestion)
    {
        isQuestion = NO;
        [isQuestionButton setTitle:@"No" forState:UIControlStateNormal];
    }
    else
    {
        isQuestion = YES;
        [isQuestionButton setTitle:@"Yes" forState:UIControlStateNormal];
    }
}

-(IBAction)deletePressed
{
    //we need to display a UIAlertView asking if they really want to delete. If so, then delete that clue entry.
    //First we display a UIAlertView
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Delete?" message:@"Are you sure you want to delete this clue?" delegate:self
                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //The OK button is at buttonIndex = 1.
    if (buttonIndex == 0)
    {
        //cancel button
    }
    
    if (buttonIndex == 1)
    {
        //here we need to completely delete the clue entry
        //[self.navigationController popViewControllerAnimated:YES];
        
        //first load up the walk's plist, delete the clue's dictionary, then save it back into the docs directory
        NSMutableArray *clueArray;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSMutableString *cluePlistPath = [[NSMutableString alloc] initWithString:documentsDirectory];
        [cluePlistPath appendString:@"/plists/"];
        [cluePlistPath appendString:uniqueID];
        [cluePlistPath appendString:@".plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath: cluePlistPath])
        {
            clueArray = [[NSMutableArray alloc] initWithContentsOfFile:cluePlistPath];
        }
        else
        {
            clueArray = [NSMutableArray new];
        }
        
        //the problem here is that all the clueIDs after this clue being deleted will be one higher than they should be. Since these also coincide with indices within the walkArray, this is bad
        
        //locate the object in the array and delete it
        //INSTEAD OF REMOVING THE OBJECT AT THE INDEX, WE JUST NEED TO SET THE FLAG "DELETED"
        //[clueArray removeObjectAtIndex:[clueID integerValue]];
        [[clueArray objectAtIndex:[clueID integerValue]] setObject:[NSNumber numberWithBool:YES] forKey:@"IsDeleted"];
        
        [clueArray writeToFile:cluePlistPath atomically:YES];
        
        //create the filenames for the audio, image and answer
        NSMutableString *clueAudioPath = [[NSMutableString alloc] initWithString:documentsDirectory];
        [clueAudioPath appendString:@"/sound/"];
        [clueAudioPath appendString:uniqueID];
        [clueAudioPath appendString:@"-"];
        [clueAudioPath appendString:[NSString stringWithFormat:@"%06d",[clueID integerValue]]];
        [clueAudioPath appendString:@"sound.caf"];
        
        NSMutableString *clueImagePath = [[NSMutableString alloc] initWithString:documentsDirectory];
        [clueImagePath appendString:@"/images/"];
        [clueImagePath appendString:uniqueID];
        [clueImagePath appendString:@"-"];
        [clueImagePath appendString:[NSString stringWithFormat:@"%06d",[clueID integerValue]]];
        [clueImagePath appendString:@"image.jpg"];
        
        NSMutableString *clueAnswerPath = [[NSMutableString alloc] initWithString:documentsDirectory];
        [clueAnswerPath appendString:@"/answers/"];
        [clueAnswerPath appendString:uniqueID];
        [clueAnswerPath appendString:@"-"];
        [clueAnswerPath appendString:[NSString stringWithFormat:@"%06d",[clueID integerValue]]];
        [clueAnswerPath appendString:@"answer.caf"];
        
        //then delete the image, audio file, and answer file
        
        NSError *error = nil;
        
        if ([fileManager fileExistsAtPath: clueAudioPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath: clueAudioPath error:&error];
        }
        
        if ([fileManager fileExistsAtPath: clueImagePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath: clueImagePath error:&error];
        }
        
        if ([fileManager fileExistsAtPath: clueAnswerPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath: clueAnswerPath error:&error];
        }
        
        
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:3] animated:YES];
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
        
        imageView.image = clueImage;
        newPhoto = true;
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
    [titleField resignFirstResponder];
    [descriptionField resignFirstResponder];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

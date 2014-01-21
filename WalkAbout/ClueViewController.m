//
//  ClueViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 7/16/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "ClueViewController.h"

@interface ClueViewController ()
{
    AVAudioSession *audioSession;
}
@end

@implementation ClueViewController
@synthesize clueTitle;
@synthesize description;
@synthesize descriptionString;
@synthesize audioFile;
@synthesize image;
@synthesize imageView;
@synthesize button;
@synthesize latitude;
@synthesize longitude;
@synthesize clueID;
@synthesize uniqueID;
@synthesize isQuestion;
@synthesize questionLabel;
//@synthesize recordAnswerButton;
@synthesize userUserName;
@synthesize walkUserName;
@synthesize barButton;
@synthesize answerButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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
    
    
    imageView.image = image;
    [self setTitle:clueTitle];
    description.numberOfLines = 0;
    [description sizeToFit];
    description.text = descriptionString;
    
    //we need to have the default record and stop buttons disabled. if the clue is a question, then those buttons will be enabled in the below if statement
    questionLabel.hidden = YES;
    //recordAnswerButton.enabled = NO;
    //recordAnswerButton.hidden = YES;
    answerButton.hidden = YES;
    answerButton.enabled = NO;
    
    //load up the audio file path from the docs directory
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSMutableString *testSoundFilePath = [[NSMutableString alloc] initWithString:docsDir];
    [testSoundFilePath appendString:@"/sound/"];
    [testSoundFilePath appendString:audioFile];
    
    NSURL *url = [NSURL fileURLWithPath:testSoundFilePath];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    }
    else
    {
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
    }
    //with the documents directory, we can start using a database to keep track of all clue titles, images, sound files, descriptions (everything about the clue)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"Here is the documents directory: %@", documentsDirectory);
    
    //set the value of the label
    /*if ([isQuestion boolValue])
    {
        isQuestionLabel.text = @"This clue is a question";
    }*/
    
    //we need to check the plist first to make sure there is no answer already. If there is, we just need to display the play button, but if there is not, then we need to display the record button.
    
    //load up the clueplist
    NSMutableString *cluePlistPath = [[NSMutableString alloc] initWithString:documentsDirectory];
    [cluePlistPath appendString:@"/plists/"];
    [cluePlistPath appendString:uniqueID];
    [cluePlistPath appendString:@".plist"];
    NSMutableArray *cluePlist = [[NSMutableArray alloc] initWithContentsOfFile:cluePlistPath];
    
    isQuestionAnswered = [[cluePlist[[clueID integerValue]] objectForKey:@"IsAnswered"] boolValue];
    
    //the below if statement will determined whether we need to display a play button, a record button, or nothing
    if([isQuestion integerValue] == 1)
    {
        /*[isQuestionLabel setText:@"This clue is a question"];
        [isQuestionLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
        [isQuestionLabel setTextColor:[UIColor blueColor]];*/
        
        questionLabel.hidden = NO;
        //recordAnswerButton.enabled = YES;
        //recordAnswerButton.hidden = NO;
        answerButton.hidden = NO;
        answerButton.enabled = YES;
        //Since this is a question clue, there should be an audio recorder button displayed. If the user clicks that button, a uialert comes up to say "Do you really want to answer this clue?"
        
        //initialize soundFileURL
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSMutableString *soundFileURL = [[NSMutableString alloc] initWithString:documentsDirectory];
        [soundFileURL appendString:@"/answers/"];
        
        //check if this directory exists
        BOOL isImageDir;
        BOOL imageExists = [fileManager fileExistsAtPath:soundFileURL isDirectory:&isImageDir];
        if (!(imageExists && isImageDir))
        {
            /* file exists */
            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:soundFileURL
                                           withIntermediateDirectories:NO
                                                            attributes:nil
                                                                 error:&error])
            {
                NSLog(@"Create directory error: %@", error);
            }
        }
        
        //now finish appending string
        [soundFileURL appendString:uniqueID];
        [soundFileURL appendString:@"-"];
        [soundFileURL appendString:[NSString stringWithFormat:@"%06d",[clueID integerValue]]];
        [soundFileURL appendString:@"answer.caf"];
        
        //NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey, [NSNumber numberWithInt:16], AVEncoderBitRateKey, [NSNumber numberWithInt:2], AVNumberOfChannelsKey, [NSNumber numberWithFloat:44100.0], AVSampleRateKey, nil];
        NSError *error = nil;
        //NSURL *soundURL = [NSURL fileURLWithPath:soundFileURL];
        //audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundURL settings:recordSettings error:&error];
        
        if(error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
        else
        {
            //[audioRecorder prepareToRecord];
        }
    }
    else if (([isQuestion integerValue] == 1) && isQuestionAnswered)
    {
        //now we have a question with an answer already given. We need to display the play button
        //we need to change the image of the button to a play button, load up the answer's audio
        //UIImage *stopImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play2" ofType:@"png"]];
        //[recordAnswerButton setImage:stopImage forState:UIControlStateNormal];
        questionLabel.text = @"The question's answer: ";
        questionLabel.hidden = NO;
        //recordAnswerButton.enabled = YES;
        //recordAnswerButton.hidden = NO;
    }
    
    if ([userUserName isEqualToString:walkUserName])
    {
        //display a button to "edit" the clue
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editClue"])
    {
        EditClueViewController *editClue = [segue destinationViewController];
        [editClue setUserName:userUserName];
        [editClue setUniqueID:uniqueID];
        [editClue setClueID:clueID];
    }
    else if ([[segue identifier] isEqualToString:@"answerClue"])
    {
        AnswerClueViewController *answerClue = [segue destinationViewController];
        [answerClue setClueID:clueID];
        [answerClue setWalkID:uniqueID];
    }
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
        //Start recording the audio here. The clue answers should be saved in the documents/answers/ directory. we also need to change the value of the isAnswered key in the plist
        
        //first record audio
        
        //we need to check the plist first to make sure there is no answer already. If there is, we just need to display the play button, but if there is not, then we need to display the record button.
        
        
        //[audioRecorder record];
        //once we start recording, we need to change the button to the stop_button so that they can tap that button to stop recording
        //NSData *imageData = [[NSData alloc] initWithContentsOfFile:@"stop2.png"];
        
        
        //UIImage *stopImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stop2" ofType:@"png"]];
        //[recordAnswerButton setImage:stopImage forState:UIControlStateNormal];

        //now change value in plist
        //load up the clueplist
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSMutableString *cluePlistPath = [[NSMutableString alloc] initWithString:documentsDirectory];
        [cluePlistPath appendString:@"/plists/"];
        [cluePlistPath appendString:uniqueID];
        [cluePlistPath appendString:@".plist"];
        NSMutableArray *cluePlist = [[NSMutableArray alloc] initWithContentsOfFile:cluePlistPath];
        //we have the plist, now go the index of the entry indicated by the clueID and change the value of IsAnswered
        [cluePlist[[clueID integerValue]] setObject:[NSNumber numberWithBool:YES] forKey:@"IsAnswered"];
        [cluePlist writeToFile:cluePlistPath atomically:YES];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //we need to change the button back to its original name here
    [button setTitle:@"Hear Name" forState:UIControlStateNormal];
}

/*
-(IBAction)recordAnswer
{
    //if we need to record some audio, we will start the audio recorder
    if(([isQuestion integerValue] == 1))
    {
        if(!audioRecorder.recording)
        {
            //First we display a UIAlertView
            UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Are you sure?" message:@"Are you sure you want to answer this question?" delegate:self
                              cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert show];
        }
        else
        {
            //Right now we would be recording, so here we would stop recording and change the button back to record
            [audioRecorder stop];
            //change the button back to record
            UIImage *stopImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"record2" ofType:@"png"]];
            [recordAnswerButton setImage:stopImage forState:UIControlStateNormal];
        }
    }
    else if(([isQuestion integerValue] == 1) && isQuestionAnswered)
    {
        //create path to load up answer audio file
        NSArray *dirPaths;
        NSString *docsDir;
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        NSMutableString *playAnswerPath = [[NSMutableString alloc] initWithString:docsDir];
        [playAnswerPath appendString:@"/answers/"];
        [playAnswerPath appendString:uniqueID];
        [playAnswerPath appendString:@"-"];
        [playAnswerPath appendString:[NSString stringWithFormat:@"%06d",[clueID integerValue]]];
        [playAnswerPath appendString:@"answer.caf"];
        
        //initialize audio player
        NSURL *url = [NSURL fileURLWithPath:playAnswerPath];
        NSError *error;
        answerAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error)
        {
            NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
        }
        else
        {
            answerAudioPlayer.delegate = self;
            [answerAudioPlayer prepareToPlay];
            [answerAudioPlayer play];
        }
    }
    //we're not going to do an else statement because an else statement would signify this is not a question
}*/

-(IBAction)doneButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

-(IBAction)playButton:(id)sender
{
    if ((audioPlayer != nil)&&audioPlayer.playing)
    {
        [audioPlayer stop];
        [button setTitle:@"Hear Name" forState:UIControlStateNormal];
    }
    else if ((audioPlayer != nil)&&!audioPlayer.playing)
    {
        [audioPlayer play];
        [button setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
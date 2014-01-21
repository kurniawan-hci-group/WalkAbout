//
//  AnswerClueViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/26/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "AnswerClueViewController.h"

@interface AnswerClueViewController ()
{
    int selectedIndex;
    int pointsValue;
    AVAudioPlayer *audioPlayer;
    NSMutableArray *cluePlist;
    bool answeredCorrect;
    AVAudioSession *audioSession;
}
@end

@implementation AnswerClueViewController
@synthesize segmentedControl;
@synthesize questionLabel;
@synthesize aAnswerLabel;
@synthesize bAnswerLabel;
@synthesize cAnswerLabel;
@synthesize dAnswerLabel;
@synthesize imageView;
@synthesize clueID;
@synthesize walkID;
@synthesize pointsLabel;
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
    
    
    answeredCorrect = false;
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    //load up the clueplist
    NSMutableString *cluePlistPath = [[NSMutableString alloc] initWithString:docsDir];
    [cluePlistPath appendString:@"/plists/"];
    [cluePlistPath appendString:walkID];
    [cluePlistPath appendString:@".plist"];
    cluePlist = [[NSMutableArray alloc] initWithContentsOfFile:cluePlistPath];
    questionLabel.text = [[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"Question"];
    aAnswerLabel.text = [[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"AAnswer"];
    bAnswerLabel.text = [[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"BAnswer"];
    cAnswerLabel.text = [[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"CAnswer"];
    dAnswerLabel.text = [[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"DAnswer"];
    pointsValue = [[[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"PointValue"] integerValue];
    pointsLabel.text = [NSString stringWithFormat:@"%d", pointsValue];
    
    //load up the image
    NSMutableString *imagePath = [[NSMutableString alloc] initWithString:docsDir];
    [imagePath appendString:@"/images/"];
    [imagePath appendString:walkID];
    [imagePath appendString:@"-"];
    [imagePath appendString:[NSString stringWithFormat:@"%06d",[clueID integerValue]]];
    [imagePath appendString:@"image.jpg"];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imagePath]];
    UIImage *clueImage = [[UIImage alloc] initWithData:imageData];
    imageView.image = clueImage;
    
    //load up the audio file
    NSMutableString *testSoundFilePath = [[NSMutableString alloc] initWithString:docsDir];
    [testSoundFilePath appendString:@"/sound/"];
    [testSoundFilePath appendString:walkID];
    [testSoundFilePath appendString:@"-"];
    [testSoundFilePath appendString:[NSString stringWithFormat:@"%06d",[clueID integerValue]]];
    [testSoundFilePath appendString:@"sound.caf"];
    
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
}

-(IBAction)answerSelected
{
    selectedIndex = segmentedControl.selectedSegmentIndex;
    if ([[[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"CorrectAnswer"] integerValue] == 0)
    {
        if (selectedIndex == 0)
        {
            //correct answer
            NSString *alertMessage = [[NSString alloc] initWithString:[NSString stringWithFormat:@"Correct! You earned %d points. Tap OK to continue your walk.", pointsValue]];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Correct!" message:alertMessage delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            answeredCorrect = true;
        }
        else
        {
            //incorrect answer
            //First we display a UIAlertView
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Incorrect" message:@"Do you want to try again or exit question?" delegate:self
                                  cancelButtonTitle:@"Exit question" otherButtonTitles:@"Try again", nil];
            [alert show];
        }
    }
    else if ([[[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"CorrectAnswer"] integerValue] == 1)
    {
        if (selectedIndex == 1)
        {
            //correct answer
            NSString *alertMessage = [[NSString alloc] initWithString:[NSString stringWithFormat:@"Correct! You earned %d points. Tap OK to continue your walk.", pointsValue]];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Correct!" message:alertMessage delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

            [alert show];
            answeredCorrect = true;
        }
        else
        {
            //incorrect answer
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Incorrect" message:@"Do you want to try again or exit question?" delegate:self
                                  cancelButtonTitle:@"Exit question" otherButtonTitles:@"Try again", nil];
            [alert show];
        }
    }
    else if ([[[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"CorrectAnswer"] integerValue] == 2)
    {
        if (selectedIndex == 2)
        {
            //correct answer
            NSString *alertMessage = [[NSString alloc] initWithString:[NSString stringWithFormat:@"Correct! You earned %d points. Tap OK to continue your walk.", pointsValue]];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Correct!" message:alertMessage delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

            [alert show];
            answeredCorrect = true;
        }
        else
        {
            //incorrect answer
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Incorrect" message:@"Do you want to try again or exit question?" delegate:self
                                  cancelButtonTitle:@"Exit question" otherButtonTitles:@"Try again", nil];
            [alert show];
        }
    }
    else if ([[[cluePlist objectAtIndex:[clueID integerValue]] objectForKey:@"CorrectAnswer"] integerValue] == 3)
    {
        if (selectedIndex == 3)
        {
            //correct answer
            NSString *alertMessage = [[NSString alloc] initWithString:[NSString stringWithFormat:@"Correct! You earned %d points. Tap OK to continue your walk.", pointsValue]];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Correct!" message:alertMessage delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

            [alert show];
            answeredCorrect = true;
        }
        else
        {
            //incorrect answer
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Incorrect" message:@"Do you want to try again or exit question?" delegate:self
                                  cancelButtonTitle:@"Exit question" otherButtonTitles:@"Try again", nil];
            [alert show];
        }
    }
    
    if (answeredCorrect)
    {
        //HERE WE NEED TO ADD THE POINTS TO THE USER'S SCORE
    }
    
}

-(IBAction)playPressed:(id)sender
{
    if (audioPlayer.isPlaying)
        [audioPlayer stop];
    else
        [audioPlayer play];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //The OK button is at buttonIndex = 1.
    if (buttonIndex == 0)
    {
        //cancel button
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:4] animated:YES];
    }
    
    if (buttonIndex == 1)
    {

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

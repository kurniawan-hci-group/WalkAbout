//
//  EnterQuestionViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 9/25/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "EnterQuestionViewController.h"

@interface EnterQuestionViewController ()
{
    AVAudioSession *audioSession;
}
@end

@implementation EnterQuestionViewController
@synthesize questionTextField;
@synthesize aAnswerTextField;
@synthesize bAnswerTextField;
@synthesize cAnswerTextField;
@synthesize dAnswerTextField;
@synthesize clueID;
@synthesize uniqueID;
@synthesize clueTitle;
@synthesize latitude;
@synthesize longitude;
@synthesize description;
@synthesize isClueQuestion;
@synthesize pointValue;
@synthesize isNewClue;
@synthesize segmentedControl;
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
}

-(IBAction)saveButtonPressed
{
    //we need to verify there is text in the text fields. If not, display a UIAlertView
    if ((questionTextField.text.length == 0) || (aAnswerTextField.text.length == 0) || (bAnswerTextField.text.length == 0) || (cAnswerTextField.text.length == 0) || (dAnswerTextField.text.length == 0))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fill in question" message:@"Please fill in every field." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        NSMutableDictionary *clueDictionary = [NSMutableDictionary new];
        [clueDictionary setValue:clueID forKey:@"ClueID"];
        [clueDictionary setValue:clueTitle forKey:@"ClueTitle"];
        [clueDictionary setValue:latitude forKey:@"ClueLat"];
        [clueDictionary setValue:longitude forKey:@"ClueLong"];
        [clueDictionary setValue:description forKey:@"Description"];
        [clueDictionary setValue:[NSNumber numberWithBool:isClueQuestion] forKey:@"QuestionAnswer"];
        [clueDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"IsAnswered"];
        [clueDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"IsDeleted"];
        [clueDictionary setValue:questionTextField.text forKey:@"Question"];
        [clueDictionary setValue:aAnswerTextField.text forKey:@"AAnswer"];
        [clueDictionary setValue:bAnswerTextField.text forKey:@"BAnswer"];
        [clueDictionary setValue:cAnswerTextField.text forKey:@"CAnswer"];
        [clueDictionary setValue:dAnswerTextField.text forKey:@"DAnswer"];
        [clueDictionary setValue:[NSNumber numberWithInt:segmentedControl.selectedSegmentIndex] forKey:@"CorrectAnswer"];
        [clueDictionary setValue:pointValue forKey:@"PointValue"];
        [clueDictionary setValue:clueTitle forKey:@"ClueTitle"];
        [clueDictionary setValue:description forKey:@"Description"];
        
        //we're forgetting to also put the clueTitle and description into the plist
        
        
        //Check that the plists directory exists; if it doesn't, create it
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
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

        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:3] animated:YES];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [questionTextField resignFirstResponder];
    [aAnswerTextField resignFirstResponder];
    [bAnswerTextField resignFirstResponder];
    [cAnswerTextField resignFirstResponder];
    [dAnswerTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

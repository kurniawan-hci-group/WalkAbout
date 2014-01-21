//
//  AnswerClueViewController.h
//  WalkAbout
//
//  Created by Dustin Adams on 9/26/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AnswerClueViewController : UIViewController <AVAudioPlayerDelegate>
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@property (nonatomic, retain) IBOutlet UILabel *aAnswerLabel;
@property (nonatomic, retain) IBOutlet UILabel *bAnswerLabel;
@property (nonatomic, retain) IBOutlet UILabel *cAnswerLabel;
@property (nonatomic, retain) IBOutlet UILabel *dAnswerLabel;
@property (nonatomic, retain) IBOutlet UILabel *pointsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSNumber *clueID;
@property (nonatomic, retain) NSString *walkID;
-(IBAction)answerSelected;
@end

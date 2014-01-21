//
//  Clue.h
//  WalkAbout
//
//  Created by Dustin Adams on 7/17/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Clue : NSObject

@property (nonatomic, retain) NSNumber *clueID;
@property (nonatomic, retain) NSString *clueTitle;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, assign) NSNumber *isAQuestion;
@property (nonatomic, assign) bool isVisited;
@end

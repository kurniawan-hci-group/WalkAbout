//
//  ConnectWifiViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 8/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "ConnectWifiViewController.h"

@interface ConnectWifiViewController ()
{
    bool isConnected;
    NSMutableArray *downloadArray;
    NSMutableArray *uploadArray;
    NSMutableArray *serverArray;
    NSMutableArray *iphoneArray;
    
    NSMutableArray *userDownloadArray;
    NSMutableArray *userUploadArray;
    NSMutableArray *userServerArray;
    NSMutableArray *userIphoneArray;
}
@end

@implementation ConnectWifiViewController
@synthesize connectLabel;
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
    isConnected = false;
    downloadArray = [NSMutableArray new];
    uploadArray = [NSMutableArray new];
    
    userDownloadArray = [NSMutableArray new];
    userUploadArray = [NSMutableArray new];
    
    isConnected = [self testInternetConnection];
    
    if (isConnected)
    {
        
        connectLabel.text = @"Loading in progress. Do not disconnect wifi...";
        //we need to download a master plist from the server, check the plist we have downloaded here, add all the ones that are on there to the one we have, then upload that one back to the server
        
        //First we download the plist from the server.
        
        NSURL *theURL = [NSURL fileURLWithPath:@"http://users.soe.ucsc.edu/~dustinadams/walkAbout/walkList.plist" isDirectory:NO];
        NSURL *userURL = [NSURL fileURLWithPath:@"http://users.soe.ucsc.edu/~dustinadams/walkAbout/usersPlist.plist" isDirectory:NO];
        NSError *err;
        
        //load the walkList
        if ([theURL checkResourceIsReachableAndReturnError:&err] == NO)
        {
            //the file exists on the server
            serverArray = [[NSMutableArray alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://users.soe.ucsc.edu/~dustinadams/walkAbout/walkList.plist"]];
        }
        else
        {
            //the file does not exist on the server
            serverArray = [NSMutableArray new];
        }
        
        //load the userList
        if ([userURL checkResourceIsReachableAndReturnError:&err] == NO)
        {
            //the file exists on the server
            userServerArray = [[NSMutableArray alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://users.soe.ucsc.edu/~dustinadams/walkAbout/usersPlist.plist"]];
        }
        else
        {
            //the file does not exist on the server
            userServerArray = [NSMutableArray new];
        }
        
        //now lets get the plist from our docs directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"walkList.plist"];
        NSString *userPath = [documentsDirectory stringByAppendingPathComponent:@"usersPlist.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath: path])
        {
            iphoneArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        }
        else
        {
            iphoneArray = [NSMutableArray new];
        }
        
        //get the userPlist from our docs directory
        if ([fileManager fileExistsAtPath: userPath])
        {
            userIphoneArray = [[NSMutableArray alloc] initWithContentsOfFile:userPath];
        }
        else
        {
            userIphoneArray = [NSMutableArray new];
        }
        
        
        //===================================================================================================
        //Instead of finding the download array with this for loop below, we need to find it by using NSMutableSet. Create an NSMutableSet, find the intersection of iphoneArray and serverArray, then make a set of serverArray minus intersection. do iphoneArray minus intersection to find out which clues we need to upload to the server
        //===================================================================================================
        // Create arrays of the IDs only
        NSArray *iphoneKeys = [iphoneArray valueForKey:@"uniqueID"];
        NSArray *serverKeys = [serverArray valueForKey:@"uniqueID"];
        
        //create arrays of the IDs for the userPlist
        NSArray *userIphoneKeys = [userIphoneArray valueForKey:@"Username"];
        NSArray *userServerKeys = [userServerArray valueForKey:@"Username"];
        
        // Turn the arrays into sets and intersect the two sets
        NSMutableSet *iphoneSet = [NSMutableSet setWithArray:iphoneKeys];
        NSMutableSet *serverSet = [NSMutableSet setWithArray:serverKeys];
        [iphoneSet intersectSet:serverSet];
        NSMutableSet *downloadSet = serverSet;
        [downloadSet minusSet:iphoneSet];
        NSArray *downloadSetArray = [downloadSet allObjects];
        
        //Turn the arrays into sets and intersect the two sets for the userPlist
        NSMutableSet *userIphoneSet = [NSMutableSet setWithArray:userIphoneKeys];
        NSMutableSet *userServerSet = [NSMutableSet setWithArray:userServerKeys];
        [userIphoneSet intersectSet:userServerSet];
        NSMutableSet *userDownloadSet = userServerSet;
        [userDownloadSet minusSet:userIphoneSet];
        NSArray *userDownloadSetArray = [userDownloadSet allObjects];
        
        //for the walks plist
        NSMutableSet *intersectSet = [NSMutableSet setWithArray:iphoneKeys];
        NSMutableSet *serSet = [NSMutableSet setWithArray:serverKeys];
        [intersectSet intersectSet:serSet];
        NSMutableSet *uploadSet = [NSMutableSet setWithArray:iphoneKeys];
        [uploadSet minusSet:intersectSet];
        NSArray *uploadSetArray = [uploadSet allObjects];
        
        //for the userList plist
        NSMutableSet *userIntersectSet = [NSMutableSet setWithArray:userIphoneKeys];
        NSMutableSet *userSerSet = [NSMutableSet setWithArray:userServerKeys];
        [userIntersectSet intersectSet:userSerSet];
        NSMutableSet *userUploadSet = [NSMutableSet setWithArray:userIphoneKeys];
        [userUploadSet minusSet:userIntersectSet];
        NSArray *userUploadSetArray = [userUploadSet allObjects];
        
        //We need to go ahead and get the serverSet minus the intersectionSet, which will be our downloadArray. We also need the iphoneSet minus the intersectionSet. That will be our uploadArray
        //======================================
        //End get the intersection
        //======================================
        
        //put all the dictionaries of objects to be downloaded into the downloadArray for the walkList
        int serverIndex = 0;
        for (int j = 0; j < [downloadSetArray count]; j++)
        {
            for (int i = 0; i < [serverArray count]; i++)
            {
                if ([[downloadSetArray objectAtIndex:j] isEqualToString:[[serverArray objectAtIndex:i] valueForKey:@"uniqueID"]])
                {
                    [downloadArray insertObject:[serverArray objectAtIndex:i] atIndex:serverIndex];
                    serverIndex++;
                }
            }
        }
        
        //do the same as above except for the userList
        int userServerIndex = 0;
        for (int j = 0; j < [userDownloadSetArray count]; j++)
        {
            for (int i = 0; i < [userServerArray count]; i++)
            {
                if ([[userDownloadSetArray objectAtIndex:j] isEqualToString:[[userServerArray objectAtIndex:i] valueForKey:@"Username"]])
                {
                    [userDownloadArray insertObject:[userServerArray objectAtIndex:i] atIndex:userServerIndex];
                    userServerIndex++;
                }
            }
        }
        
        //put all the dictionaries of objects to be uploaded into the for the walkList
        int uploadIndex = 0;
        for (int j = 0; j < [uploadSetArray count]; j++)
        {
            for (int i = 0; i < [iphoneArray count]; i++)
            {
                if ([[uploadSetArray objectAtIndex:j] isEqualToString:[[iphoneArray objectAtIndex:i] valueForKey:@"uniqueID"]])
                {
                    [uploadArray insertObject:[iphoneArray objectAtIndex:i] atIndex:uploadIndex];
                    uploadIndex++;
                }
            }
        }
        
        //do the same for the above except for the userList
        int userUploadIndex = 0;
        for (int j = 0; j < [userUploadSetArray count]; j++)
        {
            for (int i = 0; i < [userIphoneArray count]; i++)
            {
                if ([[userUploadSetArray objectAtIndex:j] isEqualToString:[[userIphoneArray objectAtIndex:i] valueForKey:@"Username"]])
                {
                    [userUploadArray insertObject:[userIphoneArray objectAtIndex:i] atIndex:userUploadIndex];
                    userUploadIndex++;
                }
            }
        }
        
        //We need to upload everything
        
        //=====================================================
        //UPLOAD THE PLIST, AUDIO AND PHOTO FILE TO THE SERVER
        //=====================================================
        //-(NSString *)uploadFile:(NSData *)data withPath:(NSString *)urlString withFileName:(NSString *)fileName  will upload the file
        //Lets initialize the strings that we will be using as the urlString
        NSString *audioUploadString = @"http://users.soe.ucsc.edu/~dustinadams/walkAbout/audioUpload.php";
        NSString *imageUploadString = @"http://users.soe.ucsc.edu/~dustinadams/walkAbout/imageUpload.php";
        NSString *plistUploadString = @"http://users.soe.ucsc.edu/~dustinadams/walkAbout/plistUpload.php";
        
        for (int i = 0; i < [uploadArray count]; i++)
        {
            //initialize our paths for the docs directory
            NSMutableString *clueListPath = [[NSMutableString alloc] initWithString:documentsDirectory];
            [clueListPath appendString:@"/plists/"];
            
            [clueListPath appendString:[[uploadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
            [clueListPath appendString:@".plist"];
            
            NSData *plistData = [[NSData alloc] initWithContentsOfFile:clueListPath];
            NSMutableString *plistCallPath = [[NSMutableString alloc] initWithString:[[uploadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
            [plistCallPath appendString:@".plist"];
            
            NSLog(@"Result of uploading plist %@", [self uploadFile:plistData withPath:plistUploadString withFileName:plistCallPath]);
            
            //for each plist we need to upload all the image and audio files
            NSMutableArray *serverClueList = [[NSMutableArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:clueListPath]];
            for (int j = 0; j < [serverClueList count]; j++)
            {
                
                NSMutableString *imagePath = [[NSMutableString alloc] initWithString:documentsDirectory];
                [imagePath appendString:@"/images/"];
                
                NSMutableString *audioPath = [[NSMutableString alloc] initWithString:documentsDirectory];
                [audioPath appendString:@"/sound/"];
                
                [imagePath appendString:[[uploadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                [imagePath appendString:@"-"];
                [imagePath appendString:[NSString stringWithFormat:@"%06d", [[[serverClueList objectAtIndex:j] objectForKey:@"ClueID"] integerValue]]];
                [imagePath appendString:@"image"];
                [imagePath appendString:@".jpg"];
                
                [audioPath appendString:[[uploadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                [audioPath appendString:@"-"];
                [audioPath appendString:[NSString stringWithFormat:@"%06d", [[[serverClueList objectAtIndex:j] objectForKey:@"ClueID"] integerValue]]];
                [audioPath appendString:@"sound"];
                [audioPath appendString:@".caf"];
                //end initializing our paths for the docs directory
                
                
                //we need the file names that are going to be saved onto the server
                NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
                NSData *audioData = [[NSData alloc] initWithContentsOfFile:audioPath];
                
                NSMutableString *imagePathCall = [[NSMutableString alloc] initWithString:[[uploadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                [imagePathCall appendString:@"-"];
                [imagePathCall appendString:[NSString stringWithFormat:@"%06d", [[[serverClueList objectAtIndex:j] objectForKey:@"ClueID"] integerValue]]];
                [imagePathCall appendString:@"image"];
                [imagePathCall appendString:@".jpg"];
                
                
                NSMutableString *audioPathCall = [[NSMutableString alloc] initWithString:[[uploadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                [audioPathCall appendString:@"-"];
                [audioPathCall appendString:[NSString stringWithFormat:@"%06d", [[[serverClueList objectAtIndex:j] objectForKey:@"ClueID"] integerValue]]];
                [audioPathCall appendString:@"sound"];
                [audioPathCall appendString:@".caf"];
                
                
                NSLog(@"Result of uploading image file: %@", [self uploadFile:imageData withPath:imageUploadString withFileName:imagePathCall]);
                NSLog(@"Result of uploading audio file: %@", [self uploadFile:audioData withPath:audioUploadString withFileName:audioPathCall]);
            }
            
            //go ahead and upload the plist onto the server
        }
        
        //=========================================================
        //END UPLOAD THE PLIST, AUDIO AND PHOTO FILE TO THE SERVER
        //=========================================================
        
        //Now lets get all of the plists, photos and audio files from the server
        
        //Now we need to update all of our files that we need to upload to the server (plists, photos, and audio files). Since we have all the walk IDs of the walks we need to download, lets start by downloading each clue plist for each walk and putting those in the documents/plists directory. These will all be in on the server in a directory labeled plists. At the same time we're doing this, we can download the photos and audio files of each clue.
        
        //==================================================================================
        //HERE WE WILL DOWNLOAD ALL THE FILES WE DON'T HAVE ONTO THE DEVICE FROM THE SERVER
        //==================================================================================
        for (int i = 0; i < [downloadArray count]; i++)
        {
            //initialize path to download the plist off the server
            NSMutableString *plistServerString = [[NSMutableString alloc] initWithString:@"http://users.soe.ucsc.edu/~dustinadams/walkAbout/plists/"];
            [plistServerString appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
            [plistServerString appendString:@".plist"];
            //end initialize path

            
            //initialize the strings to save the plist, audio, and photo file into the docs directory
            NSMutableString *clueListPath = [[NSMutableString alloc] initWithString:documentsDirectory];
            [clueListPath appendString:@"/plists/"];
            
            NSMutableString *imagePath = [[NSMutableString alloc] initWithString:documentsDirectory];
            [imagePath appendString:@"/images/"];
            
            NSMutableString *audioPath = [[NSMutableString alloc] initWithString:documentsDirectory];
            [audioPath appendString:@"/sound/"];
            
            //first check if the /plists/ directory exists
            BOOL isDir;
            BOOL exists = [fileManager fileExistsAtPath:clueListPath isDirectory:&isDir];
            if (!(exists && isDir))
            {
                /* file exists */
                NSError *error;
                if (![[NSFileManager defaultManager] createDirectoryAtPath:clueListPath
                                               withIntermediateDirectories:NO
                                                                attributes:nil
                                                                     error:&error])
                {
                    NSLog(@"Create directory error: %@", error);
                }
            }
            //end check whether the plists directory exists
            
            //now check whether the /images/ directory exists
            BOOL isImageDir;
            BOOL imageExists = [fileManager fileExistsAtPath:imagePath isDirectory:&isImageDir];
            if (!(imageExists && isImageDir))
            {
                /* file exists */
                NSError *error;
                if (![[NSFileManager defaultManager] createDirectoryAtPath:imagePath
                                               withIntermediateDirectories:NO
                                                                attributes:nil
                                                                     error:&error])
                {
                    NSLog(@"Create directory error: %@", error);
                }
            }
            //end check if /images/ directory exists
            
            
            //check whether the /audio/ directory exists
            BOOL isPhotoDir;
            BOOL photoExists = [fileManager fileExistsAtPath:audioPath isDirectory:&isPhotoDir];
            if (!(photoExists && isPhotoDir))
            {
                /* file exists */
                NSError *error;
                if (![[NSFileManager defaultManager] createDirectoryAtPath:audioPath
                                               withIntermediateDirectories:NO
                                                                attributes:nil
                                                                     error:&error])
                {
                    NSLog(@"Create directory error: %@", error);
                }
            }
            //end check if /audio/ directory exists
            
            //append the proper postfix onto the file paths
            [clueListPath appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
            [clueListPath appendString:@".plist"];
            
            //Now that we have each walk plist, we need to go through that plist and download all the audio and photo files
            
            /*[imagePath appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
            [imagePath appendString:@"image.jpg"];
            
            [audioPath appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
            [audioPath appendString:@"sound.caf"];*/
            //end appending proper postfixes
            
            
            //Now we download the plist file from the server into our docs directory
            NSURL *plistURL = [NSURL fileURLWithPath:plistServerString isDirectory:NO];
            //NSError *err;
            if ([plistURL checkResourceIsReachableAndReturnError:&err] == NO)
            {
                //the file exists on the server
                NSMutableArray *clueArray = [[NSMutableArray alloc] initWithContentsOfURL:[NSURL URLWithString:plistServerString]];
                
                //Now that we have each walk plist, we need to go through that plist and download all the audio and photo files
                for (int j = 0; j < [clueArray count]; j++)
                {
                    NSMutableString *clueImagePath = [[NSMutableString alloc] initWithString:imagePath];
                    NSMutableString *clueAudioPath = [[NSMutableString alloc] initWithString:audioPath];
                    
                    [clueImagePath appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                    [clueImagePath appendString:@"-"];
                    
                    [clueImagePath appendString:[NSString stringWithFormat:@"%06d", [[[clueArray objectAtIndex:j] objectForKey:@"ClueID"] integerValue]]];
                    [clueImagePath appendString:@"image.jpg"];
                    
                    [clueAudioPath appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                    [clueAudioPath appendString:@"-"];
                    
                    [clueAudioPath appendString:[NSString stringWithFormat:@"%06d", [[[clueArray objectAtIndex:j] objectForKey:@"ClueID"] integerValue]]];
                    [clueAudioPath appendString:@"sound.caf"];
                    //end appending proper postfixes
                    
                    //Now we need to get the URL where they exist on the server
                    
                    
                    //initialize path to download the image off the server
                    NSMutableString *imageServerString = [[NSMutableString alloc] initWithString:@"http://users.soe.ucsc.edu/~dustinadams/walkAbout/images/"];
                    [imageServerString appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                    [imageServerString appendString:@"-"];
                    [imageServerString appendString:[NSString stringWithFormat:@"%06d", [[[clueArray objectAtIndex:j] objectForKey:@"clueID"] integerValue]]];
                    [imageServerString appendString:@"image"];
                    [imageServerString appendString:@".jpg"];
                    //end initialize path
                    
                    //initialize path to download the audio off the server
                    NSMutableString *audioServerString = [[NSMutableString alloc] initWithString:@"http://users.soe.ucsc.edu/~dustinadams/walkAbout/sound/"];
                    [audioServerString appendString:[[downloadArray objectAtIndex:i] objectForKey:@"uniqueID"]];
                    [audioServerString appendString:@"-"];
                    [audioServerString appendString:[NSString stringWithFormat:@"%06d", [[[clueArray objectAtIndex:j] objectForKey:@"ClueID"] integerValue]]];
                    [audioServerString appendString:@"sound"];
                    [audioServerString appendString:@".caf"];
                    //end initialize path
                    
                    //Now we download the image file from the server into our docs directory
                    NSURL *imageURL = [NSURL URLWithString:imageServerString];
                    //NSError *err;
                    if ([imageURL checkResourceIsReachableAndReturnError:&err] == NO)
                    {
                        //the file exists on the server
                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                        [imageData writeToFile:clueImagePath atomically:YES];
                        //Here we will download the file from the server and save it into our documents/images directory
                    }
                    else
                    {
                        //the file does not exist on the server
                    }
                    
                    //Now we download the audio file from the server into our docs directory
                    NSURL *audioURL = [NSURL URLWithString:audioServerString];
                    //NSError *err;
                    if ([audioURL checkResourceIsReachableAndReturnError:&err] == NO)
                    {
                        //the file exists on the server
                        NSData *audioData = [NSData dataWithContentsOfURL:audioURL];
                        [audioData writeToFile:clueAudioPath atomically:YES];
                        //Here we will download the file from the server and save it into our documents/images directory
                    }
                    else
                    {
                        //the file does not exist on the server
                    }
                    
                    
                }
                //Now we will save the clueArray into the documents/plists directory which is the clueListPath
                [clueArray writeToFile:clueListPath atomically:YES];
            }
            else
            {
                //the file does not exist on the server
                //Here we can either save a null plist or don't save anything at all
            }
            
        }
        //========================================================
        //END DOWNLOADING ALL THE FILES WE NEED FROM THE SERVER
        //========================================================

        
        //Now that we have the download array populated, we need to add all those objects to the end of the iphoneArray
        for (int i = 0; i < [downloadArray count]; i++)
        {
            [iphoneArray insertObject:[downloadArray objectAtIndex:i] atIndex:[iphoneArray count]];
        }
        //Now save the iphoneArray back into the documents/ directory
        [iphoneArray writeToFile:path atomically:YES];
        
        //do this for the userList
        for (int i = 0; i < [userDownloadArray count]; i++)
        {
            [userIphoneArray insertObject:[userDownloadArray objectAtIndex:i] atIndex:[userIphoneArray count]];
        }
        [userIphoneArray writeToFile:userPath atomically:YES];
        
        //also upload the iphoneArray to the server
        NSString *uploadPlistPHPPath = @"http://users.soe.ucsc.edu/~dustinadams/walkAbout/iPhoneUpload.php";
        NSString *plistFileName = @"walkList.plist";
        NSData *walkListData = [[NSData alloc] initWithContentsOfFile:path];
        NSLog(@"Result of uploading walkList.plist: %@", [self uploadFile:walkListData withPath:uploadPlistPHPPath withFileName:plistFileName]);
        connectLabel.text = @"Finished!";
        
        //also upload the userIphoneArray to the server
        NSString *userPlistFileName = @"usersPlist.plist";
        NSData *userWalkListData = [[NSData alloc] initWithContentsOfFile:userPath];
        NSLog(@"Result of uploading userList.plist: %@", [self uploadFile:userWalkListData withPath:uploadPlistPHPPath withFileName:userPlistFileName]);
    }
    else
    {
        connectLabel.text = @"Cannot connect to wifi";
    }
    
    //Now that we've downloaded all the clues we didn't have, we need to upload all the clues the server doesn't have

}

-(NSString *)uploadFile:(NSData *)data withPath:(NSString *)urlString withFileName:(NSString *)fileName
{
    //Now we need to upload the plist to the server
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:data]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //NSLog(@"Outcome: %@", returnString);
    return returnString;
}

// Checks if we have an internet connection or not
- (BOOL)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    /*
    // Internet is reachable
    
    [internetReachableFoo startNotifier];*/
    if (([internetReachableFoo currentReachabilityStatus] == ReachableViaWiFi) || ([internetReachableFoo currentReachabilityStatus] == ReachableViaWWAN))
    {
        // Do something that requires wifi
        return true;
    }
    //else if ([internetReachableFoo currentReachabilityStatus] == NotReachable)
    else
    {
        // Show alert because no wifi or 3g is available..
        return false;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

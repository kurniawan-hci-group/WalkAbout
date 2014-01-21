//
//  WalkAboutViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 6/14/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "WalkAboutViewController.h"

#define kUpdateFrequency    60.0

@interface WalkAboutViewController ()
{
    NSMutableArray *clueArray;
    int clueIndex;
    int numberOfSubviewsAdded;
    bool alertViewShowing;
    bool isSleeping;
    bool walkStarted;
    bool zoomOutPhotoShowing;
    bool zoomMedPhotoShowing;
    bool zoomInPhotoShowing;
    NSMutableArray *trueXcoords;
    NSMutableArray *trueYcoords;
    NSMutableArray *estXcoords;
    NSMutableArray *estYcoords;
    IBOutlet UIButton *startButton;
    UILabel *walkingLabel;
    UIImageView *zoomedMedImage;
    UIImageView *zoomedInImage;
}
@end

@implementation WalkAboutViewController
@synthesize scrollView;
@synthesize imageView;
@synthesize foreImage;
@synthesize locationManager;
@synthesize uniqueID;
@synthesize userName;
@synthesize walkUserName;
@synthesize barButton;
@synthesize directions;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    {
        //below is also the url of our current map image
        //imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://maps.googleapis.com/maps/api/staticmap?center=37.723327,-122.477588&zoom=17&size=640x640&sensor=false&maptype=hybrid&scale=4&path=color:0x0000ff|weight:5|37.721986,-122.475408|37.722208,-122.475368|37.722607,-122.475373|37.723123,-122.475345|37.723549,-122.475314|37.723953,-122.475288|37.724425,-122.475323|37.724589,-122.475185|37.724958,-122.475263|37.725208,-122.475271|37.725678,-122.475328|37.725494,-122.475675|37.725335,-122.476191|37.725648,-122.476583|37.725769,-122.476825|37.725646,-122.477299|37.725451,-122.477263|37.725207,-122.477016|37.724975,-122.476823|37.724699,-122.476888|37.724166,-122.477148|37.723798,-122.477131|37.723419,-122.477143|37.723025,-122.477283|37.722780,-122.477741|37.722846,-122.478352|37.722642,-122.478798|37.722552,-122.478996|37.722543,-122.479434|37.722597,-122.479903|37.722727,-122.480359|37.722324,-122.480509|37.721941,-122.480532|37.721943,-122.480037|37.721823,-122.479474|37.721772,-122.479167|37.721792,-122.478791|37.721677,-122.478280|37.721831,-122.478050|37.721771,-122.477818|37.721699,-122.477559|37.721522,-122.477094|37.721508,-122.476974"]]]];
        
        //here is the current url of the image we're using: http://maps.googleapis.com/maps/api/staticmap?center=41.304836,-123.527184&zoom=18&size=640x640&sensor=false&maptype=hybrid&scale=4&path=color:0x0000ff|weight:5|41.305035,-123.527458|41.304923,-123.527411|41.304826,-123.527473|41.304773,-123.527502|41.304717,-123.527535|41.304661,-123.527532|41.304604,-123.527523|41.304557,-123.527586|41.304489,-123.527705|41.304474,-123.527791|41.304393,-123.527743|41.304366,-123.527795|41.304339,-123.527808|41.304298,-123.527737|41.304268,-123.527685|41.304233,-123.527614|41.304221,-123.527498|41.304217,-123.527349|41.304189,-123.527177|41.304187,-123.527013|41.304244,-123.526964|41.304295,-123.526891|41.304369,-123.526904|41.304421,-123.526918|41.304593,-123.526992|41.304739,-123.527149|41.304827,-123.527186|41.304989,-123.527286|41.305025,-123.527393
        
        //THE DIMENSINOS OF OUR IMAGE map.png ARE 640 pixels x 640 pixels
    }
    accuracyCounter = 0;
    passingID = 0;
    clueIndex = -1;
    isSleeping = false;
    alertViewShowing = false;
    
    zoomInPhotoShowing = false;
    zoomMedPhotoShowing = false;
    zoomOutPhotoShowing = true;
    
    trueXcoords = [NSMutableArray new];
    trueYcoords = [NSMutableArray new];
    estXcoords = [NSMutableArray new];
    estYcoords = [NSMutableArray new];
    
    //Initialize latitude and longitude variables
    currLatitude = 41.305035;
    currLongitude = -123.527458;
    
    //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map.png"]];
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hybrid-zoomedIn.png"]];
    imageView.frame = CGRectMake(0, 0, imageView.frame.size.width/2, imageView.frame.size.height/2);
    
    /*zoomedMedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hybrid-zoomedMed.png"]];
    zoomedMedImage.frame = CGRectMake(0, 0, zoomedMedImage.frame.size.width/2, zoomedMedImage.frame.size.height/2);
    
    zoomedInImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hybrid-zoomedIn.png"]];
    zoomedInImage.frame = CGRectMake(0, 0, zoomedInImage.frame.size.width/2, zoomedInImage.frame.size.height/2);*/
    
    //Here we're going to create one clue view controller for each clue
    //THIS IS A BIG ISSUE: WE NEED TO CHECK TO SEE IF THERE IS EVEN A PLIST BY THIS NAME TO BEGIN WITH BECAUSE THE FIRST TIME, THERE WON'T BE
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //the new path is going to be the plist in the plists directory
    NSMutableString *path = [[NSMutableString alloc] initWithString:documentsDirectory];
    [path appendString:@"/plists/"];
    [path appendString:uniqueID];
    [path appendString:@".plist"];
    //NSString *path = [documentsDirectory stringByAppendingPathComponent:@"clueList.plist"];
    
    
    //create a start and end button to start the walk being used for testing at SFState campus
    /*UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startButton addTarget:self
               action:@selector(startWalk:)
     forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    //startButton.frame = CGRectMake(15, 420, 80.0, 30.0);
    startButton.frame = CGRectMake(15, 15, 80.0, 30.0);
    
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [endButton addTarget:self
               action:@selector(endWalk:)
     forControlEvents:UIControlEventTouchUpInside];
    [endButton setTitle:@"End" forState:UIControlStateNormal];
    //endButton.frame = CGRectMake(15, 455, 80.0, 30.0);
    endButton.frame = CGRectMake(15, 50, 80.0, 30.0);
    //end create the start button*/
    
    //add image to foreground
    foreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home.gif"]];
    foreImage.frame = CGRectMake((((640 * (123.527941 + currLongitude)) / .001650) + 320)/2.0, (((640 * (41.305425 - currLatitude)) / .001280) + 320)/2.0, foreImage.frame.size.width, foreImage.frame.size.height);
    //The first two arguments are the x and y coordinates where the image gets laid over
    [imageView addSubview:foreImage];
    //end add image to foreground
    
    numberOfSubviewsAdded = 0;
    
    //populate the clue list right here
    NSMutableArray *savedPlist = [[NSMutableArray alloc] initWithContentsOfFile:path];
    clueArray = [[NSMutableArray alloc] initWithCapacity:[savedPlist count]];
    //Once each clue is created, we need to display a dot on the screen for that clue
    for (int i=0;i < [savedPlist count];i++)
    {
        if (![[[savedPlist objectAtIndex:i] objectForKey:@"IsDeleted"] boolValue])
        {
            //populate the clue
            clueArray[i] = [Clue new];
            [clueArray[i] setClueID:[[savedPlist objectAtIndex:i] objectForKey:@"ClueID"]];
            [clueArray[i] setClueTitle:[[savedPlist objectAtIndex:i] objectForKey:@"ClueTitle"]];
            [(Clue *)clueArray[i] setLatitude:[[savedPlist objectAtIndex:i] objectForKey:@"ClueLat"]];
            [(Clue *)clueArray[i] setLongitude:[[savedPlist objectAtIndex:i] objectForKey:@"ClueLong"]];
            [(Clue *)clueArray[i] setDescription:[[savedPlist objectAtIndex:i] objectForKey:@"Description"]];
            [(Clue *)clueArray[i] setIsAQuestion:[[savedPlist objectAtIndex:i] objectForKey:@"QuestionAnswer"]];
            //display the dot
            UIImageView *dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clue.png"]];
            
            dotImage.frame = CGRectMake((((640 * (123.527941 + [[[savedPlist objectAtIndex:i] objectForKey:@"ClueLong"] doubleValue])) / .001650) + 320)/2.0, (((640 * (41.305425 - [[[savedPlist objectAtIndex:i] objectForKey:@"ClueLat"] doubleValue])) / .001280) + 320)/2.0, foreImage.frame.size.width/2, foreImage.frame.size.height/2);
            
            // foreImage.frame = CGRectMake(((640 * (123.527941 + currLongitude)) / .001650) + 320, ((640 * (41.305425 - currLatitude)) / .001280) + 320, foreImage.frame.size.width, foreImage.frame.size.height);
            //dotImage.frame = CGRectMake(0, 0, foreImage.frame.size.width, foreImage.frame.size.height);
            [imageView addSubview:dotImage];
        }
    }
    //end create clues
    
    [scrollView addSubview:imageView];
    //the frame of the scroll view needs to be the same as the bg image (the map)
    //scrollView.contentSize = CGSizeMake(imageView.frame.size.width/2,imageView.frame.size.height/2);
    scrollView.contentSize = CGSizeMake(imageView.frame.size.width,imageView.frame.size.height);
    scrollView.scrollEnabled = YES;
    scrollView.minimumZoomScale=.8;
    scrollView.maximumZoomScale = imageView.image.size.width / scrollView.frame.size.width;
    //scrollView.maximumZoomScale=4.0;
    //scrollView.zoomScale = 1.0;
    scrollView.delegate=self;
    
    
//******************************************************************************************
//UPDATE THE ACCELEROMETER
//******************************************************************************************
    locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.headingFilter = 1;
	locationManager.delegate = self;
	[locationManager startUpdatingHeading];
    
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [locationManager startUpdatingLocation];
    
    // Enable listening to the accelerometer
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    px = py = pz = 0;
    numSteps = 0;
    
//******************************************************************************************
//END UPDATE THE ACCELEROMETER
//******************************************************************************************


    
    //[self.view addSubview:startButton];
    //[self.view addSubview:endButton];
    
    [self populateArray];
    dummyIndex = 0;
    /*
    if (!alertViewShowing)
    {
    
        [NSTimer scheduledTimerWithTimeInterval:.1
                                         target:self
                                       selector:@selector(targetMethod)
                                       userInfo:nil
                                        repeats:YES];
    }*/
    
    //Right here we need to compare whether the user who is logged in is the same as the user who created the walk. If it's the same, we need to display a button to add a clue
    if ([userName isEqualToString:walkUserName])
    {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton addTarget:self
                    action:@selector(startWalk:)
          forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"Start walking" forState:UIControlStateNormal];
    //startButton.frame = CGRectMake(15, 420, 80.0, 30.0);
    startButton.frame = CGRectMake(10, 10, 105.0, 25.0);
    startButton.backgroundColor = [UIColor whiteColor];
    startButton.layer.borderColor = [UIColor blackColor].CGColor;
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    startButton.layer.borderWidth = 0.5f;
    startButton.layer.cornerRadius = 10.0f;
    walkStarted = FALSE;
    [self.view addSubview:startButton];
    
    walkingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, 75.0, 25.0)];
    walkingLabel.text = @"Walking";
    walkingLabel.textColor = [UIColor greenColor];
    [walkingLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    walkingLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:walkingLabel];
    walkingLabel.hidden = TRUE;
    
    //add the viewDirections button
    //add button to manually add directions
    directionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [directionsButton addTarget:self
                         action:@selector(viewDirections)
               forControlEvents:UIControlEventTouchUpInside];
    [directionsButton setTitle:@"Directions" forState:UIControlStateNormal];
    //startButton.frame = CGRectMake(15, 420, 80.0, 30.0);
    directionsButton.frame = CGRectMake(self.view.frame.size.width - 115, 10, 105.0, 25.0);
    directionsButton.backgroundColor = [UIColor whiteColor];
    directionsButton.layer.borderColor = [UIColor blackColor].CGColor;
    [directionsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    directionsButton.layer.borderWidth = 0.5f;
    directionsButton.layer.cornerRadius = 10.0f;
    [self.view addSubview:directionsButton];
}

-(void)viewDirections
{
    //show the directions
    //display a text field to get the directions
    //We need to display a simple view that says "Please be sure to review your walk" - request by Kathy
    directionsView = [UIView new];
    directionsView.frame = CGRectMake(25, 5, 270, 280);
    directionsView.backgroundColor = [UIColor whiteColor];
    directionsView.layer.borderColor = [UIColor blackColor].CGColor;
    directionsView.layer.borderWidth = 3.0f;
    
    UILabel *directionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, 220)];
    directionsLabel.layer.borderWidth = .5f;
    directionsLabel.layer.borderColor = [[UIColor grayColor] CGColor];
    directionsLabel.text = directions;
    [directionsView addSubview:directionsLabel];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(exitDirections)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    button.frame = CGRectMake(92, 235, 75.0, 30.0);
    [directionsView addSubview:button];
    
    //animate showing view
    [UIView transitionWithView:self.view
                      duration:.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.view addSubview:directionsView];
                        self.navigationController.navigationBar.hidden = YES;
                    }
                    completion:NULL];
}

-(void)exitDirections
{
    //exit the directions
    //animate showing view
    [UIView transitionWithView:self.view
                      duration:.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [directionsView removeFromSuperview];
                        self.navigationController.navigationBar.hidden = NO;
                    }
                    completion:NULL];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showClue"])
    {
        //Here we need to change the image and sound file paths that are getting pased to the ClueViewController file 
        
        isSleeping = true;
        //set all the information for the clue view controller
        ClueViewController *clueViewController = [segue destinationViewController];
        [clueViewController setClueTitle:[clueArray[clueIndex] clueTitle]];
        [clueViewController setUniqueID:uniqueID];
        [clueViewController setClueID:[clueArray[clueIndex] clueID]];
        [clueViewController setDescriptionString:[clueArray[clueIndex] description]];
        [clueViewController setIsQuestion:[clueArray[clueIndex] isAQuestion]];
        [clueViewController setUserUserName:userName];
        [clueViewController setWalkUserName:walkUserName];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSMutableString *imagePath = [[NSMutableString alloc] initWithString:documentsDirectory];
        [imagePath appendString:@"/images/"];
        [imagePath appendString:uniqueID];
        [imagePath appendString:@"-"];
        [imagePath appendString:[NSString stringWithFormat:@"%06d",[[clueArray[clueIndex] clueID] integerValue]]];
        [imagePath appendString:@"image.jpg"];
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imagePath]];
        UIImage *clueImage = [[UIImage alloc] initWithData:imageData];
        [clueViewController setImage:clueImage];
        
        NSMutableString *soundFile = [[NSMutableString alloc] initWithString:uniqueID];
        [soundFile appendString:@"-"];
        [soundFile appendString:[NSString stringWithFormat:@"%06d",[[clueArray[clueIndex] clueID] integerValue]]];
        [soundFile appendString:@"sound.caf"];
        [clueViewController setAudioFile:soundFile];

    }
    else if ([[segue identifier] isEqualToString:@"createClueSegue"])
    {
        CreateClueViewController *createClueViewController = [segue destinationViewController];
        
        //Here we need to pull up the clueArray from the documents/plists directory which will have the name of the walkID
        
        [createClueViewController setLongitude:currLongitude];
        [createClueViewController setLatitude:currLatitude];
        //the clueID will be stored into the createClueViewController as a string with the first 6 characters being the walkID, with the last 6 characters being the size of the clue array
        [createClueViewController setClueID:[[NSNumber alloc] initWithInt:[clueArray count]]];
        //[createClueViewController setWalkID:walkID];
        [createClueViewController setUniqueID:uniqueID];
        //we need to pass the gps coords to the createClueViewController
        [createClueViewController setIsNewClue:NO];
    }
}

-(IBAction)createClue:(id)sender
{
    [self performSegueWithIdentifier:@"createClueSegue" sender:self];
}

-(void)targetMethod
{
    if (!(isSleeping || alertViewShowing))
    {
        
        //everytime our home icon moves, we will check to see if it is in the vacinity of a clue.
        //When we do this with the accelerometer, everytime the new latitude and longitude is updated, we will check if that updated val is in the vacinity of a clue
        
            [self checkIfCloseToClue];
            currLongitude = path_y_coords[dummyIndex];
            currLatitude = path_x_coords[dummyIndex];
        
            foreImage.frame = CGRectMake(((640 * (122.479251 + path_y_coords[dummyIndex])) / .003400) + 320, ((640 * (37.724576 - path_x_coords[dummyIndex])) / .002700) + 320, foreImage.frame.size.width, foreImage.frame.size.height);
        
            [scrollView addSubview:imageView];
            //End moving icon
        
            //keep the array index from going out of bounds
            //if ((dummyIndex + 10) < 573)
            if ((dummyIndex + 10) < 341)
                dummyIndex = dummyIndex + 1;
            else
                dummyIndex = 0;
    }
}

-(IBAction)startWalk:(id)sender
{
    walkStarted = !walkStarted;
    NSLog(@"Start walk");
    if (walkStarted)
    {
        //set the button to say "End walk"
        [startButton setTitle:@"Pause" forState:UIControlStateNormal];
        walkingLabel.hidden = FALSE;
    }
    else
    {
        [startButton setTitle:@"Continue" forState:UIControlStateNormal];
        //set the button to say "Keep walking"
        walkingLabel.hidden = TRUE;
    }
}

-(IBAction)endWalk:(id)sender
{
    NSLog(@"End walk");
    //Here we need to save the walk and send it off
    if (walkStarted)
    {
        walkStarted = false;
        NSMutableDictionary *clueDictionary = [NSMutableDictionary dictionary];
        [clueDictionary setValue:trueXcoords forKey:@"TrueXcoords"];
        [clueDictionary setValue:trueYcoords forKey:@"TrueYcoords"];
        [clueDictionary setValue:estXcoords forKey:@"EstXcoords"];
        [clueDictionary setValue:estYcoords forKey:@"EstYcoords"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"estimation.plist"];
        
        //save the plist
        [clueDictionary writeToFile:path atomically:YES];
        
        
         //The below code is for uploading files to a server
         //convert the plist to NSData, which is imageData
         //replace filename with the actual file name
         //to convert to NSData, use
         NSData *data = [[NSData alloc] initWithContentsOfFile:path];
         
         //This is also a good tutorial: http://zcentric.com/2008/08/29/post-a-uiimage-to-the-web/
         
         NSString *urlString = @"http://users.soe.ucsc.edu/~dustinadams/iPhoneUpload.php";
         
         NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
         [request setURL:[NSURL URLWithString:urlString]];
         [request setHTTPMethod:@"POST"];
         
         NSString *boundary = @"---------------------------14737809831466499882746641449";
         NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
         [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
         
         NSMutableData *body = [NSMutableData data];
         [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"estimation.plist\"\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[NSData dataWithData:data]];
         [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         [request setHTTPBody:body];
         
         NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
         NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
         NSLog(@"Outcome: %@", returnString);
         //return ([returnString isEqualToString:@"OK"]);
        
    }
}

-(void)checkIfCloseToClue
{
    //loop through all the clues and see if our currLatitude and currLongitude is close to any of the clue's lats and longs
    
    if ((!alertViewShowing) && (!isSleeping))
    {
        clueIndex = -1;
    
        for (int i=0; ((i<[clueArray count]) && (!alertViewShowing)); i++)
        {
            clueIndex = clueIndex + 1;
            //if(((currLongitude <= ([[clueArray[i] longitude] doubleValue] + .000035)) && (currLongitude >= ([[clueArray[i] longitude] doubleValue] - .000035))) && ((currLatitude >= ([[clueArray[i] latitude] doubleValue] - .000035))&&(currLatitude <= ([[clueArray[i] latitude] doubleValue] + .000035))))
            //if(((currLongitude <= ([[clueArray[i] longitude] doubleValue] + .000070)) && (currLongitude >= ([[clueArray[i] longitude] doubleValue] - .000000))) && ((currLatitude >= ([[clueArray[i] latitude] doubleValue] - .000070))&&(currLatitude <= ([[clueArray[i] latitude] doubleValue] + .000000))))
            double longRange = .000060;
            double latRange = .000060;
            if(((currLongitude <= ([[(Clue *)clueArray[i] longitude] doubleValue] + longRange)) && (currLongitude >= ([[(Clue *)clueArray[i] longitude] doubleValue] - longRange))) && ((currLatitude >= ([[(Clue *)clueArray[i] latitude] doubleValue] - latRange))&&(currLatitude <= ([[(Clue *)clueArray[i] latitude] doubleValue] + latRange))))
            {
                //segue now
                if(!([clueArray [i] isVisited]))
                {
                    alertViewShowing = true;
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"You've reached a clue" message:@"Complete the clue." delegate:self
                                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    [alert show];
                    [clueArray [i] setIsVisited:YES];
                }
            }
        }
    }
}

-(void)populateArray
{
    double x[] = {41.305035, 41.305035, 41.305023, 41.305003, 41.304997, 41.304992, 41.304982, 41.304971, 41.304961, 41.304952, 41.304936, 41.30493, 41.304923, 41.304915, 41.304908, 41.304899, 41.304889, 41.304879, 41.304869, 41.304859, 41.304848, 41.304837, 41.304826, 41.304815, 41.304805, 41.304797, 41.304789, 41.304781, 41.304773, 41.304769, 41.304769, 41.304773, 41.304775, 41.304771, 41.304762, 41.304752, 41.304742, 41.304733, 41.304725, 41.304717, 41.30471, 41.304704, 41.304697, 41.304689, 41.304682, 41.304675, 41.304668, 41.304661, 41.304654, 41.304647, 41.304641, 41.304635, 41.304629, 41.304623, 41.304617, 41.304611, 41.304606, 41.304604, 41.304601, 41.304599, 41.304595, 41.304592, 41.304588, 41.304584, 41.304579, 41.304573, 41.304568, 41.304562, 41.304557, 41.304551, 41.304544, 41.304539, 41.304532, 41.304525, 41.304517, 41.304511, 41.304506, 41.3045, 41.304496, 41.304492, 41.304489, 41.304489, 41.304491, 41.304494, 41.304495, 41.304493, 41.304491, 41.304488, 41.304485, 41.30448, 41.304474, 41.304467, 41.304461, 41.30445, 41.304441, 41.304431, 41.304424, 41.304416, 41.304409, 41.304403, 41.304399, 41.304395, 41.304393, 41.304391, 41.304387, 41.304383, 41.304381, 41.304382, 41.304383, 41.304381, 41.304377, 41.304375, 41.304374, 41.304373, 41.30437, 41.304366, 41.304365, 41.304367, 41.304366, 41.304362, 41.304358, 41.304354, 41.30435, 41.304347, 41.304343, 41.304339, 41.304334, 41.304328, 41.304322, 41.304316, 41.30431, 41.304306, 41.304303, 41.304302, 41.304302, 41.304303, 41.304305, 41.304307, 41.304305, 41.304302, 41.304298, 41.304292, 41.304288, 41.304284, 41.30428, 41.304275, 41.304271, 41.304268, 41.304269, 41.304268, 41.304264, 41.304258, 41.304254, 41.304255, 41.304255, 41.304254, 41.304251, 41.304247, 41.304242, 41.304237, 41.304233, 41.304229, 41.304225, 41.304218, 41.304213, 41.304211, 41.304211, 41.304211, 41.304211, 41.304211, 41.304213, 41.304215, 41.304218, 41.304221, 41.304223, 41.304225, 41.304226, 41.304226, 41.304224, 41.304222, 41.304221, 41.304221, 41.304221, 41.30422, 41.304219, 41.304217, 41.304216, 41.304216, 41.304216, 41.304215, 41.304212, 41.304209, 41.304207, 41.304206, 41.304204, 41.3042, 41.304197, 41.304194, 41.304191, 41.304189, 41.304187, 41.304185, 41.304184, 41.304183, 41.304183, 41.304182, 41.304181, 41.304181, 41.304181, 41.304181, 41.304182, 41.304184, 41.304185, 41.304186, 41.304187, 41.304187, 41.30419, 41.304194, 41.304199, 41.304205, 41.304211, 41.304214, 41.304213, 41.304213, 41.304219, 41.304225, 41.30423, 41.304235, 41.30424, 41.304244, 41.304248, 41.304252, 41.304255, 41.304254, 41.304256, 41.304259, 41.304261, 41.304264, 41.304268, 41.304274, 41.30428, 41.304284, 41.304289, 41.304295, 41.304301, 41.304307, 41.304313, 41.304319, 41.304325, 41.304331, 41.304338, 41.304345, 41.30435, 41.304356, 41.304361, 41.304365, 41.304369, 41.304369, 41.304368, 41.304368, 41.304368, 41.304368, 41.304368, 41.304372, 41.304378, 41.304385, 41.304391, 41.304397, 41.304404, 41.304412, 41.304421, 41.30443, 41.304439, 41.304449, 41.30446, 41.30447, 41.304482, 41.304495, 41.30451, 41.304524, 41.304535, 41.304544, 41.304554, 41.304565, 41.304576, 41.304585, 41.304593, 41.3046, 41.304606, 41.304613, 41.304623, 41.304634, 41.304646, 41.304658, 41.30467, 41.304682, 41.304693, 41.304701, 41.304709, 41.304719, 41.304729, 41.304739, 41.304749, 41.304759, 41.304768, 41.304776, 41.304773, 41.30477, 41.304772, 41.304779, 41.304785, 41.304792, 41.304802, 41.304812, 41.304827, 41.304845, 41.304861, 41.304876, 41.304889, 41.304901, 41.304912, 41.304924, 41.304935, 41.304947, 41.30496, 41.304971, 41.304981, 41.304989, 41.304993, 41.304994, 41.304996, 41.305001, 41.305007, 41.305012, 41.305013, 41.305014, 41.305014, 41.305016, 41.30502, 41.305025, 41.30503};
    double y[] = {-123.527458, -123.527458, -123.52742, -123.527402, -123.527394, -123.527396, -123.527413, -123.527422, -123.527422, -123.527412, -123.527418, -123.52741, -123.527411, -123.527417, -123.527423, -123.527431, -123.527439, -123.527447, -123.527455, -123.527462, -123.527467, -123.527471, -123.527473, -123.52747, -123.527464, -123.527457, -123.527452, -123.527453, -123.527459, -123.527472, -123.527487, -123.527502, -123.527516, -123.527529, -123.527536, -123.527536, -123.527533, -123.527531, -123.527532, -123.527535, -123.527537, -123.52754, -123.527543, -123.527541, -123.527537, -123.527534, -123.527533, -123.527532, -123.52753, -123.527528, -123.527523, -123.527519, -123.52752, -123.527522, -123.527526, -123.527526, -123.527524, -123.527523, -123.527525, -123.527526, -123.527525, -123.527526, -123.527529, -123.527536, -123.527544, -123.527554, -123.527565, -123.527575, -123.527586, -123.527596, -123.527605, -123.527615, -123.527626, -123.527638, -123.527649, -123.527659, -123.527668, -123.527677, -123.527687, -123.527696, -123.527705, -123.527715, -123.527723, -123.527731, -123.52774, -123.52775, -123.52776, -123.52777, -123.527779, -123.527786, -123.527791, -123.527792, -123.527789, -123.527782, -123.527774, -123.527768, -123.527761, -123.527755, -123.527753, -123.527753, -123.527753, -123.527749, -123.527743, -123.527737, -123.527734, -123.527738, -123.527746, -123.527756, -123.527764, -123.52777, -123.527773, -123.527778, -123.527786, -123.527793, -123.527798, -123.527795, -123.527786, -123.527779, -123.527773, -123.527772, -123.527776, -123.527781, -123.527787, -123.527793, -123.5278, -123.527808, -123.527815, -123.527819, -123.527821, -123.527821, -123.527817, -123.527809, -123.527801, -123.527791, -123.527781, -123.527772, -123.527764, -123.527757, -123.527749, -123.527742, -123.527737, -123.527732, -123.527726, -123.52772, -123.527715, -123.527711, -123.527707, -123.527699, -123.527692, -123.527685, -123.527681, -123.527679, -123.527675, -123.527668, -123.527661, -123.527654, -123.527646, -123.527638, -123.52763, -123.527622, -123.527614, -123.527606, -123.527599, -123.527591, -123.527582, -123.527572, -123.527561, -123.527553, -123.527543, -123.527535, -123.527526, -123.527518, -123.527508, -123.527498, -123.527486, -123.527474, -123.527463, -123.527451, -123.52744, -123.527428, -123.527416, -123.527405, -123.527392, -123.527378, -123.527364, -123.527349, -123.527335, -123.527321, -123.527306, -123.52729, -123.527276, -123.527263, -123.52725, -123.527238, -123.527227, -123.527216, -123.527206, -123.527196, -123.527187, -123.527177, -123.527167, -123.527156, -123.527144, -123.527133, -123.527121, -123.52711, -123.527098, -123.527088, -123.527077, -123.527065, -123.527053, -123.527042, -123.527032, -123.527022, -123.527013, -123.527013, -123.527006, -123.527001, -123.526996, -123.526992, -123.526989, -123.526982, -123.526978, -123.526974, -123.52697, -123.526966, -123.526963, -123.526962, -123.526962, -123.526964, -123.526966, -123.526966, -123.526965, -123.526957, -123.526949, -123.526942, -123.526935, -123.526927, -123.52692, -123.526913, -123.526907, -123.526902, -123.526897, -123.526891, -123.526884, -123.526877, -123.526872, -123.526869, -123.526868, -123.526866, -123.526867, -123.526869, -123.526875, -123.52688, -123.526886, -123.526892, -123.526897, -123.526904, -123.52691, -123.52691, -123.52691, -123.52691, -123.526912, -123.526911, -123.526912, -123.526913, -123.526917, -123.526922, -123.526924, -123.526921, -123.526918, -123.526913, -123.526909, -123.526907, -123.526911, -123.526918, -123.526923, -123.526927, -123.52693, -123.526932, -123.526939, -123.526949, -123.526957, -123.526962, -123.526968, -123.526979, -123.526992, -123.527008, -123.527024, -123.527038, -123.527049, -123.527057, -123.527065, -123.527074, -123.527081, -123.527089, -123.527098, -123.527109, -123.527123, -123.527133, -123.52714, -123.527149, -123.527159, -123.527167, -123.527171, -123.527169, -123.527161, -123.527162, -123.527161, -123.527165, -123.527173, -123.527181, -123.527185, -123.527186, -123.527186, -123.527188, -123.527189, -123.527193, -123.5272, -123.52721, -123.527221, -123.52723, -123.52724, -123.527246, -123.527253, -123.52726, -123.527271, -123.527286, -123.527303, -123.527322, -123.527339, -123.527354, -123.527367, -123.527377, -123.527377, -123.527378, -123.527381, -123.527385, -123.52739, -123.527393, -123.527392};
    for (int i=0; i<341; i++)
    {
        path_x_coords[i] = x[i];
        path_y_coords[i] = y[i];
    }
}

-(void)calculateDistance
{
    //for (int j=0; j<573; j++)
    for (int j=0; j<341; j++)
    {
        distance[j] = sqrt(pow((currLatitude - path_x_coords[j]), 2) + pow((currLongitude - path_y_coords[j]), 2));
    }
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    
    if ((!isSleeping) && (!alertViewShowing) && (walkStarted))
    {
        xx = acceleration.x;
        yy = acceleration.y;
        zz = acceleration.z;
        
        dot = (px * xx) + (py * yy) + (pz * zz);
        a = ABS(sqrt(px * px + py * py + pz * pz));
        b = ABS(sqrt(xx * xx + yy * yy + zz * zz));
        
        dot /= (a * b);
        
        //if the user comes within lets say 5 ft of the clue, then something happens.
        
        //if (dot <= 0.82)
        //.997 is too sensitive
        if (dot <= .995)
        {
            if (!isSleeping)
            {
                //isSleeping = YES;
                [self performSelector:@selector(wakeUp) withObject:nil afterDelay:0.3];
                numSteps += 1;
                if (numSteps >= 680)
                {
                    numSteps = 0;
                }
                //ONCE A STEP IS DETECTED, GRAB THE LAST KNOWN HEADING, AND WITH THE ESTIMATED STEP SIZE, UPDATE DISPLACEMENT
                //z = step size (constant right now)
                //Theta = newRad
                //DeltaX = z * cos(Theta)
                //DeltaY = z * sin(Theta)
                //In terms of GPS units, one step (app. 2.5 ft.) is equal to about .00000685
                currLongitude = currLongitude + (.00000685 * cos(newRad + M_PI / 2));
                currLatitude = currLatitude + (.00000685 * sin(newRad + M_PI / 2));
                NSLog (@"STEP DETECTED:\nUPDATED DISPLACEMENT: %f, %f", currLongitude, currLatitude);
                
                currLatitude = path_x_coords[numSteps/2];
                currLongitude = path_y_coords[numSteps/2];
                
                [self checkIfCloseToClue];
                /*if (accuracyCounter == 6)
                {
                    
                    [self calculateDistance];
                
                    double lowestDistance = 1000;
                    int lowestDistanceIndex = 0;
                    //for (int k = 0; k<573; k++)
                    for (int k = 0; k<341; k++)
                    {
                        if(distance[k] < lowestDistance)
                        {
                            lowestDistance = distance[k];
                            lowestDistanceIndex = k;
                        }
                    }
                
                    currLatitude = path_x_coords[lowestDistanceIndex];
                    currLongitude = path_y_coords[lowestDistanceIndex];
                    
                    if (walkStarted)
                    {
                        //Here we need to log the currLatitude, currLongitude, and the GPS coords
                        NSLog(@"ACTUAL LOCATION: %f, %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
                        NSNumber *trueX = [[NSNumber alloc] initWithDouble:locationManager.location.coordinate.latitude];
                        NSNumber *trueY = [[NSNumber alloc] initWithDouble:locationManager.location.coordinate.longitude];
                        NSNumber *estX = [[NSNumber alloc] initWithDouble:currLatitude];
                        NSNumber *estY = [[NSNumber alloc] initWithDouble:currLongitude];
                        
                        
                        [trueXcoords addObject:trueX];
                        [trueYcoords addObject:trueY];
                        
                        [estXcoords addObject:estX];
                        [estYcoords addObject:estY];
                        
                    }
                    
                    accuracyCounter = 0;
                    
                    [self checkIfCloseToClue];
                }
                accuracyCounter++;*/
                
                //Now that we're getting the updated displacement, we need to move the icon on the screen
                //Calculate the new coordinates based on the pedometer
                
                //RIGHT NOW WE'RE GOING TO DISPLACE THE USERS CURRENT LOCATION ON THE MAP BY 320 pixels SO IT WILL SHOW UP IN THE MIDDLE
                
                //we're subtracting the initial latitude and longitude to make sure it fits fine on the screen
                
                //foreImage.frame = CGRectMake(((640 * (122.479221 + currLongitude)) / .001650) + 320, ((640 * (37.724556 - currLatitude)) / .001280) + 320, foreImage.frame.size.width, foreImage.frame.size.height);
                foreImage.frame = CGRectMake((((640 * (123.527941 + currLongitude)) / .001650) + 320)/2.0, (((640 * (41.305425 - currLatitude)) / .001280) + 320)/2.0, foreImage.frame.size.width, foreImage.frame.size.height);
                // foreImage.frame = CGRectMake((((640 * (123.527941 + currLongitude)) / .001650) + 320)/2.0, (((640 * (41.305425 - currLatitude)) / .001280) + 320)/2.0, foreImage.frame.size.width, foreImage.frame.size.height);
                [scrollView addSubview:imageView];
                //End moving icon
            }
        }
        
        px = xx; py = yy; pz = zz;
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alertViewShowing = false;
    //The OK button is at buttonIndex = 1.
    if (buttonIndex == 0)
    {
        isSleeping = false;
    }
    
    if (buttonIndex == 1)
    {
        [self performSegueWithIdentifier:@"showClue" sender:self];
    }
}

//CLLocationManagerDelegate method, called when the device changes heading
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	// Convert Degree to Radian and move the needle
    // The heading is relative to true north, so in order to perform any trig functions, we have to add Pi/2 to the heading
	oldRad =  -manager.heading.trueHeading * M_PI / 180.0f;
	newRad =  -newHeading.trueHeading * M_PI / 180.0f;
}


- (void)wakeUp
{
    isSleeping = NO;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollV withView:(UIView *)view atScale:(float)scale
{
    //[scrollView setContentSize:CGSizeMake(scale*1280, scale*1280)];
    [scrollView setContentSize:CGSizeMake(scale*640, scale*640)];
    
    if (scale > 4)
    {
        //redraw to the zoomed in image
        /*
        [[[scrollView subviews] objectAtIndex:([[scrollView subviews] count] - 1)] removeFromSuperview];
        [scrollView addSubview:zoomedInImage];
        [self.view insertSubview:scrollView belowSubview:[[self.view subviews] objectAtIndex:([[scrollView subviews] count] - 1)]];*/
        
    }
    else if(scale > 2)
    {
        //redraw to the zoomed medium image ([[scrollView subviews] count] - 1)

    }
    else
    {
        //redraw to the zoomed out image

    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    isSleeping = false;    
}
- (void)viewDidDisappear:(BOOL)animated
{
    isSleeping = true;
}

//the delegate needs to be set to nil before the view controller is completely deallocated, otherwise app will crash
-(void)dealloc
{
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  CreateWalkViewController.m
//  WalkAbout
//
//  Created by Dustin Adams on 7/19/13.
//  Copyright (c) 2013 Dustin Adams. All rights reserved.
//

#import "CreateWalkViewController.h"
#define kUpdateFrequency    60.0

@interface CreateWalkViewController ()

@end

@implementation CreateWalkViewController
@synthesize scrollView;
@synthesize imageView;
@synthesize foreImage;
@synthesize locationManager;
@synthesize motionManager;
@synthesize walkName;
@synthesize userName;
@synthesize startBarButton;
@synthesize directionsBarButton;

double Sensor_Data[8];
double countx,county ;
double accelerationx[2], accelerationy[2];
double velocityx[2], velocityy[2];
double pythagoreanVelocity;
double positionX[2];
double positionY[2];
double positionZ[2];
double direction;
double sstatex,sstatey;

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
	// Do any additional setup after loading the view, typically from a nib.
    accuracyCounter = 0;
    pickerIndex = 0;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hybrid-zoomedIn.png"]];
    imageView.frame = CGRectMake(0, 0, imageView.frame.size.width/2, imageView.frame.size.height/2);
    
    saveWalk = FALSE;
    showNameAlert = TRUE;
    viewIsShowing = TRUE;
    descriptionAlert = FALSE;
    
    //Initialize latitude and longitude variables
    currLatitude = 41.305035;
    currLongitude = -123.527458;
    
    /*UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(createClue:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Create" forState:UIControlStateNormal];
    button.frame = CGRectMake(25, 425, 100.0, 40.0);*/
    
    //add image to foreground
    foreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home.gif"]];
    
    foreImage.frame = CGRectMake((((640 * (123.527941 + currLongitude)) / .001650) + 320)/2.0, (((640 * (41.305425 - currLatitude)) / .001280) + 320)/2.0, foreImage.frame.size.width, foreImage.frame.size.height);
    //The first two arguments are the x and y coordinates where the image gets laid over
    [imageView addSubview:foreImage];
    //end add image to foreground
    
    [scrollView addSubview:imageView];
    //the frame of the scroll view needs to be the same as the bg image (the map)
    scrollView.contentSize = CGSizeMake(imageView.frame.size.width,imageView.frame.size.height);
    scrollView.scrollEnabled = YES;
    scrollView.minimumZoomScale=.8;
    scrollView.maximumZoomScale=imageView.image.size.width / scrollView.frame.size.width;
    scrollView.delegate=self;
    
    
    //******************************************************************************************
    //UPDATE THE ACCELEROMETER
    //******************************************************************************************
    locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.headingFilter = 1;
	locationManager.delegate = self;
	[locationManager startUpdatingHeading];
    
    // Allocate motion manager and enable listening to the accelerometer
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.01; // 100 Hz
    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startDeviceMotionUpdates];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getAccelerometer:) userInfo:nil repeats:YES];
    
    //Old accelerometer code.
    //[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
    //[[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    px = py = pz = 0;
    numSteps = 0;
    
    //******************************************************************************************
    //END UPDATE THE ACCELEROMETER
    //******************************************************************************************
    
    
    //Initialize latitude and longitude variables
    //currLatitude = 41.305035;41.305425
    //currLongitude = -123.527458;
    
    //[self.view addSubview:button];
    
    [self populateArray];
    dummyIndex = 0;
    
    //Go ahead and initialize our walkArray
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"walkList.plist"];
    
    if ([fileManager fileExistsAtPath:path])
    {
        walkArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    else
    {
        walkArray = [NSMutableArray new];
    }
    //end initializing walkArray
    
    //walkID = [[NSNumber alloc] initWithInt:[walkArray count]];
    
    
    //create the uialertview for text input
    // Ask for Username and password.
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Enter walk name:" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    // Adds a username Field
    /*UITextField *utextfield = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    utextfield.placeholder = @"Walk name";
    [utextfield setBackgroundColor:[UIColor whiteColor]];
    [alertview addSubview:utextfield];
    [utextfield becomeFirstResponder];*/

    // Move a little to show up the keyboard
    //CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
    //[alertview setTransform:transform];
    
    viewIsShowing = FALSE;
    // Show alert on screen.
    [alertview show];
    
    //we need to set this flag to false for right now, just so it's not moving while the user is entering the walk name

    
    //Create the unique key for walk
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy-HH-mm-ss"];
    uniqueKey = [formatter stringFromDate:[NSDate date]];
    //end create uniqueKey

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"End Walk" style:UIBarButtonItemStyleBordered target:self action:@selector(endWalk:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Insert" style:UIBarButtonItemStyleBordered target:self action:@selector(createClue:)];
    
    //add start button for walk
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
    
    //add label to indicate the user is walking
    walkingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, 75.0, 25.0)];
    walkingLabel.text = @"Walking";
    walkingLabel.textColor = [UIColor greenColor];
    [walkingLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    walkingLabel.backgroundColor = [UIColor clearColor];
    //[walkLabelView addSubview:walkingLabel];
    [self.view addSubview:walkingLabel];
    walkingLabel.hidden = TRUE;
    
    //add button to manually add directions
    directionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [directionsButton addTarget:self
                    action:@selector(addDirections:)
          forControlEvents:UIControlEventTouchUpInside];
    [directionsButton setTitle:@"Directions" forState:UIControlStateNormal];
    //[directionsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    //startButton.frame = CGRectMake(15, 420, 80.0, 30.0);
    directionsButton.frame = CGRectMake(self.view.frame.size.width - 115, 10, 105.0, 25.0);
    directionsButton.backgroundColor = [UIColor whiteColor];
    directionsButton.layer.borderColor = [UIColor blackColor].CGColor;
    [directionsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    directionsButton.layer.borderWidth = 0.5f;
    directionsButton.layer.cornerRadius = 10.0f;
    //directionsButton.frame = CGRectMake(0, 0, 105.0, 25.0);
    //[directionsButtonView addSubview:directionsButton];
    [self.view addSubview:directionsButton];
    //[self.view bringSubviewToFront:directionsButton];
    //[directionsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    //directionsButton.frame = CGRectMake(self.view.frame.size.width - 115, 30, 105.0, 25.0);

}

-(void)viewDidAppear:(BOOL)animated
{
    if (showNameAlert)
        viewIsShowing = FALSE;
    else
        viewIsShowing = TRUE;
    //here we need to count the total amount of clues already in the array
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString *path = [[NSMutableString alloc] initWithString:documentsDirectory];
    [path appendString:@"/plists/"];
    [path appendString:uniqueKey];
    [path appendString:@".plist"];
    
    if ([fileManager fileExistsAtPath:path])
    {
        clueArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    else
    {
        clueArray = [NSMutableArray new];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    viewIsShowing = FALSE;
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

-(IBAction)addDirections:(id)sender
{
    //display a text field to get the directions
    //We need to display a simple view that says "Please be sure to review your walk" - request by Kathy
    directionsView = [UIView new];
    directionsView.frame = CGRectMake(25, 5, 270, 210);
    directionsView.backgroundColor = [UIColor whiteColor];
    directionsView.layer.borderColor = [UIColor blackColor].CGColor;
    directionsView.layer.borderWidth = 3.0f;
    
    textField = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 250, 150)];
    if (directions == nil)
    {
        textField.text = @"Enter directions";
    }
    else
    {
        textField.text = directions;
    }
    textField.font = [UIFont systemFontOfSize:17.0];
    textField.layer.borderWidth = .5f;
    textField.layer.borderColor = [[UIColor grayColor] CGColor];
    [textField becomeFirstResponder];
    [directionsView addSubview:textField];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(finishAddingDirections)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    button.frame = CGRectMake(92, 165, 75.0, 30.0);
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

-(void)finishAddingDirections
{
    directions = [NSMutableString stringWithString:textField.text];
    //[self.navigationController popViewControllerAnimated:YES];
    [UIView transitionWithView:self.view
                      duration:.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [directionsView removeFromSuperview];
                    }
                    completion:NULL];
    self.navigationController.navigationBar.hidden = NO;
}

-(IBAction)endWalk:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Want to save?" message:@"Do you want to save this walk?" delegate:self
                          cancelButtonTitle:@"Don't Save" otherButtonTitles:@"Save", @"Cancel", nil];
    [alert show];
}

-(void)calculateDistance
{
    for (int j=0; j<341; j++)
    {
        distance[j] = sqrt(pow((currLatitude - path_x_coords[j]), 2) + pow((currLongitude - path_y_coords[j]), 2));
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return; //Cancel
    }
    else if (buttonIndex == 1)
    {
        if (showNameAlert)
        {
            //UITextField *field = (UITextField *)[[alertView subviews] lastObject];
            UITextField *field = [alertView textFieldAtIndex:0];
            NSLog (@"%@", field.text);
            walkName = field.text;
            showNameAlert = FALSE;
            viewIsShowing = TRUE;
        }
        else
        {
            
            //We need to display one more uialertview to ask for a description
            //[self.navigationController popViewControllerAnimated:YES];
            UIView *describeView = [UIView new];
            describeView.frame = CGRectMake(25, 5, 270, 280);
            describeView.backgroundColor = [UIColor whiteColor];
            describeView.layer.borderColor = [UIColor blackColor].CGColor;
            describeView.layer.borderWidth = 3.0f;
            
            UILabel *titleLabel = [UILabel new];
            titleLabel.frame = CGRectMake(50, 0, 200, 35);
            titleLabel.backgroundColor = [UIColor whiteColor];
            titleLabel.text = @"Describe your walk";
            titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18.0];
            [describeView addSubview:titleLabel];
            
            descriptionLabel = [UILabel new];
            descriptionLabel.frame = CGRectMake(10, 40, 110, 30);
            descriptionLabel.backgroundColor = [UIColor whiteColor];
            descriptionLabel.text = @"Description:";
            descriptionLabel.font = [UIFont fontWithName:@"Arial" size:18.0];
            descriptionLabel.textAlignment = NSTextAlignmentRight;
            [describeView addSubview:descriptionLabel];
            
            descriptionTextView = [UITextView new];
            descriptionTextView.frame = CGRectMake(125, 40, 125, 30);
            descriptionTextView.font = [UIFont fontWithName:@"System" size:20.0]; // text font
            descriptionTextView.layer.borderColor = [UIColor blackColor].CGColor;
            descriptionTextView.layer.borderWidth = 1.5f;
            [descriptionTextView becomeFirstResponder];
            [describeView addSubview:descriptionTextView];
            
            difficultyLabel = [UILabel new];
            difficultyLabel.frame = CGRectMake(10, 80, 110, 30);
            difficultyLabel.backgroundColor = [UIColor whiteColor];
            difficultyLabel.text = @"Difficulty:";
            difficultyLabel.font = [UIFont fontWithName:@"Arial" size:18.0];
            difficultyLabel.textAlignment = NSTextAlignmentRight;
            [describeView addSubview:difficultyLabel];
            
            difficultyPickerView = [UIPickerView new];
            difficultyPickerView.frame = CGRectMake(125, 80, 125, 30);
            difficultyPickerView.delegate = self;
            difficultyPickerView.showsSelectionIndicator = YES;
            [describeView addSubview:difficultyPickerView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self
                       action:@selector(getDescription)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Done" forState:UIControlStateNormal];
            button.frame = CGRectMake(125, 245, 75.0, 30.0);
            [describeView addSubview:button];
            
            //animate showing view
            [UIView transitionWithView:self.view
                              duration:1.0
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                [self.view addSubview:describeView];
                                self.navigationController.navigationBar.hidden = YES;
                            }
                            completion:NULL];
            //[self.view addSubview:describeView];
        }
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Handle the selection
    pickerIndex = row;
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 3;
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *difficulty = [[NSArray alloc] initWithObjects:@"Easy", @"Medium", @"Hard", nil];
    NSString *title = [difficulty objectAtIndex:row];
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    int sectionWidth = 100;
    return sectionWidth;
}

-(void)getDescription
{
    //once the walk ends, we need to add all this information to the plist and save it back to the home directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"walkList.plist"];
    
    NSArray *difficulty = [[NSArray alloc] initWithObjects:@"Easy", @"Medium", @"Hard", nil];
    NSString *title = [difficulty objectAtIndex:pickerIndex];
    
    NSMutableDictionary *walkEntry = [NSMutableDictionary new];
    [walkEntry setValue:uniqueKey forKey:@"uniqueID"];
    [walkEntry setValue:walkName forKey:@"walkName"];
    [walkEntry setValue:userName forKey:@"userName"];
    [walkEntry setValue:descriptionTextView.text forKey:@"description"];
    [walkEntry setValue:title forKey:@"difficulty"];
    if (directions == nil)
    {
        [walkEntry setValue:@"no directions" forKey:@"directions"];
    }
    else
    {
        [walkEntry setValue:directions forKey:@"directions"];
    }
    //Instead of saving the clueArray with the walkPlist, we will save a plist file by the name of the walkID in a directory named plists
    //[walkEntry setValue:[[NSNumber alloc] initWithInt:[clueArray count]] forKey:@"clueID"];
    [walkArray addObject:walkEntry];
    [walkArray writeToFile:path atomically:YES];
    
    
    //We need to display a simple view that says "Please be sure to review your walk" - request by Kathy
    UIView *describeView = [UIView new];
    describeView.frame = CGRectMake(25, 5, 270, 280);
    describeView.backgroundColor = [UIColor whiteColor];
    describeView.layer.borderColor = [UIColor blackColor].CGColor;
    describeView.layer.borderWidth = 3.0f;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(35, 0, 200, 150);
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.text = @"Please remember to review your walk for correctness.";
    titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:24.0];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [describeView addSubview:titleLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(leaveScreen)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    button.frame = CGRectMake(92, 160, 75.0, 30.0);
    [describeView addSubview:button];
    
    //animate showing view
    [UIView transitionWithView:self.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.view addSubview:describeView];
                        self.navigationController.navigationBar.hidden = YES;
                    }
                    completion:NULL];
    //end show view
}

-(void)leaveScreen
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"createClueSegue"])
    {
        CreateClueViewController *createClueViewController = [segue destinationViewController];
        
        //Here we need to pull up the clueArray from the documents/plists directory which will have the name of the walkID
        
        [createClueViewController setLongitude:currLongitude];
        [createClueViewController setLatitude:currLatitude];
        //the clueID will be stored into the createClueViewController as a string with the first 6 characters being the walkID, with the last 6 characters being the size of the clue array
        [createClueViewController setClueID:[[NSNumber alloc] initWithInt:[clueArray count]]];
        //[createClueViewController setWalkID:walkID];
        [createClueViewController setUniqueID:uniqueKey];
        //we need to pass the gps coords to the createClueViewController
        [createClueViewController setIsNewClue:YES];
    }
}

-(void) getAccelerometer:(NSTimer *) timer {
    //NSLog (@"X: %.2f Y: %.2f Z: %.2f", self.motionManager.accelerometerData.acceleration.x, self.motionManager.accelerometerData.acceleration.y, self.motionManager.accelerometerData.acceleration.z);
    if (!isSleeping && viewIsShowing && walkStarted)
    {
        
        //isSleeping = YES;
        [self performSelector:@selector(wakeUp) withObject:nil afterDelay:0.3];
        
        //Magic box the system
        //Take guesses at
        [self position];
        if(currLongitude > -123.525886) {
            currLongitude = -123.525880;
        } else if (currLongitude < -123.528749) {
            currLongitude = -123.5286;
        } else {
            currLongitude = pythagoreanVelocity * (.0000685 * cos(newRad + M_PI / 2)) + currLongitude;
        }
        
        if (currLatitude > 41.306104) {
            currLatitude = 41.3060;
        } else if (currLatitude < 41.30363) {
            currLatitude = 41.3037;
        } else {
            currLatitude = pythagoreanVelocity * (.0000685 * sin(newRad + M_PI / 2)) + currLatitude;
        }
        
        //instead of finding the closest point which we need to move close to, we're going to use the numSteps we've taken as an index to get our location
        
        //currLatitude = path_x_coords[numSteps/2];
        //currLongitude = path_y_coords[numSteps/2];
        NSLog(@"Moving with velocity %f towards heading %f", pythagoreanVelocity, newRad);
        // Magic numbers for a 'bounding box'
        foreImage.frame = CGRectMake((((640 * (123.527941 + currLongitude)) / .001650) + 320)/2.0, (((640 * (41.305425 - currLatitude)) / .001280) + 320)/2.0, foreImage.frame.size.width, foreImage.frame.size.height);
        [scrollView addSubview:imageView];
        //End moving icon
        
    }
}

- (void) movement_end_check {
    if (accelerationx[1] < 0.20) //we count the number of acceleration samples that equals cero
    { countx++;}
    else { countx =0;}
    
    if (countx>=25) //if this number exceeds 25, we can assume that velocity is cero
    {
        velocityx[1]=0;
        velocityx[0]=0;
    }
    
    if (accelerationy[1] < 0.20) //we do the same for the Y axis
    { county++;}
    else { county =0;}
    
    if (county>=25)
    { 
        velocityy[1]=0;
        velocityy[0]=0;
    } 
}

- (void) position {
    unsigned char count2 ;
    count2=0;
    double adjustedPitch = self.motionManager.deviceMotion.attitude.pitch *2/3;
    double adjustedAcceloY = self.motionManager.accelerometerData.acceleration.y + adjustedPitch;
    double adjustedAcceloZ = self.motionManager.accelerometerData.acceleration.z + 1 - adjustedPitch;
    accelerationx[1]= adjustedAcceloY;
    accelerationy[1]= adjustedAcceloZ;
    count2++;
    
    //accelerationx[1]= accelerationx[1]/4; // division by 4
    //accelerationy[1]= accelerationy[1]/4;
    
    if ((accelerationx[1] <=0.15)&&(accelerationx[1] >= -0.15)) //Discrimination window applied
    {accelerationx[1] = 0;} // to the X axis acceleration
    //variable
    
    if ((accelerationy[1] <=0.15)&&(accelerationy[1] >= -0.15))
    {accelerationy[1] = 0;}
    
    //NSLog(@"Acceleration is: %f %f", accelerationx[0], accelerationy[0]);
    
    //first X integration:
    velocityx[1]= velocityx[0]+ accelerationx[0]+ ((accelerationx[1] -accelerationx[0])/2);
    //first Y integration:
    velocityy[1] = velocityy[0] + accelerationy[0] + ((accelerationy[1] -accelerationy[0])/2);
    
    
    //second X integration:
    positionX[1]= positionX[0] + velocityx[0] + ((velocityx[1] - velocityx[0])/2);
    //second Y integration:
    positionY[1] = positionY[0] + velocityy[0] + ((velocityy[1] - velocityy[0])/2);
    
    accelerationx[0] = accelerationx[1]; //The current acceleration value must be sent
    //to the previous acceleration
    accelerationy[0] = accelerationy[1]; //variable in order to introduce the new
    //acceleration value.
    
    velocityx[0] = velocityx[1]; //Same done for the velocity variable
    velocityy[0] = velocityy[1];
    
    pythagoreanVelocity = sqrt((velocityx[0]*velocityx[0]) + (velocityy[0] * velocityy[0]));
    
    // These numbers need to be calibrated
    positionX[1] = positionX[1]*262144; //The idea behind this shifting (multiplication)
    //is a sensibility adjustment.
    positionY[1] = positionY[1]*262144; //Some applications require adjustments to a
    
    [self movement_end_check];
    
    positionX[0] = positionX[1]; //actual position data must be sent to the
    positionY[0] = positionY[1]; //previous position
    //NSLog(@"Position is: %f %f", positionX[0], positionY[0]);
    
    direction = 0; // data variable to direction variable reset
}

- (void)wakeUp
{
    isSleeping = false;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	// Convert Degree to Radian and move the needle
    // The heading is relative to true north, so in order to perform any trig functions, we have to add Pi/2 to the heading
	oldRad =  -manager.heading.trueHeading * M_PI / 180.0f;
	newRad =  -newHeading.trueHeading * M_PI / 180.0f;
    //NSLog(@"New magnetic heading: %f", newHeading.magneticHeading);
	//NSLog(@"New true heading: %f", newHeading.trueHeading);
}

-(IBAction)createClue:(id)sender
{
    NSLog(@"Create Clue clicked");
    //Now that a clue is to be created, we need to put the clueID, latitude and longitude into the clueArray
    
    /*NSMutableDictionary *clueEntry = [NSMutableDictionary new];
    NSMutableString *clueIdentifier = [NSString stringWithFormat:@"%06d", [walkID integerValue]];
    [clueIdentifier appendString:[NSString stringWithFormat:@"%06d", [clueArray count]]];
    [clueEntry setValue:clueIdentifier forKey:@"clueIdentifier"];
    [clueEntry setValue:[[NSNumber alloc] initWithFloat:currLatitude] forKey:@"Latitude"];
    [clueEntry setValue:[[NSNumber alloc] initWithFloat:currLongitude] forKey:@"Longitude"];*/
    
    //Here we need to create a UIAlertView to get the title and description of the clue since we need to log that info into the plist since we won't be able to do that in the createClueViewController class
    
    [self performSegueWithIdentifier:@"createClueSegue" sender:self];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [descriptionTextView resignFirstResponder];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollV withView:(UIView *)view atScale:(float)scale
{
    [scrollView setContentSize:CGSizeMake(scale*640, scale*640)];
}

-(void)dealloc
{
    //[[UIAccelerometer sharedAccelerometer] setDelegate:nil]; // Deprecated since motionmanager is now used.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

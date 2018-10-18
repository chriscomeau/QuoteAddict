//
//  SideMenuViewController.m


#import "SideMenuViewController.h"
#import "QuoteAddictAppDelegate.h"
//#import "FlurryAnalytics.h"
//#import "UIDevice-Hardware.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
@synthesize button5;
@synthesize button6;
@synthesize button7;
@synthesize button8;
@synthesize button9;
@synthesize button10;
@synthesize button11;
@synthesize button12;
@synthesize button13;
@synthesize buttonAll;
@synthesize buttonNew;
@synthesize buttonRandom;
@synthesize buttonFavorites;
@synthesize buttonUpdate;
@synthesize buttonRight;
@synthesize shadow;
@synthesize screenshot;

NSRecursiveLock *lock1;
NSRecursiveLock *lock2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    alreadyVisible = NO;
    
	//online
    [appDelegate setIsOnline:[appDelegate checkOnline]];
	
	//button
	buttonUpdate.hidden = !([appDelegate updateAvailable] && [appDelegate isOnline]);
    
    //screenshot
    [[self view] bringSubviewToFront:screenshot];
    
    [self updateButtons];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    alreadyVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    //alreadyVisible = NO;
}

- (void)viewDidLoad
{
    NSLog(@"%@", @"SideMenuViewController::viewDidLoad");
    
    [super viewDidLoad];
        
    appDelegate = (QuoteAddictAppDelegate *)[[UIApplication sharedApplication] delegate];

    lock1 = [[NSRecursiveLock alloc] init];
    lock2 = [[NSRecursiveLock alloc] init];
        
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    //self.view.alpha = 0.5f;
    
    buttonArray = [NSMutableArray array];
    [buttonArray addObject:button1];
    [buttonArray addObject:button2];
    [buttonArray addObject:button3];
    [buttonArray addObject:button4];
    [buttonArray addObject:button5];
    [buttonArray addObject:button6];
    [buttonArray addObject:button7];
    [buttonArray addObject:button8];
    [buttonArray addObject:button9];
    [buttonArray addObject:button10];
    [buttonArray addObject:button11];
    [buttonArray addObject:button12];
    [buttonArray addObject:button13];
    [buttonArray addObject:buttonAll];
    [buttonArray addObject:buttonNew];
    [buttonArray addObject:buttonRandom];
    [buttonArray addObject:buttonFavorites];

    stringArray = [NSMutableArray array];
    [stringArray addObject:@"Absurd"];
    [stringArray addObject:@"Cartoon"];
    [stringArray addObject:@"Comic"];
    [stringArray addObject:@"Funny"];
    [stringArray addObject:@"Game"];
    [stringArray addObject:@"Insightful"];
    [stringArray addObject:@"Love"];
    [stringArray addObject:@"Motivation"];
    [stringArray addObject:@"Movie"];
    [stringArray addObject:@"Religion"];
    [stringArray addObject:@"Science"];
    [stringArray addObject:@"Sport"];
    [stringArray addObject:@"TV"];
    [stringArray addObject:@"All"];
    [stringArray addObject:@"New"];
    [stringArray addObject:@"Random"];
    [stringArray addObject:@"Favorites"];

    buttonRight.hidden = NO;
    shadow.hidden = NO;
    screenshot.hidden = NO;
    shadow.alpha = 0.5f;
    alreadyVisible = NO;
    
    [buttonRight addTarget:self action:@selector(actionRight:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //button fonts
    //UIFont *tempFont = [UIFont fontWithName:@"PTSans-Bold" size:22] ;
    UIFont *tempFont = kButtonFont;
    int i = 0;
    int catIndex = 0;
    int numCat = 13;
            
    for (UIButton *button in buttonArray)
    {
        if(i==numCat)
        {
            //second column
            i = 0;
        }
        
        [button addTarget:self action:@selector(actionButton:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
        //NSLog(@"%@", button.titleLabel.text);
        [button setTitle:[stringArray objectAtIndex:catIndex] forState:UIControlStateNormal];

        button.titleLabel.font = tempFont;
        //[button setTitleColor:RGBA(120,120,120, 255) forState:UIControlStateHighlighted ];
        [button setTitleColor:RGBA(200,200,200, 255) forState:UIControlStateHighlighted ];

        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);
        button.hidden = NO;
               
        i++;
        catIndex++;
    }
    
    
    tempFont = [UIFont fontWithName:@"CenturyGothic-Bold" size:12] ; 
	buttonUpdate.titleLabel.font = tempFont;
    UIColor *buttonColor = [appDelegate buttonTextColor]; //[UIColor darkGrayColor];
    [buttonUpdate setTitleColor:buttonColor forState:UIControlStateNormal];
    [buttonUpdate addTarget:self action:@selector(actionUpdate:) forControlEvents:UIControlEventTouchUpInside];
    buttonUpdate.hidden = YES;
    
    //corner
    //[appDelegate cornerView:self.view];
    
    [self updateButtons];

}

- (void)updateButtons
{
    int i = 0;
    int catIndex = 0;
    int y = 22;
    int x = 20;
    int numCat = 13;
    int spacing = 0;
    
    //spacing
    if([appDelegate isIphone5])
    {
        spacing = 42;
    }
    else if([appDelegate isIpad])
    {
        if([appDelegate isPortrait])
            spacing = 64;
        else
            spacing = 54;
    }
    else
    {
        spacing = 34;
    }
    
    CGRect tempButtonFrame;
    
    for (UIButton *button in buttonArray)
    {
        if(i==numCat)
        {
            //second column
            i = 0;
            x = 150;
        }
        
    
        tempButtonFrame = button.frame;
        tempButtonFrame.origin.x = x;
        tempButtonFrame.origin.y = y + spacing * i;
        //tempButtonFrame.size.width = 260;
        button.Frame = tempButtonFrame;
        
               
        i++;
        catIndex++;
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([appDelegate isIpad] && !alreadyVisible)
    {
        return YES;
    }
    else 
    {
        if(interfaceOrientation == UIDeviceOrientationPortrait) 
            return YES;
        else 
            return NO;
    }
}

- (BOOL)shouldAutorotate
{
    if([appDelegate isIpad] && !alreadyVisible)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"AboutViewController::didRotateFromInterfaceOrientation");
	
    if([appDelegate isIpad])
    {
        //rotating = NO;
		
        [self updateUIOrientation];
        
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"AboutViewController::willRotateToInterfaceOrientation");
	
    if([appDelegate isIpad])
    {
        //otating = YES;
		
        [self updateUIOrientation];
    }
}

- (void)updateUIOrientation
{	
    [lock2 lock];
    
    NSLog(@"ConvertViewController::updateUIOrientation");
	
    if([appDelegate isIpad])
    {
        [self updateShadow:0 withScreen:[appDelegate GetScreenRect] ];

		/*int offset = 2;//4;
        CGRect tempFrame;
		
		//move close button
		tempFrame = closeButton.frame;
        tempFrame.origin.x = adButton.frame.origin.x - closeButton.frame.size.width/2 + offset;
        tempFrame.origin.y = adButton.frame.origin.y - closeButton.frame.size.height/2 + offset;
        closeButton.frame = tempFrame;
        
        //keep updating
        if(rotating)
            [self performSelector:@selector(updateUIOrientation) withObject:nil afterDelay:0.01];*/
		
    }
    
    [lock2 unlock];
}

- (void)actionButton:(id)sender forEvent:(UIEvent *)event
{    
    NSLog(@"SideMenuViewController::actionButton");
    UIButton *button = (UIButton*)sender;
    NSString *newSearchString = @"";
    
    if(USE_ANALYTICS == 1)
	{
        //[FlurryAnalytics logEvent:@"SideMenuViewController::actionMain"];
	}
    
    alreadyVisible = NO;
    [[appDelegate archiveViewController] toggleSlide];

    newSearchString = [NSString stringWithFormat:@"category:%@", button.titleLabel.text];
    [[appDelegate archiveViewController] forceSearch:newSearchString withDelay:YES];
}


- (void)actionUpdate:(id)sender
{
	NSLog(@"SideMenuViewController::actionUpdate");
	
    if(![appDelegate isOnline])
		return;

	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id580936901"]];
    
	[appDelegate setShowUpdate:YES];
    alreadyVisible = NO;
    [[appDelegate archiveViewController] toggleSlide];
}

- (void)actionRight:(id)sender forEvent:(UIEvent *)event
{    
    NSLog(@"SideMenuViewController::actionRight");
    
    alreadyVisible = NO;
    [[appDelegate archiveViewController] toggleSlide];
}

-(void)setupShadow:(int)x withScreen:(CGRect)screenRect
{
    //CGRect screenRect = [appDelegate GetScreenRect];
	//CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;

    shadow.hidden = NO;
    screenshot.hidden = NO;
    
    shadow.frame = CGRectMake(shadow.frame.origin.x, 0, shadow.frame.size.width, screenHeight);
    screenshot.frame = CGRectMake(screenshot.frame.origin.x, 0, screenshot.frame.size.width, screenHeight);

    //[self updateShadow:x withScreen:screenRect];

}

-(void)updateShadow:(int)x withScreen:(CGRect)screenRect
{
    [lock1 lock];
    
    //CGRect screenRect = [appDelegate GetScreenRect];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
    
    //shadow
    CGRect tempFrame;
    
    tempFrame = shadow.frame;
    shadow.frame = CGRectMake(shadow.frame.origin.x  + x, shadow.frame.origin.y, shadow.frame.size.width, shadow.frame.size.height);
    tempFrame = shadow.frame;
    
    //screenshot
    tempFrame = screenshot.frame;
    screenshot.frame = CGRectMake(shadow.frame.origin.x + shadow.frame.size.width, 0, screenWidth, screenHeight);
    tempFrame = screenshot.frame;

    //button
    buttonRight.frame = screenshot.frame;
    [lock1 unlock];
}

@end

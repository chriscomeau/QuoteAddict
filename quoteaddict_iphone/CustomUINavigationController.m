
#import "CustomUINavigationController.h"
#import "QuoteAddictAppDelegate.h"

@implementation CustomUINavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    appDelegate = (QuoteAddictAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    if([appDelegate isIpad])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        //return UIDeviceOrientationPortrait;
        return UIInterfaceOrientationMaskAllButUpsideDown;

    }
}

- (BOOL)shouldAutorotate
{
    if([appDelegate isIpad])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([appDelegate isIpad])
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


@end

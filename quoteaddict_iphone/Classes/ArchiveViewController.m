//
//  ArchiveViewController.m
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//noResultsImage

#import "ArchiveViewController.h"
#import "QuoteAddictAppDelegate.h"
//#import "TapForTap.h"
#import "UIAlertView+Errors.h"
#import "QuoteAddictIAPHelper.h"
#import <StoreKit/StoreKit.h>
 
@implementation ArchiveViewController

@synthesize tableView;
@synthesize darkImage;
@synthesize spin;
@synthesize tableViewController;
//@synthesize navigationController;
//@synthesize adView;
@synthesize closeButton;
@synthesize offlineImage;
@synthesize noResultsImage;
@synthesize adButton;
@synthesize badgeText;
@synthesize imageViewBadge;
@synthesize slide;
@synthesize tableButton;
@synthesize searchString;
@synthesize oldSearchString;
@synthesize searchBar2;
@synthesize HUD;

NSRecursiveLock *lock1;
NSRecursiveLock *lock2;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self becomeFirstResponder];

    lock1 = [[NSRecursiveLock alloc] init];
    lock2 = [[NSRecursiveLock alloc] init];

    appDelegate = (QuoteAddictAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate setArchiveViewController:self];

    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
	adDownloaded = NO;
    slide = NO;
    searchString = @"";
    oldSearchString = @"";
    slideX = 0;
    rotating = NO;
	
    //show load
    tableView.hidden = YES;
    darkImage.hidden = YES;
    spin.hidden = YES;
    
    noResultsImage.hidden = YES;
	offlineImage.hidden = YES;
    doHud = NO;
	closed = NO;

    //list
    tableViewController = [[TableViewController alloc] initWithStyle:UITableViewCellStyleDefault];
    //hide it
    tableViewController.view.hidden = NO;
   
    //autosize
    //tableViewController.view.autoresizingMask = UIViewAutoresizingNone;
    //tableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    tableViewController.view.autoresizingMask = tableView.autoresizingMask;
    
    //resize
    tableViewController.view.frame = tableView.frame;
    [self.view addSubview:tableViewController.view];
    
    self.tableView.scrollsToTop = NO;
    tableViewController.tableView.scrollsToTop = YES;
    //cell border
    //UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    tableViewController.tableView.tableFooterView = [UIView new];
	
    //fix separator ios7
    [tableViewController.tableView setSeparatorInset:UIEdgeInsetsZero];

	//for ad
	//oldTableHeight = tableViewController.tableView.frame.size.height - NAV_BAR_HEIGHT;

	//left button
	[self updateBadgeLeft];
    
    //invisible button covering table, to slide back
    [tableButton addTarget:self action:@selector(toggleSlide) forControlEvents:UIControlEventTouchUpInside];
    [[self view] bringSubviewToFront:tableButton];   
    tableButton.hidden = YES;
    tableButton.userInteractionEnabled = NO;
    
	[closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
	[adButton addTarget:self action:@selector(actionAd:) forControlEvents:UIControlEventTouchUpInside];

	self.closeButton.hidden = YES;
    self.adButton.hidden = YES;
    

    //show add on startup?
    [self showAd:YES];
    
    //delay?
    if([appDelegate isOnline])
        [appDelegate performSelector:@selector(updateAd) withObject:nil afterDelay:0.5];
	
    //[appDelegate updateAd];
    
	//if(false)
   /* if([appDelegate isTapForTap] && ![appDelegate isShowDefault])
	{
		//[self showAd:YES];
		[self setupAd];
	}*/
    
    
    //search bar
    if(true)
    {
        //UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
        searchBar2 = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];

        searchBar2.placeholder = @"Type a search term";
        //searchBar2.barTintColor = RGBA(121, 95, 54, 255); //[UIColor blackColor];
        searchBar2.barTintColor = RGBA(101,86,64, 255); //[UIColor blackColor];
        //searchBar2.barTintColor = RGBA(64, 46, 18, 255); //[UIColor blackColor];
        //searchBar2.tintColor = RGBA(64, 46, 18, 255); //[UIColor blackColor];
        searchBar2.delegate = self;
        

        //font
        /*for(UIView *subView in searchBar2.subviews)
        {
            if ([subView isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)subView;
                [textField setFont: [UIFont fontWithName:@"Century Gothic" size:12]];
                textField.textColor = RGBA(94, 94, 94, 255); //grey
                textField.returnKeyType = UIReturnKeyDone; //UIReturnKeySearch

                
                //allow empty search
                [textField setEnablesReturnKeyAutomatically:NO];
            }
        }*/
        
        for(UIView *subView in searchBar2.subviews)
        {
            for(UIView *subView2 in subView.subviews)
            {
                if ([subView2 isKindOfClass:[UITextField class]]) {
                    UITextField *textField = (UITextField *)subView2;
                    [textField setFont: [UIFont fontWithName:@"Century Gothic" size:12]];
                    textField.textColor = RGBA(94, 94, 94, 255); //grey
                    textField.returnKeyType = UIReturnKeyDone; //UIReturnKeySearch
                    
                    //allow empty search
                    [textField setEnablesReturnKeyAutomatically:NO];
                }
            }
        }
      
        //[searchBar sizeToFit];
        [searchBar2 setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        searchBar2.autocorrectionType = UITextAutocorrectionTypeNo;
        [searchBar2 sizeToFit];
        
        self.tableViewController.tableView.tableHeaderView = searchBar2;
        //[self.tableViewController.tableView scrollRectToVisible:[[self.tableView tableHeaderView] bounds] animated:NO];
    }
    
    
    //banner
    self.bannerView.delegate = self;
    self.bannerView.hidden = YES;
    self.closeButton.hidden = YES;
    self.adButton.hidden = YES;

}

- (void)notifyForeground
{
    NSLog(@"ArchivetViewController::notifyForeground");

	//reset, show on foreground
	//closed = NO;
    
    //update	
    [appDelegate setIsOnline:[appDelegate checkOnline]];
    
	//if(![appDelegate isOnline])
	//	[self showAd:NO];
    
    //ad
    [self updateBanner:YES];

    //else if(![appDelegate isShowDefault])
	//	[self showAd:YES]; //show on foreground
	
	//if(![appDelegate isOnline])
	{
		[appDelegate refresh];
	}
	
	//offline
	/*if([appDelegate isOnline])
		[self showOffline:NO];
	else
		[self showOffline:YES];
	*/
    
	//reload?
    //[appDelegate refresh];
    
    
     //switch ad
     if([appDelegate isOnline] && !closed && !self.adButton.hidden)
        [appDelegate performSelector:@selector(updateAd) withObject:nil afterDelay:0.5];
	
}

-(void)showOffline:(BOOL)show
{
    if(show)
    {
        //hide other
        [self showNoResults:NO];
        
        [[self view] bringSubviewToFront:self.offlineImage];
        
        //animate
        self.offlineImage.hidden = NO;
        self.offlineImage.alpha = 0.0;
        [UIView animateWithDuration:0.5
                                delay:0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{self.offlineImage.alpha = 1.0;}
                     completion:nil];
    }
    else
    {
        offlineImage.hidden = !show;
    }

}

-(void)showNoResults:(BOOL)show
{
    if(show)
    {
        //hide other
        [self showOffline:NO];
        
        [[self view] bringSubviewToFront:self.noResultsImage];
        
        //animate
        self.noResultsImage.hidden = NO;
        self.noResultsImage.alpha = 0.0;
        [UIView animateWithDuration:0.3
                                delay:0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{self.noResultsImage.alpha = 1.0;}
                     completion:nil];
    }
    else
    {
        noResultsImage.hidden = !show;
    }
}


-(void)hideAd
{
    int viewHeight = self.view.frame.size.height;
    
    //shrink table
    CGRect tempFrame = tableViewController.tableView.frame;
    tempFrame.size.height = viewHeight;
    tableViewController.tableView.frame = tempFrame;
    
    //[appDelegate setPrefPurchasedRemoveAds:YES];
    //[appDelegate saveState];
    
    self.adButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.bannerView.hidden = YES;

}

-(void)showAd:(BOOL)show
{
    //disabled
    if(YES && [appDelegate isDebug])
    {
     [self hideAd];
     return;
    }
    
    //always hidden
    self.adButton.hidden = NO;
    
    BOOL exit = NO;
    
    int adHeight = self.adButton.frame.size.height; //50;
    int viewHeight = self.view.frame.size.height;
    
    if(closed)
        exit = YES;
    
    else if([appDelegate isShowDefault])
        exit = YES;
    
    else if(![appDelegate isOnline] && show)
        exit = YES;
    
    else if([appDelegate prefPurchasedRemoveAds])
        exit = YES;
    
    else if (![appDelegate isDebug] && [[QuoteAddictIAPHelper sharedInstance] productPurchased:[appDelegate productRemoveAds].productIdentifier])
        exit = YES;
    
    //else if([appDelegate savedAdImage] == nil)
    //    exit = YES;
    
    
    //else if(show && adView != nil && adView.hidden == NO)
    //  exit = YES;
    //else if(!show && (adView == nil || adView.hidden == YES))
    //    exit = YES;
    
    
    
    if(exit)
    {
        [self hideAd];
        return;
    }
    
    //if(!adDownloaded)
    //	return;
    
    NSLog(@"showAd");
    
    //tapfortap
    //http://developer.tapfortap.com/sdk
    
    
    //shrink table
    CGRect tempFrame = tableViewController.tableView.frame;
    tempFrame.size.height = viewHeight;
    if(show)
        tempFrame.size.height -= adHeight;
    
    //not on ipad
    if(![appDelegate isIpad])
        tableViewController.tableView.frame = tempFrame;
    
    if(show)
    {
        //cross-fade
        /*[UIView transitionWithView:self.adButton
         duration:0.3f
         options:UIViewAnimationOptionTransitionCrossDissolve
         animations:^{
         [self.adButton setImage:[appDelegate savedAdImage] forState:UIControlStateNormal];
         } completion:nil];
         */
        
        
        //[self.adButton setImage:[appDelegate savedAdImage] forState:UIControlStateNormal];
        //int adX = 0;
        //int adY = 0;
        
        //adX = self.adButton.frame.origin.x;
        //adY = self.adButton.frame.origin.y; //0;
        
        
        //adView.hidden = NO;
        
        //[[self view] bringSubviewToFront:self.adButton];
        [[self view] bringSubviewToFront:self.bannerView];
        [[self view] bringSubviewToFront:self.closeButton];
        
        //fade in
        if(self.bannerView.hidden) //only of hidden
        {
            self.closeButton.alpha = 0.0;
            //self.adButton.alpha = 0.0;
            self.bannerView.alpha = 0.0;
            self.closeButton.hidden = NO;
            //self.adButton.hidden = NO;
            self.bannerView.hidden = NO;
            
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationCurveEaseInOut
                             animations:^{
                                 self.closeButton.alpha = 1.0;
                                 //self.adButton.alpha = 1.0;
                                 self.bannerView.alpha = 1.0;
                             }
                             completion:nil];
        }
        
        //move close
        /*int offset = 1;
         tempFrame = closeButton.frame;
         tempFrame.origin.x = adWidth - tempFrame.size.width + offset;
         tempFrame.origin.y = adY - tempFrame.size.height/2 + offset;
         closeButton.frame = tempFrame;*/
        
        //move back
        //self.adBack.frame = self.adView.frame;
        
        //[self updateUIOrientation];
    }
    else
    {
        //adButton.hidden = YES;
        closeButton.hidden = YES;
        self.bannerView.hidden = YES;
        //if(adView != nil)
        //	adView.hidden = YES;
    }
}


/*

// Hook up a button to this method to show an interstitial, or call it before pushing a view controller, etc.
- (IBAction) showInterstitial: (id)sender
{
    // Show an Interstitial
    [TapForTapInterstitial showWithRootViewController: self];
}

// Hook up a button to this method to show an app wall
- (IBAction) showMoreApps: (id)sender
{
    // Show an App Wall
    [TapForTapAppWall showWithRootViewController: self];
}

#pragma mark - TapForTapAdViewDelegate methods
*/

- (UIViewController *) rootViewController
{
    //return self; // or possibly self.navigationController
    return self.navigationController;
}

/*
- (void) tapForTapAdViewDidReceiveAd: (TapForTapAdView *)adView
{
    NSLog(@"tapForTapAdViewDidReceiveAd");
	
	if(closed)
		return;
	
	adDownloaded = YES;
	
	if(![appDelegate isOnline])
		[self showAd:NO];
    else if([appDelegate isTapForTap] && ![appDelegate isShowDefault])
		[self showAd:YES];
}

- (void) tapForTapAdView: (TapForTapAdView *)adView didFailToReceiveAd: (NSString *)reason
{
    NSLog(@"didFailToReceiveAd: %@", reason);
	[self showAd:NO];
}

- (void) tapForTapAdViewWasTapped: (TapForTapAdView *)adView
{
    NSLog(@"tapForTapAdViewWasTapped");
	
	//[self showAd:NO];
}
*/

- (void)actionMenu:(id)sender
{
    //hide keyboard
    [self hideKeyboard];
    
    [self toggleSlide];
    return;
    
    //popup
    /*UIActionSheet * actionSheet=nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a category..."
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil 
                                otherButtonTitles:@"All", @"Absurd",@"Cartoon", @"Comic", @"Funny", @"Game", @"Insightful", @"Love", @"Motivation", @"Movie", @"Religion",
                                 @"Science", @"Sport", @"TV", nil];*/
    
/*
Absurd
Cartoon
Comic 
Funny 
Game
Insightful 
Love 
Motivation 
Movie 
Religion 
Science 
Sport 
TV 
*/
    
    //[actionSheet showInView:self.view];
    //actionSheet.destructiveButtonIndex = 12;
    //[actionSheet showInView: [[appDelegate navController] navigationBar]];
}

- (void)actionClose:(id)sender
{
	//old way
    /*if([appDelegate isDebug] && ![appDelegate isSimulator])
    {
        [self showAd:NO];
        closed = YES;
        return;
    }*/
	    
    //offline ignore
    if(![appDelegate isOnline])
    {
        //message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In-App Purchases" message:@"Please try again when you are connected to the internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show]; 
        return;
	}
    
	SKProduct* product = [appDelegate productRemoveAds];

	if(product == nil)
	{
		//todo:chris: check
		[self showAd:NO];
		closed = YES;
		return;
	}
	
	//price
	NSNumberFormatter * _priceFormatter;
	_priceFormatter = [[NSNumberFormatter alloc] init];
	[_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	// Add to bottom of tableView:cellForRowAtIndexPath (before return cell)
	[_priceFormatter setLocale:product.priceLocale];
	
	NSString *price = [_priceFormatter stringFromNumber:product.price];
			
	alertRemoveAd = nil;
    alertRemoveAd = [[UIAlertView alloc] initWithTitle:@"Remove Ads"
											message:[NSString stringWithFormat:@"Do you want to permanently remove all banner ads and encourage an indie app developer? (%@)", price]
										   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	[alertRemoveAd show];
	
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:    (NSInteger)buttonIndex
{
	
    if(alertView == alertRemoveAd)
    {
        if(buttonIndex==0)
        {
            //cancel
        }
        else if(buttonIndex==1)
        {
			//[self showAd:NO];
			//closed = YES;
			
			[self buyRemoveAds];
        }
	}
}


- (void)actionAd:(id)sender
{
    [appDelegate gotoAd];
}

- (void)actionAbout:(id)sender
{
    //side menu
    if(slide)
    {
        [self toggleSlide];
    }
    
    /*int numApps = [appDelegate getNumApps];
    if(numApps > 0)
    {
        [appDelegate setPrefNumApps:numApps];
        [appDelegate saveState];
    }
    */
    
    //hide keyboard
    [self hideKeyboard];

     //back
    //UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];

    [appDelegate performSelector:@selector(pushAbout) withObject:nil afterDelay:0.1];
}

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"ArchivetViewController::actionSheet didDismissWithButtonIndex");
    
/*
All
New
Absurd
Cartoon 
Comic 
Funny 
Game 
Insightful 
Love 
Motivation 
Movie 
Religion 
Science 
Sport 
TV 
*/

    switch (buttonIndex)
    {
         case 0:
            [self forceSearch:@"" withDelay:NO];
            break;
         case 1:
            [self forceSearch:@"Absurd" withDelay:NO];
            break;
         case 2:
            [self forceSearch:@"Cartoon" withDelay:NO];
            break;
         case 3:
            [self forceSearch:@"Comic" withDelay:NO];
            break;
         case 4:
            [self forceSearch:@"Funny" withDelay:NO];
            break;
         case 5:
            [self forceSearch:@"Game" withDelay:NO];
            break;
         case 6:
            [self forceSearch:@"Insightful" withDelay:NO];
            break;
         case 7:
            [self forceSearch:@"Love" withDelay:NO];
            break;
         case 8:
            [self forceSearch:@"Motivation" withDelay:NO];
            break;
         case 9:
            [self forceSearch:@"Movie" withDelay:NO];
            break;
         case 10:
            [self forceSearch:@"Religion" withDelay:NO];
            break;
         case 11:
            [self forceSearch:@"Science" withDelay:NO];
            break;
         case 12:
            [self forceSearch:@"Sport" withDelay:NO];
            break;
         case 13:
            [self forceSearch:@"TV" withDelay:NO];
            break;
		
            
        default:
            break;
    }
    
}

//iap
- (void)inAppAlertAppeared:(id)sender
{
    NSLog(@"ArchiveViewController inAppAlertAppeared");

	doHud = NO;
}

//tethering, in-call
- (void)statusBarWillChangeFrame:(id)sender
{
    NSLog(@"ArchiveViewController statusBarWillChangeFrame");

	[self showAd:YES];
}

/*
- (void)didChangeStatusBarFrame
{
    NSLog(@"ArchiveViewController didChangeStatusBarFrame");
}
 */

- (void)updateBadgeLeft
{
    NSLog(@"ArchiveViewController updateBadgeLeft");
    
    if([appDelegate updateAvailable])
    //if(YES) //forced
    //if(NO) //disabled
    {
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftButtonBadge.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionMenu:)];
        [self.navigationItem setLeftBarButtonItem:button animated:NO];

    }
    else
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionMenu:)];
        [self.navigationItem setLeftBarButtonItem:button animated:NO];
    }
}

- (void)updateBadgeRight
{
    NSLog(@"ArchiveViewController updateBadgeRight");
    
    int numApps = [appDelegate getNumApps];
    NSLog(@"ArchiveViewController: numApps: %d", numApps);
    
    //show num
    if(numApps > 0 && numApps > [appDelegate prefNumApps])
    //if(YES) //force
    //if(NO) //disabled
    {
		// ButtonItem right
        UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,27,23)];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"rightButtonBadge.png"] forState:UIControlStateNormal];
        [rightButton setBackgroundColor:[UIColor clearColor]];
        [rightButton addTarget:self action:@selector(actionAbout:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = buttonItem;
		
    }
    else
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionAbout:)];
        [self.navigationItem setRightBarButtonItem:button animated:NO];
    }
}

- (void)selectImage:(int)index showView:(BOOL)show
{
    [lock1 lock];
    
    if(show)
    {
        [self hideKeyboard];
        
        //back button
        //UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStyleBordered target: nil action: nil];
        //[[[appDelegate firstViewController] navigationItem] setBackBarButtonItem: newBackButton];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
        
        [[appDelegate firstViewController] setReload:YES];
        
         
        //delay, so keyboard can hide
        double delayInSeconds = 0.1f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[appDelegate navController] pushViewController:[appDelegate firstViewController] animated:YES];
        });
    }
    
    [lock1 unlock];

}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    //[self becomeFirstResponder];
	
	currentOrientation = [[UIDevice currentDevice] orientation];
    
    //check online
    [appDelegate setIsOnline:[appDelegate checkOnline]];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(statusBarWillChangeFrame:)
												 //name:UIApplicationWillChangeStatusBarFrameNotification
												 name:UIApplicationDidChangeStatusBarFrameNotification
											   object:nil];
    
    //for in-app confirm
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(inAppAlertAppeared:) 
                                               name:UIApplicationWillResignActiveNotification 
                                             object:nil];


    //iap
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];

    tableViewController.view.hidden = NO;
    
    //force hide, for Default.png
	if([appDelegate isShowDefault])
		tableViewController.view.hidden = YES;
    
    //nav
    [appDelegate navController].navigationBar.translucent = NO;

    //show load
    /* tableView.hidden = NO;
    darkImage.hidden = NO;
    spin.hidden = NO;*/

	//title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"A.C.M.E. Secret Agent" size:20] ;
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text= @"Quote Addict";
    [self navigationItem].titleView = label;
    [self.navigationItem.titleView sizeToFit];  //center

    //notify
	if([appDelegate backgroundSupported])
	{
		[[NSNotificationCenter  defaultCenter] addObserver:self
												  selector:@selector(notifyForeground)
													  name:UIApplicationWillEnterForegroundNotification
													object:nil]; 
	}
    
    
    //reload
    //[appDelegate refresh]; //too often
	
	//offline
	/*if([appDelegate isOnline])
		[self showOffline:NO];
	else
		[self showOffline:YES];
    */
    
    //badge
    [self updateBadgeRight];
	[self updateBadgeLeft];
	
    //CGPoint tempCenter = self.view.center;
    //CGRect tempFrame = self.view.frame;
    //CGRect tempBounds = self.view.bounds;
    	
    //ad
    [self updateBanner:YES];
    
	[self updateUIOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	rotating = NO;
	
	//[self becomeFirstResponder];
    
    //refresh, only after delay?
    //[appDelegate refresh];
    
    //hide test
    //tableView.hidden = YES;
    //tableViewController.view.hidden = YES;
    
    //test
    //[appDelegate alertHelp:YES];
    
    self.tableView.scrollsToTop = NO;
    tableViewController.tableView.scrollsToTop = YES;
	
	//if(false)
    /*if([appDelegate isTapForTap] && ![appDelegate isShowDefault])
    {
        [self showAd:YES];
    }*/
    
    
	//resize
	[self showAd:YES];
	
    [self performSelector:@selector(updateBadgeRight) withObject:nil afterDelay:0.3];
	
	[appDelegate fadeDefault];
    
    //fix double click crash?
    [appDelegate setAlreadySelectImage:NO];
    
    //refresh on favorite modified
    
    if([appDelegate favorites] && [appDelegate favoritesModified])
    {
        [appDelegate setFavoritesModified:NO];
        [appDelegate refresh];
    }
    
    //upate?
    if([appDelegate showUpdate])
    {
        [appDelegate alertUpdate:YES];
		[appDelegate setUpdateAvailable:NO];
    }
	else
	{
		//version database
		[appDelegate updateRemoveDatabaseVersion];
	}

}

- (void)viewWillDisappear:(BOOL)animated {
    
    //hide keyboard
    [self hideKeyboard];


	[self resignFirstResponder];
    
	[super viewWillDisappear:animated];
	
	rotating = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}


- (void)dealloc {
    //[super dealloc];
	    
    ////[HUD removeFromSuperview];
	//[HUD release];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event 
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        [appDelegate refresh];
    }
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"AboutViewController::didRotateFromInterfaceOrientation");
	
    if([appDelegate isIpad])
    {
        rotating = NO;
		
        [self updateUIOrientation];
        
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"AboutViewController::willRotateToInterfaceOrientation");
	
    if([appDelegate isIpad])
    {
        rotating = YES;
		
        [self updateUIOrientation];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {    
    return YES;
}

- (void)forceReSearch
{
    [self forceSearch:[searchBar2 text] withDelay:YES];
}

- (void)forceSearch:(NSString*)string withDelay:(BOOL)delay
{
    NSLog(@"ArchiveViewController::forceSearch");
    
    NSString *newSearchString = string;
    if(newSearchString == nil)
        newSearchString =@"";
    
    newSearchString = [newSearchString lowercaseString];
    if([newSearchString isEqualToString:@"category:all"])
        newSearchString = @"";
    else if([newSearchString isEqualToString:@"category:new"])
        newSearchString = @"category:new";
    
    [searchBar2 setText:newSearchString];
    [self searchBarSearchButtonClicked:self.searchBar2];

    //force scroll
    if(delay)
        [self performSelector:@selector(scrollToTop) withObject:nil afterDelay:(SLIDE_DELAY + 0.1f)];

    else
        [self scrollToTop]; 
}

- (void)scrollToTop
{
    [self.tableViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)toggleSlide
{
    NSLog(@"ArchiveViewController::toggleSlide");

    //to prevent slide while sliding
    if([appDelegate isSliding])
       return;
       
    //slide out view
    
    slide = !slide; //toggle
       
    if(!slide)
    {
        //back to normal
        //[appDelegate window].rootViewController = [appDelegate navController];

    }
    else
    {
        //show menu
     
        //screenshot
        //http://nickharris.wordpress.com/2012/02/05/ios-slide-out-navigation-code/
      
        //UIView *whichView = self.view;
        UIView *whichView = [appDelegate navController].view;
        CGSize viewSize = whichView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();

        //offset for title bar
        //int offset = -STATUS_BAR_HEIGHT;
        int offset = 0;
        CGContextTranslateCTM(context, 0, offset);
        
        [whichView.layer renderInContext:UIGraphicsGetCurrentContext()];

        // Read the UIImage object
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [[appDelegate sideMenuViewController].screenshot setImage:image];
        
        
        [appDelegate window].rootViewController = [appDelegate sideMenuViewController];
    }
    
    //disable input
    [self tableViewController].view.userInteractionEnabled =  !slide;
    
  
    //invisible button
    tableButton.hidden = !slide;
    tableButton.userInteractionEnabled = slide;
  	//[[self view] bringSubviewToFront:tableButton];
      
    float time = 0;
    int len = 0;
	
	if([appDelegate isIpad])
	{
		time = SLIDE_DELAY;

        if([appDelegate isPortrait])
            len = SLIDE_LEN_IPAD_PORTRAIT;
        else
            len = SLIDE_LEN_IPAD_LANDSCAPE;
	}
	else
	{
		time = SLIDE_DELAY;
		len = SLIDE_LEN;
	}
	
	
    if(!slide)
        len *= -1; //other way 

    if(slide)
        [[appDelegate sideMenuViewController] setupShadow:0 withScreen:[appDelegate GetScreenRect]];
    else
         [[appDelegate sideMenuViewController] setupShadow:len withScreen:[appDelegate GetScreenRect] ];

    //start slide
    [appDelegate setIsSliding:YES];
    
    slideX = 0;
    [UIView animateWithDuration:time
                     animations:^{
                         slideX += len;
                         [[appDelegate sideMenuViewController] updateShadow:slideX withScreen:[appDelegate GetScreenRect]];

                     }
     
                     completion:^(BOOL finished){
                         if(finished)
                         {
                             //slideView.hidden = YES;
                             [appDelegate setIsSliding:NO];
                             
                             if(!slide)
                                [appDelegate window].rootViewController = [appDelegate navController];

                         }
                    }
     ];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"searchBar textDidChange");
    //searchString = searchText;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {

    //NSLog(@"searchBarShouldEndEditing");

    //searchBar.showsCancelButton = NO;
    //searchString = searchBar.text;

    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    //NSLog(@"searchBarSearchButtonClicked");

    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    /*NSArray *results = [SomeService doSearch:searchBar.text];
	
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.theTableView.allowsSelection = YES;
    self.theTableView.scrollEnabled = YES;
	
    [self.tableData removeAllObjects];
    [self.tableData addObjectsFromArray:results];
    [self.theTableView reloadData];*/
    
    searchString = searchBar.text;
    oldSearchString = searchString;
    
    //sanitize string
    searchString = [searchString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    searchString = [searchString stringByReplacingOccurrencesOfString:@";" withString:@""];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"%" withString:@""];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"," withString:@""];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"." withString:@""];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"*" withString:@""];
    //searchString = [searchString stringByReplacingOccurrencesOfString:@":" withString:@""];

    [appDelegate searchQuote:searchString];
    [self.tableViewController.tableView reloadData];
    
    if([appDelegate totalItems] == 0)
    {
        //[UIAlertView showError:@"No quotes found. Please try another search." withError@"Error"];
        [self showNoResults:YES];
    }
    else
    {
         [self showNoResults:NO];
    }
        
    //hide keyboard
    [searchBar resignFirstResponder];
    
    //ad
    [self updateBanner:YES];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    NSLog(@"searchBarCancelButtonClicked");
    searchString = @"";
    [appDelegate searchQuote:searchString];
    [self.tableViewController.tableView reloadData];

    [searchBar resignFirstResponder];
    
    //ad
    [self updateBanner:YES];
}

- (void)buyRemoveAds
{
    //disabled
    if([appDelegate isDebug] && ![appDelegate isSimulator])
        return;
    
     //show hud
    doHud = YES;
    [self showHud:@"Connecting"];
    
	SKProduct* product = [appDelegate productRemoveAds];
	
    NSLog(@"Buying %@...", product.productIdentifier);
    [[QuoteAddictIAPHelper sharedInstance] buyProduct:product];
}

- (void)productPurchased:(NSNotification *)notification {
	
    NSString * productIdentifier = notification.object;
    [[appDelegate products] enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {

            *stop = YES;
            doHud = NO;
			[self showAd:NO];
            [appDelegate setPrefPurchasedRemoveAds:YES];
            [appDelegate saveState];
            
            //message
            [UIAlertView showError:@"Thanks for your support!" withTitle:@"In-App Purchases"];
        }
    }];
    
}

/*- (void)restoreRemoveAds
{
    [[QuoteAddictIAPHelper sharedInstance] restoreCompletedTransactions];
    [appDelegate setPrefPurchasedRemoveAds:YES];
    [appDelegate saveState];
    [self showAd:NO];
}
*/


/*
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    // reset the shouldBeginEditing BOOL ivar to YES, but first take its value and use it to return it from the method call
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}*/


- (void)showHud:(NSString*)label
{
	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.labelText = label;
	
	[HUD showWhileExecuting:@selector(hudTask) onTarget:self withObject:nil animated:YES];
}

- (void)hudTask
{
    NSDate *start = [NSDate date];
    NSTimeInterval timeInterval = ABS([start timeIntervalSinceNow]);
    
    //at least min, at most max
    while( (timeInterval < MIN_HUD_TIME) || (doHud && (timeInterval < MAX_HUD_TIME)) )
    {
       timeInterval = ABS([start timeIntervalSinceNow]);
    }
}

-(void) orientationChanged:(NSNotification *) notification
{
	NSLog(@"AboutViewController::orientationChanged");
	
    //if([appDelegate isIpad])
    {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        //Ignoring specific orientations
        if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown
            || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation)
        {
			//return;
        }
		
		
        currentOrientation = orientation;
		
        [self updateUIOrientation];
		
        //[self updateBadge];
    }
}

- (void)updateUIOrientation
{	
    [lock2 lock];
    
    NSLog(@"ConvertViewController::updateUIOrientation");
	
    if([appDelegate isIpad])
    {
		int offset = 2;//4;
        CGRect tempFrame;
		
		//move close button
		tempFrame = closeButton.frame;
        tempFrame.origin.x = adButton.frame.origin.x - closeButton.frame.size.width/2 + offset;
        tempFrame.origin.y = adButton.frame.origin.y - closeButton.frame.size.height/2 + offset;
        closeButton.frame = tempFrame;
        
        //keep updating
        if(rotating)
            [self performSelector:@selector(updateUIOrientation) withObject:nil afterDelay:0.01];
		
    }
    
    [lock2 unlock];
}

- (void)hideKeyboard
{
    //hide keyboard
    [searchBar2 resignFirstResponder];
    searchBar2.text = oldSearchString;
}


#pragma mark -
#pragma mark Banner

- (void)updateBanner:(BOOL)reload {
    
    if(![appDelegate isOnline])
    {
        [self hideAd];
        return;
    }
    
    //ad
    if([appDelegate prefPurchasedRemoveAds])
    {
        [self hideAd];
        return;
    }
    
    //force resize
    if(self.bannerView.hidden) {
        [self hideAd];
    }
    
    GADRequest *request = [GADRequest request];
    // Enable test ads on simulators.
    //request.testDevices = @[ GAD_SIMULATOR_ID ];
    /*request.testDevices = [NSArray arrayWithObjects:
     @"MY_SIMULATOR_IDENTIFIER",
     @"MY_DEVICE_IDENTIFIER",
     nil];*/
    
    self.bannerView.adUnitID = kGoogleAdMobId;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:request];
    
}


- (void)adViewDidReceiveAd:(GADBannerView *)view {
    NSLog(@"adViewDidReceiveAd");
    
    [self showAd:YES];
    
    //self.bannerView.hidden = NO;
    //self.closeAdButton.hidden = YES;
    //self.adSpinner.hidden = YES;
    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    
    NSLog(@"didFailToReceiveAdWithError");
    
    [self showAd:NO];
    
    //self.bannerView.hidden = YES;
    //self.closeAdButton.hidden = YES;
    //self.adSpinner.hidden = YES;
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}


@end

//
//  QuoteAddictAppDelegate.m
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/xattr.h>

#import "QuoteAddictAppDelegate.h"
#import "iRate.h"
#import "iNotify.h"
//#import "SecureUDID.h"
#import "NSString+HTML.h"
//#import "SHK.h"
//#import "SHKConfiguration.h"
//#import "SHKFacebook.h"
//#import "ShareKitDemoConfigurator.h"
#import "UIAlertView+Errors.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
//#import "TapForTap.h"
#import "Quotes.h"
#import "NSData+Base64.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "QuoteAddictIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "AFNetworking.h"
#import "NSMutableArray+Shuffle.h"
//#import "QRTools.h"
#import "NSDate-Utilities.h"

#if USE_TESTFLIGHT
    #import "TestFlight.h"
#endif

@implementation QuoteAddictAppDelegate

@synthesize window;
@synthesize navController;
@synthesize qrImage;
@synthesize showingHelp;
@synthesize prefRated;
@synthesize savedAdImage;
@synthesize savedImage;
@synthesize savedThumbImage;
@synthesize firstViewController;
@synthesize random;
@synthesize popular;
@synthesize isDoneLaunching;
@synthesize isOnline;
@synthesize isLoading;
@synthesize totalItems;
@synthesize archiveViewController;
@synthesize aboutViewController;
@synthesize sideMenuViewController;
@synthesize missingThumb;
@synthesize indexToLoad;
@synthesize cellBackImage1;
@synthesize cellBackImage2;
@synthesize prefRunCount;
@synthesize prefNumApps;
@synthesize currentAdId;
@synthesize prefPlaySound;
@synthesize prefShowAll;
@synthesize prefVersion;
@synthesize prefPurchasedRemoveAds;
@synthesize lastTimeSince70;
@synthesize prefOpened;
@synthesize splash;
@synthesize alreadyFadeDefault;
@synthesize quotes;
@synthesize isSliding;
@synthesize numRows;
@synthesize timeLastRefresh;
@synthesize alreadySelectImage;
@synthesize products;
@synthesize productRemoveAds;
@synthesize favoritesArray;
@synthesize favoritesModified;
@synthesize favorites;
@synthesize showUpdate;
@synthesize currentAdUrl;
@synthesize remoteDatabaseVersion;
@synthesize updateAvailable;
@synthesize showLockscreen;
@synthesize inReview;
@synthesize prefMailchimpCount;
@synthesize prefMailchimpShown;

NSRecursiveLock *lock1;
NSRecursiveLock *lock2;
NSRecursiveLock *lock3;
NSRecursiveLock *lock4;
NSRecursiveLock *lock5;
NSRecursiveLock *lock6;
NSRecursiveLock *lock7;
SystemSoundID audioEffect;


+ (void)initialize
{
 	//configure iRate
	[iRate sharedInstance].appStoreID = 580936901; 
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 3;
	//[iRate sharedInstance].debug = YES; 
    
    //configure iNotify
	[iNotify sharedInstance].notificationsPlistURL = @"http://quoteaddict.com/notifications.plist";
	//[iNotify sharedInstance].debug = YES;
}

-(void) applicationWillEnterForeground:(UIApplication *)application
{
	//notification
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //check online
    //bool wasOnline = isOnline;
    isOnline = [self checkOnline];
    
    /*if(!wasOnline && isOnline)
    {
            [self refresh];
    }
    else if(timeLastRefresh == nil)
    {
            [self refresh];
    }
    else
    {
        //check time background
        #define NUM_MINUTES_TO_REFRESH 60
        int secsToRefresh = 60 * NUM_MINUTES_TO_REFRESH;
        int interval = [[NSDate date] timeIntervalSinceDate:timeLastRefresh];
        if(interval > secsToRefresh)
        {
            [self refresh];
        }
    }*/
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    showingHelp = false;
    random = NO;
    popular = NO;
    isDoneLaunching = NO;
    isOnline = NO;
    alreadyFillTable = NO;
    alreadyFillTable2 = NO;
    emptyTable = NO;
    isLoading = NO;
    isSliding = NO;
    alreadySelectImage = NO;
    favoritesModified = NO;
    favorites = NO;
    showUpdate = NO;
	remoteDatabaseVersion = 0;
	updateAvailable = NO;
    showLockscreen = NO;
    inReview = YES;
    prefMailchimpCount = 0;
    prefMailchimpShown = YES;
    
    numAppsDownloaded = NO;
    numApps = 0;

    totalItems = 0;
    numRows = 0;
    
    prefPurchasedRemoveAds = NO;
    prefPlaySound = NO;
    prefShowAll = YES;
    prefVersion = [NSString stringWithFormat:@""];
    lastTimeSince70 = 0;
    prefRunCount = 0;
    prefNumApps = 0;
    timeLastRefresh = nil;
    currentAdId = 0;
    currentAdUrl = @"";
    adArray = nil;

    self.buttonTextColor = RGBA(36,36,36, 255);//[UIColor darkGrayColor];

    //crash
    [Fabric with:@[[Crashlytics class]]];

    //random
    srand(time(NULL));
    
    lock1 = [[NSRecursiveLock alloc] init];
    lock2 = [[NSRecursiveLock alloc] init];
    lock3 = [[NSRecursiveLock alloc] init];
    lock4 = [[NSRecursiveLock alloc] init];
    lock5 = [[NSRecursiveLock alloc] init];
    lock6 = [[NSRecursiveLock alloc] init];
    lock7 = [[NSRecursiveLock alloc] init];
    
     //data

    indexToLoad = 0;

    favoritesArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    savedAdImage = nil;
	
    //db
    [self copyBundleDatabase:NO];
    [self searchQuote:@""];

	//qr
    qrImage = nil;
    NSString *qrString = @"http://itunes.apple.com/app/id580936901"; //daily
    qrImage = [self generateQRCodeWithString:qrString scale:1.0f];
    
    //qrImage = [QRTools qrFromString:qrString withSize:500];
    
    //[qrImage retain];

	//notification
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        [self processNotification:localNotif];
    }

    [self setupNotifications];

    //ios7 tint color
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
        //window.tintColor = RGBA(121, 95, 54, 255);
        window.tintColor = RGBA(101,86,64, 255);

    //load
    [self loadState];
    
    prefRunCount++;
	if(prefRunCount >= 10000)
		prefRunCount= 10000;

    //sharekit setup
    /*DefaultSHKConfigurator *configurator = [[ShareKitDemoConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    [SHK flushOfflineQueue]; //offline
     */
    
    //manually create controller
    //archiveViewController = [ArchiveViewController alloc];
    firstViewController = [[FirstViewController alloc] initWithNibName:@"FirstView" bundle:nil];
    aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
	sideMenuViewController = [SideMenuViewController alloc];
    
    //force load
    //archiveViewController.view.hidden = NO;
    //modalHelp = [[HelpViewController alloc] initWithNibName:@"HelpView" bundle:nil];
    sideMenuViewController.view.hidden = NO;

    //force
    firstViewController.view.hidden = NO;
    archiveViewController.view.hidden = NO;
	aboutViewController.view.hidden = NO;

    //offset sidemenu view
    int offsetx = 0; //20;
    int offsety = 0; //STATUS_BAR_HEIGHT;//-320;
    sideMenuViewController.view.frame = CGRectMake(offsetx, offsety, sideMenuViewController.view.frame.size.width,
                                               sideMenuViewController.view.frame.size.height);  
    
    offsetx = 0;
    offsety = 0;//-STATUS_BAR_HEIGHT;
    navController.view.frame = CGRectMake(offsetx, offsety, navController.view.frame.size.width,
                                               navController.view.frame.size.height);
    
    //cell back
    cellBackImage1 =[UIImage imageNamed:@"cell_back.png"];
    cellBackImage2 =[UIImage imageNamed:@"cell_back2.png"];

    //missing
    missingThumb = [UIImage imageNamed:@"thumbMissing.png"];

    //nav bar
    //color
    //http://cocoadevblog.heroku.com/uinavigationcontroller-customization-tutorial
    //self.navController.navigationBar.tintColor = RGBA(18, 64, 63, 255);  //turcoise
    
    //test
    self.navController.navigationBar.tintColor = RGBA(213,203,186, 255);  //brown
    
    //bar
    self.navController.navigationBar.barTintColor = RGBA(101,86,64, 255);  //brown
    //self.navController.navigationBar.barTintColor = RGBA(121, 95, 54, 255);  //brown
    
    self.navController.navigationBar.translucent = NO;
    self.navController.navigationBarHidden = NO; //hide
    [self.navController setNavigationBarHidden:NO animated:NO];
    

    BOOL cache = YES;
    if(cache)
    {
        //cache, caching
        //1024*1024*10 = 10 MB
        int cacheSizeMemory = 4*1024*1024; // 4MB
        int cacheSizeDisk = 32*1024*1024; // 32MB
        //[[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*4]; //4mb
        //[[NSURLCache sharedURLCache] setDiskCapacity:1024*1024*32]; //32mb
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
        //fix leak?
        //[[NSURLCache sharedURLCache] setMemoryCapacity:0];
        //[[NSURLCache sharedURLCache] setDiskCapacity:0];
    }
    else
    {
        //force delete cache
        int cacheSizeMemory = 0;
        int cacheSizeDisk = 0;
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
    }
    
    //title: On iPad devices, the UIStatusBarStyleDefault and UIStatusBarStyleBlackTranslucent styles default to the UIStatusBarStyleBlackOpaque appearance.
    
	//if(isIpad())
    //if([self isIpad])
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //else
    /*{
        if(SYSTEM_VERSION_LESS_THAN(@"7"))
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        }
        else
        {
            //UIStatusBarStyleDefault,UIStatusBarStyleLightContent
        }
    }
    */
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
    
    missingThumb = [UIImage imageNamed:@"thumbMissing.png"];

    
    //analytics
    
    if(USE_ANALYTICS == 1)
	{
		// NSLog(@"USE_ANALYTICS == 1");
		//events:
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"INTERESTING_EVENT"];
		//http://wiki.localytics.com/doku.php?id=iphone_integration
		
		//[[LocalyticsSession sharedLocalyticsSession] startSession:@"???"];
        
        
        //[FlurryAnalytics startSession:@"???"];
		
	}
	else
	{
		NSLog(@"USE_ANALYTICS == 0");
	}
    
    
    //testflight
#if USE_TESTFLIGHT
    if([self isTestflight])
	{
        [TestFlight takeOff:@"???"];
    }
#endif
    
     //inits
    [Helpers initGoogleAnalytics];
    [Helpers initMailChimp:self];

    //modals
    modalHelp = [[WelcomeViewController alloc] initWithNibName:@"WelcomeView" bundle:nil];
    modalQR = [[QRViewController alloc] initWithNibName:@"QRView" bundle:nil];
    modalUpdate = [[UpdateViewController alloc] initWithNibName:@"UpdateView" bundle:nil];

    //ready
    isDoneLaunching = YES;
    isOnline = [self checkOnline];
   
	
    //[window makeKeyAndVisible];
    
    //IAP
	[self loadIAP];
        
    //badge
    [self updateNumAppsBadge];
    
    //lockscsreen
    [self updateInReview];

    //push
    [self initPushNotifications];
   
    //save
    [self saveState];
    
    window.rootViewController = navController;
   

    //window
    [window makeKeyAndVisible];

    
    if(prefOpened == NO) //1st time only
    {
         //force wait, for sheet anim
        //[NSThread sleepForTimeInterval:0.3];
        //[self alertHelp:YES];
        [self performSelector:@selector(alertHelpFirstTime) withObject:nil afterDelay:0.1];
    }

    //color
	//if([self isDebug])
    //    [window setBackgroundColor:[UIColor blueColor]];
    //else
        [window setBackgroundColor:[UIColor blackColor]];

    //tapfortap
    //[TapForTap initializeWithAPIKey: @"???"];

	[self fadeDefaultSetup];
	
    //mailchimp
    [Helpers shouldShowMailChimp];

	//version database
	//[self updateRemoveDatabaseVersion];
    
    return YES;
}



/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

/*- (void)setRootMenu;
{
    window.rootViewController = sideMenuViewController;
}

- (void)setRootNormal
{
    window.rootViewController = navController;
}*/


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"applicationDidReceiveMemoryWarning");

    //empty cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //clear thumbs, nope
    //[imageThumbArray removeAllObjects];
    
    //clear image
    savedImage = nil;
}

-(void)addNavigationController:(UINavigationController*)nav
{
    [window addSubview:nav.view];
}

- (void)saveStateDefault
{
    NSLog(@"QuoteAddictAppDelegate::saveStateDefault");
    
    //nothing yet
}

- (void)saveState
{
    NSLog(@"QuoteAddictAppDelegate::saveState");
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
  	[prefs setBool:prefPlaySound forKey:@"prefPlaySound"];
    [prefs setBool:prefPurchasedRemoveAds forKey:@"prefPurchasedRemoveAds"];
    [prefs setBool:prefShowAll forKey:@"prefShowAll"];

    prefVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [prefs setObject:prefVersion forKey:@"prefVersion"];
                       
    if(lastTimeSince70 == 0)
        lastTimeSince70 = [[NSDate date] timeIntervalSince1970];
    
    [prefs setDouble:lastTimeSince70 forKey:@"lastTimeSince70"];
                         
    [prefs setInteger:prefRunCount forKey:@"prefRunCount"];
    [prefs setInteger:prefNumApps forKey:@"prefNumApps"];
    [prefs setInteger:currentAdId forKey:@"currentAdId"];
  
    [prefs setInteger:prefMailchimpCount forKey:@"prefMailchimpCount"];
    [prefs setBool:prefMailchimpShown forKey:@"prefMailchimpShown"];

  	[prefs setBool:prefOpened forKey:@"prefOpened"];

     //favorites
    [prefs setObject:favoritesArray forKey:@"favoritesArray"];


    [prefs synchronize];
}

- (void)loadState
{
    NSLog(@"QuoteAddictAppDelegate::loadState");
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
    //set defaults
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 
                                 [NSNumber numberWithBool:NO], @"prefOpened",
                                 [NSNumber numberWithBool:YES], @"prefPlaySound",
                                 [NSNumber numberWithBool:NO], @"prefPurchasedRemoveAds",
                                 [NSNumber numberWithBool:YES], @"prefShowAll",
                                 [NSString stringWithFormat:@""], @"prefVersion",
                                 [NSNumber numberWithDouble:0], @"lastTimeSince70",
                                 [NSNumber numberWithDouble:0], @"prefRunCount",
                                 [NSNumber numberWithDouble:0], @"prefNumApps",
                                 [NSNumber numberWithDouble:APP_ID_QRLOCK], @"currentAdId",
                                 [NSNumber numberWithDouble:0], @"prefMailchimpCount",
                                 [NSNumber numberWithBool:NO], @"prefMailchimpShown",

                                 nil];
                                 
    [prefs registerDefaults:appDefaults];
    
    prefPurchasedRemoveAds = [prefs boolForKey:@"prefPurchasedRemoveAds"];
  	prefOpened = [prefs boolForKey:@"prefOpened"];
    prefPlaySound = [prefs boolForKey:@"prefPlaySound"];
    prefShowAll = YES; //[prefs boolForKey:@"prefShowAll"];
    lastTimeSince70 = [prefs doubleForKey:@"lastTimeSince70"];
    prefVersion = [prefs stringForKey:@"prefVersion"];
    prefRunCount = [prefs integerForKey:@"prefRunCount"];
    prefNumApps = [prefs integerForKey:@"prefNumApps"];
    currentAdId = [prefs integerForKey:@"currentAdId"];
    prefMailchimpCount = [prefs integerForKey:@"prefMailchimpCount"];
    prefMailchimpShown = [prefs boolForKey:@"prefMailchimpShown"];
    
    //favorites
    favoritesArray = [[prefs objectForKey:@"favoritesArray"] mutableCopy];
    if (!favoritesArray)
    {
        // create array if it doesn't exist in NSUserDefaults
        favoritesArray = [[NSMutableArray alloc] init];
    }
}

- (void)facebookLogin
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharerAuthorized:) name:@"SHKAuthDidFinish" object:nil];

     //login
   // SHKSharer *service = [[SHKFacebook alloc] init];
   // [service authorize];
}

- (void)sharerAuthorized:(NSNotification *)notification {

     NSLog(@"AppDelegate::sharerAuthorized");
}

- (BOOL)handleOpenURL:(NSURL*)url
{
     NSLog(@"AppDelegate::handleOpenURL");

	NSString* scheme = [url scheme];
    //if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]])
    //    return [SHKFacebook handleOpenURL:url];
    
    //return [facebook handleOpenURL:url]; 
    
    return YES;
}

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url 
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation 
{
     NSLog(@"AppDelegate::openURL");

    return [self handleOpenURL:url];
    
    //return YES;
}

- (BOOL)application:(UIApplication *)application 
      handleOpenURL:(NSURL *)url
{
     NSLog(@"AppDelegate::handleOpenURL");

    return [self handleOpenURL:url];  
}


- (void)dealloc {
    //[window release];
    //[super dealloc];
}

-(void) playSound:(NSString*)filename
{   
	if(!prefPlaySound)
		return;
    
    //invalid filename
    if( (filename == nil) || ([filename length] <= 0 ) || [filename isEqualToString:@""])
        return;
	
    //http://www.iphonedevsdk.com/forum/iphone-sdk-development/2940-help-please-playing-short-sound-tutorial-not-working.html
    //http://blogs.x2line.com/al/archive/2011/05/19/3831.aspx
    //http://iphone-dev-tips.alterplay.com/2009/12/shortest-way-to-play-sound-effect-on.html
    //http://stackoverflow.com/questions/818515/iphone-how-to-make-key-click-sound-for-custom-keypad
    
    
    
    NSString *path  = [[NSBundle mainBundle] pathForResource : filename ofType :@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        //AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &audioEffect);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);

        AudioServicesPlaySystemSound(audioEffect);
    }
    else
    {
        NSLog(@"error, file not found: %@", path);
    }
    
    
}


-(void) testFlightFeedback
{
#if USE_TESTFLIGHT
    if([self isTestflight])
	{
      [TestFlight openFeedbackView];
    }
#endif
}


-(void) applicationDidEnterBackground:(UIApplication *)application
{
   /* alreadyLoaded = false;
    
	//going to background
    
    if(!prefRemember)
    {
		keyString = @"";
	}
    
	[self saveState];
	
	
	if(USE_ANALYTICS == 1)
	{
		// Close Localytics Session
		[[LocalyticsSession sharedLocalyticsSession] close];
		[[LocalyticsSession sharedLocalyticsSession] upload];
	}*/
	
	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self applicationDidEnterBackground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[self applicationWillEnterForeground:application];
    
     //notifications
    [self setupNotifications];

}

-(BOOL)backgroundSupported
{
	UIDevice* device = [UIDevice currentDevice];
	BOOL tempBackgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		tempBackgroundSupported = device.multitaskingSupported;
	
	return tempBackgroundSupported;
}

//https://gist.github.com/1323251
- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    
	if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";

    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (CDMA)";

    //ipad 4
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    
    //ipad mini
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini (Wifi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad mini";

    //sim
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}


- (BOOL) isIpad
{
//#ifdef UI_USER_INTERFACE_IDIOM
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
//#else
//	return NO;
//#endif
}

- (BOOL) isIphone5
{
   if ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
    {
      // iphone 5
      return YES;
    }
    else 
    {
        return NO;
    }
}

-(UIImage*) getQRImage
{
    assert(qrImage);
    return qrImage;
}



- (UIImage*) createMaskWithImage: (UIImage*) inputImage
{
    CGImageRef image = inputImage.CGImage;
    
    int maskWidth               = CGImageGetWidth(image);
    int maskHeight              = CGImageGetHeight(image);
    //  round bytesPerRow to the nearest 16 bytes, for performance's sake
    int bytesPerRow             = (maskWidth + 15) & 0xfffffff0;
    int bufferSize              = bytesPerRow * maskHeight;
    
    //  allocate memory for the bits 
    CFMutableDataRef dataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(dataBuffer, bufferSize);
    
    //  the data will be 8 bits per pixel, no alpha
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx            = CGBitmapContextCreate(CFDataGetMutableBytePtr(dataBuffer),
                                                        maskWidth, maskHeight,
                                                        8, bytesPerRow, colourSpace, kCGImageAlphaNone);
    //  drawing into this context will draw into the dataBuffer.
    CGContextDrawImage(ctx, CGRectMake(0, 0, maskWidth, maskHeight), image);
    CGContextRelease(ctx);
    
    //  now make a mask from the data.
    CGDataProviderRef dataProvider  = CGDataProviderCreateWithCFData(dataBuffer);
    CGImageRef mask                 = CGImageMaskCreate(maskWidth, maskHeight, 8, 8, bytesPerRow,
                                                        dataProvider, NULL, FALSE);
    
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colourSpace);
    CFRelease(dataBuffer);
    
    UIImage *returnImage = [UIImage imageWithCGImage:mask];
    CGImageRelease(mask);
    return returnImage;

}


- (UIImage*) maskImage:(UIImage *)inputImage withMask:(UIImage *)inputMaskImage {
    
	//return inputImage;
    
    //http://stackoverflow.com/questions/2776747/masking-a-uiimage
    
    /*
     CGImageRef maskRef = inputMaskImage.CGImage; 
     
     CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
     CGImageGetHeight(maskRef),
     CGImageGetBitsPerComponent(maskRef),
     CGImageGetBitsPerPixel(maskRef),
     CGImageGetBytesPerRow(maskRef),
     CGImageGetDataProvider(maskRef), NULL, false);
     
     CGImageRef masked = CGImageCreateWithMask([inputImage CGImage], mask);
     CGImageRelease(mask);
     
     UIImage *maskedImage = [UIImage imageWithCGImage:masked];
     
     return maskedImage;*/
    
    
    
    //http://stackoverflow.com/questions/1133248/any-idea-why-this-image-masking-code-does-not-work
    
    CGImageRef masked = CGImageCreateWithMask([inputImage CGImage], [[self createMaskWithImage: inputMaskImage] CGImage]);
    
    UIImage *returnImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return returnImage;
    
}


-(UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    /*CGImageRef rawImageRef=image.CGImage;
    
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0); 
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();    
    return result;*/
    
}


-(UIImage *)colorizeImage: (UIImage *)image
{
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(image.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    //UIColor *color = RGBA(94, 94, 94, 255); //grey
    UIColor *color = RGBA(106, 74, 5, 25); //brown

    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    //CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    /*
     
     kCGBlendModeNormal,
     kCGBlendModeMultiply,
     kCGBlendModeScreen,
     kCGBlendModeOverlay,
     kCGBlendModeDarken,
     kCGBlendModeLighten,
     kCGBlendModeColorDodge,
     kCGBlendModeColorBurn,
     kCGBlendModeSoftLight,
     kCGBlendModeHardLight,
     kCGBlendModeDifference,
     kCGBlendModeExclusion,
     kCGBlendModeHue,
     kCGBlendModeSaturation,
     kCGBlendModeColor,
     kCGBlendModeLuminosity,
     
     */
    
    
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return coloredImg;
}

- (void) mailComposeController:(MFMailComposeViewController*)controller
		   didFinishWithResult:(MFMailComposeResult)result
						 error:(NSError*)error
{
	if(result == MFMailComposeResultSent)
	{
		NSLog(@"mail sent");
	}
		
	//[tabBarController dismissViewControllerAnimated:YES completion:nil];
	[controller dismissViewControllerAnimated:YES completion:nil];

}

- (void)sendEmailTo:(NSString *)to withSubject:(NSString *)subject withBody:(NSString *)body withView:(UIViewController*)theView
{
    
    //todo: test if mail account
    if (![MFMailComposeViewController canSendMail])
    {
        return;
    }

        
	//old way
	
	/*
	 NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
	 [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
	 [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
	 [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	 
	 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
	 */
	
	//new way 
	
	NSArray *recipients = [[NSArray alloc] initWithObjects:to, nil];
	NSArray *recipientEmpty = [[NSArray alloc] init];
	
	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:subject];
	[controller setMessageBody:body isHTML:NO];
	
    //color
    //[[controller navigationBar] setTintColor:[UIColor blackColor]];
	//disabled
	//[[controller navigationBar] setTintColor:self.navController.navigationBar.tintColor];
    
    //disabled
	//[[controller navigationBar] setBarTintColor:self.navController.navigationBar.tintColor];
    
	if([to  length] == 0)
		[controller setToRecipients: recipientEmpty];
	else
		[controller setToRecipients: recipients];
	
    [ theView presentViewController:controller animated:YES completion:NULL];
    
	//[controller release];
	
	//[recipients release];
	//[recipientEmpty release];
	
}

- (void)alertHelpFirstTime
{
    [self alertHelp:YES];
}

- (void)alertHelp:(BOOL)isAnimated
{
    //disabled
    return;
    
		if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"alertHelp"];
        //[FlurryAnalytics logEvent:@"alertHelp"];
        
	}
	   
	[[self navController] presentViewController:modalHelp animated:isAnimated completion:NULL];
}


- (void)alertQR:(BOOL)isAnimated
{
	
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"alerQR"];
        //[FlurryAnalytics logEvent:@"alerQR"];
        
	}
	[[self navController] presentViewController:modalQR animated:isAnimated completion:NULL];
}

- (void)alertUpdate:(BOOL)isAnimated
{
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"alertUpdate"];
        //[FlurryAnalytics logEvent:@"alerQR"];
	}
    
	[[self navController] presentViewController:modalUpdate animated:isAnimated completion:NULL];
}

- (void)alertUpdateDone:(BOOL)fromThread
{
    if(fromThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[NSThread sleepForTimeInterval:1.0];
            
            [ [self navController] dismissViewControllerAnimated:YES completion:nil];

        });
    }
    else
        [ [self navController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertHelpDone
{
	[ [self navController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertHelpDoneFirstTime
{
	[ [self navController] dismissViewControllerAnimated:NO completion:nil];
}



- (void)alertHelpDoneNotAnimated
{
	[ [self navController] dismissViewControllerAnimated:NO completion:nil];
}


- (void)gotoTwitter
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/BingWallpapers"]];
}

- (void)gotoQRScannerApp
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/en/app/scan/id411206394?mt=8"]];
}

- (void)gotoFacebook
{
	
	/*
     
	 <a href="http://www.facebook.com/pages/Password-Grid/169115183113120"  target='_blank'>Facebook</a>
	 
	 <iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.facebook.com%2Fpages%2FPassword-Grid%2F169115183113120&amp;layout=button_count&amp;show_faces=true&amp;width=450&amp;action=like&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:100px; height:21px;" allowTransparency="true"></iframe>
     
	 
	 
     */
	
	//fb://profile/BingWallpapers
	//fb://profile/210227459693
	
	//NSURL *fanPageURL = [NSURL URLWithString:@"fb://BingWallpapers"];
	
	//if(true)
	//if (![[UIApplication sharedApplication] openURL: fanPageURL]) 
	{
        //fanPageURL failed to open.  Open the website in Safari instead
        //NSURL *webURL = [NSURL URLWithString:@"http://www.facebook.com/pages/Password-Grid/169115183113120"];
		
		NSURL *webURL = [NSURL URLWithString:@"http://www.facebook.com/BingWallpapers"];
        [[UIApplication sharedApplication] openURL: webURL];
	}
	
    
}

- (void)gotoAd
{
    if(currentAdUrl == nil || [currentAdUrl length] <= 0)
        return;

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentAdUrl]];
}

- (void)gotoGift
{
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gotoGift"];
	}
	
	[self saveState];
	
	
    //http://stackoverflow.com/questions/5197035/gift-app-from-inside-the-app
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=580936901&productType=C&pricingParameter=STDQ"]];
}

- (void)gotoReviews
{
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gotoReviews"];
        //[FlurryAnalytics logEvent:@"gotoReviews"];
        
	}
	
    /*NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
     str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str]; 
     str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
     
     // Here is the app id from itunesconnect
     str = [NSString stringWithFormat:@"%@289382458", str]; 
     
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
     */
	
	//prefRated = YES;
	//[self saveState];
	
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=580936901&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"]];
	
}

- (BOOL) isDebug
{
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

- (BOOL) isSimulator
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}


- (BOOL) isPortrait
{
    if(![self isIpad])
        return YES;
    
    BOOL value = NO;
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];  

    /*UIDeviceOrientationUnknown,
    UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    UIDeviceOrientationFaceUp,              // Device oriented flat, face up
    UIDeviceOrientationFaceDown             // Device oriented flat, face down
    */


    if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
            value = YES;
    else
            value = NO;
    
    return value;
}

- (BOOL) isRetina
{
   if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) 
    {
      // Retina display
      return YES;
    }
    else 
    {
        return NO;
    }
}

- (BOOL) isTestflight
{
    //#ifdef DEBUG
    //    return NO;
    //#endif

    #if USE_TESTFLIGHT
        //return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        //http://en.wikipedia.org/wiki/IOS_version_history
        //return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.3"); //to confirm?
        return true;
    #else
        return NO;
    #endif    
}

- (NSString *) getSecureID
{
   /* NSString *domain     = @"com.skyriser.bingwallpapers";
    NSString *key        = @"89rkgdfuiigudfkj";
    NSString *identifier = [SecureUDID UDIDForDomain:domain usingKey:key];
    // The returned identifier is a 36 character (128 byte + 4 dashes) string that is unique for that domain, key, and device tuple
    
    return identifier;*/
    
    return @"?";
}

- (NSString*) getUserAgent
{
    //append version
    NSString *agent = [NSString stringWithFormat:@"BingWallpapers-iOS-%@", [self getVersionString2]];
    return agent; 
}

- (NSString*)getVersionString
{
    NSString *debugString = [NSString stringWithFormat:@"%@", [self isDebug]?@" (debug)":@""]; //add debug string
    NSString *output = [NSString stringWithFormat:@"%@%@",
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], debugString];
	//NSLog(@"%@", [NSString stringWithFormat:@"getVersionString: %@", getVersionString2);
	
	return output;
}
- (NSString*)getVersionString2
{
    NSString *debugString = [NSString stringWithFormat:@"%@", [self isDebug]?@" (debug)":@""]; //add debug string
	NSString *output = [NSString stringWithFormat:@"%@ (%@)%@",
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ,
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
						debugString];
    
	//NSLog(@"%@", [NSString stringWithFormat:@"getVersionString2: %@", getVersionString2);
	
	return output;
}


-(void) updateAd
{
    NSLog(@"QuoteAddictiPhoneAppDelegate::updateAd");

    //disable
    return;
    

    if(![self isOnline])
        return;
    
    savedAdImage = nil;

    
        
    //get list
    NSURL * url_afn = [NSURL URLWithString:URL_API_AD_LIST];
    NSURLRequest *request_afn = [[NSURLRequest alloc] initWithURL:url_afn];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
       AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request_afn
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            //save it
            adArray = JSON;
            [self updateAd2];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            adArray = nil;
            NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            //timed out
        }];
    [operation start];
}

-(void) updateAd2
{
    if(adArray == nil || [adArray count] == 0)
        return;
    
    NSMutableArray *ad_array_id = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *ad_array_url_appstore = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *ad_array_url_image = [[NSMutableArray alloc] initWithObjects:nil];
    
    for(NSDictionary *dict in adArray)
    {
        NSString *tempString = nil;
        NSNumber *tempNum = nil;
        
        tempNum = [NSNumber numberWithInt:[[dict objectForKey:@"app_id"] integerValue]];
        [ad_array_id addObject:tempNum];
        
        tempString = [dict objectForKey:@"url_appstore"];
        [ad_array_url_appstore addObject:tempString];
        
        tempString = [dict objectForKey:@"url_image"];
        [ad_array_url_image addObject:tempString];
        
    }
    
    //next
    currentAdId++;
    
    //loop
    if(currentAdId >= [ad_array_id count])
        currentAdId = 0;

    if([ad_array_id[currentAdId] intValue] == APP_ID_CURRENT)
        currentAdId++;
    
    //loop again
    if(currentAdId >= [ad_array_id count])
        currentAdId = 0;
    
    currentAdUrl = ad_array_url_appstore[currentAdId];
    
    [self saveState];

    //connection
    NSString  *url = ad_array_url_image[currentAdId];
    //NSURL * imageURL = [NSURL URLWithString:url];
    NSLog(@"url:%@", url);
         
    //savedAdImage = nil;
    AFImageRequestOperation *operationImage =
            [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
            success:^(UIImage *image)
            {
                savedAdImage = image;
                if(savedAdImage != nil)
                    [archiveViewController showAd:YES];
                else
                    [archiveViewController showAd:NO];
            }
           ];
    
     [operationImage setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            //timed out
        }];
    [operationImage start];

    //[[UIApplication sharedApplication] endBackgroundTask:taskId];
}


- (BOOL)openURL:(NSURL*)url
{
    //BrowserViewController *bvc = [[BrowserViewController alloc] initWithUrls:url];
    //[self.navigationController pushViewController:bvc animated:YES];
   // [bvc release];
    
    //force wait, for sheet anim
    [NSThread sleepForTimeInterval:0.3];


    [[UIApplication sharedApplication] openURL:url];
    
    //[super openURL:url];
    
    //[[UIApplication sharedApplication] canOpenURL:
    //[NSURL URLWithString:@"googlechrome://"]];


    return YES;
}


//BOOL HasConnection()
- (BOOL)HasConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) 
    {
        //offline
        //NSLog(@"QuoteAddictAppDelegate::HasConnection: no");

        return false;
    }
    //else if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN)
    else
    {
       //online
       //NSLog(@"QuoteAddictAppDelegate::HasConnection: yes");

        return true;
    }
}


- (BOOL) checkOnline
{
   [lock5 lock];
    
    //forced
    //return true;

    //not ready yet
    //if(![self isDoneLaunching])
     //   return NO;
    
    BOOL tempOnline = YES;
    

    if(![self HasConnection])
        tempOnline = NO;
    
        return tempOnline;
    
    [lock5 unlock];
}

- (void)selectImage:(int)index showView:(BOOL)show
{
    NSLog(@"QuoteAddictAppDelegate::selectImage: %d", index);

    if(show)
    {
        if(alreadySelectImage)
            return;

        alreadySelectImage = YES;
        
        indexToLoad = index;
        
        //save thumb
        [archiveViewController selectImage:index showView:show];
    }
}


- (void)refresh 
{
    NSLog(@"%@", @"QuoteAddictAppDelegate::refresh");
    
     //not ready yet
    if(![self isDoneLaunching])
        return;

    //hide show results
    [archiveViewController showNoResults:NO];
       
    //[self fillTable];
    
    //[[archiveViewController tableViewController]  startLoading];
    //[[archiveViewController tableViewController].tableView reloadData];
    [archiveViewController forceReSearch];
    
    //timestamp last refresh
    if([self checkOnline])
        timeLastRefresh = [NSDate date];

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    //white background
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, newSize.width, newSize.height));

    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}


-(void)cornerView:(UIView*)inView
{
    //disabled
    return;
    
    float radius = 0.0f;
    if([self isIpad])
        radius = 5.0f;
    else
        radius = 5.0f;
    
    inView.layer.backgroundColor = [UIColor blackColor].CGColor;
    [inView.layer setMasksToBounds:YES];
    [inView.layer setCornerRadius:radius]; //5.0f or 8.0f?
    //inView.clipsToBounds = YES;
    //inView.layer.masksToBounds = YES;
}

/*- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    //[[appDelegate navController] setNavigationBarHidden:YES animated:YES];

    return YES;
}*/


-(void)copyImageToClipboard:(UIImage*)inImage
{
    if(inImage != nil)
        [UIPasteboard generalPasteboard].image = inImage;
}


-(void)updateNumAppsBadge
{
    [archiveViewController updateBadgeRight];
}

-(void)hideNumAppsBadge
{
    //int tabIndex = 1;
    //[[ [tabBarController tabBar].items objectAtIndex:tabIndex] setBadgeValue:nil];
    
    //save
    if(numApps > prefNumApps)
    {
        prefNumApps = numApps;
        [self saveState];
    }
}

-(int)getNumApps
{
    if(![self HasConnection])
    {
        numApps = 0;
    }
    else
    {
        if(!numAppsDownloaded) //not yet updated
        {
            NSURL *datasourceURL = [NSURL URLWithString:URL_API_NUM_APPS];
            NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject){
            
                //convert data to string, then string to int
                NSData* data =  [operation responseData];
                NSString* responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                numApps = [responseString intValue];
                numApps--; //dont count myself
                if(numApps < 0)
                    numApps = 0;
                else if(numApps > 99)
                    numApps = 99;
                
                numAppsDownloaded = YES;
                [self updateNumAppsBadge];

                
            }failure:^(AFHTTPRequestOperation* operation, NSError* error){
                numAppsDownloaded = NO;
                numApps = 0;
            }];
        
            [operation start];
            
            return 0;
        }
    }
    
    return numApps;
}


- (void)pushAbout
{
    if(aboutViewController)
    {
        if(![self.navController.topViewController isKindOfClass:[aboutViewController class]])
        {
            [self.navController pushViewController:aboutViewController animated:YES];
        }
    }
    
    /*if(aboutViewController)
    {
        @try {
            [self.navController pushViewController:aboutViewController animated:YES];
        }
        @catch (NSException * ex) {
            //“Pushing the same view controller instance more than once is not supported” 
            //NSInvalidArgumentException
            NSLog(@"Exception: [%@]:%@",[ex  class], ex );
            NSLog(@"ex.name:'%@'", ex.name);
            NSLog(@"ex.reason:'%@'", ex.reason);
            //Full error includes class pointer address so only care if it starts with this error
            NSRange range = [ex.reason rangeOfString:@"Pushing the same view controller instance more than once is not supported"];

            if([ex.name isEqualToString:@"NSInvalidArgumentException"] &&
               range.location != NSNotFound)
            {
                //view controller already exists in the stack - just pop back to it
                [self.navController popToViewController:aboutViewController animated:NO];
            }else{
                NSLog(@"ERROR:UNHANDLED EXCEPTION TYPE:%@", ex);
            }
        }
        @finally
        {
            //NSLog(@"finally");
        }
    }
    else
    {
        NSLog(@"ERROR:pushViewController: viewController is nil");
    }*/
}


- (BOOL) isShowDefault
{
	//YES, force hide, for Default.png
	return NO;
}

- (BOOL) isTapForTap
{
    BOOL value = NO;
    //value =  prefTap && ![self isIpad]; //iphone only, no ipad
    //value =  prefTap && ![self isIpad]; //iphone only, no ipad
    
    //value =  prefTap; //all
    
    return value;
 }

- (NSString*) getStringFromURL:(NSString*)url
{    
    NSURL *viewURL = [NSURL URLWithString:url];
    NSString* outStr = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:viewURL] encoding:NSASCIIStringEncoding];
    return outStr;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if([self isIpad])
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
    if([self isIpad])
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
    if([self isIpad])
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

- (void)fadeDefaultSetup
{
    //return;
    
    /*if([self isIpad])
    {
        if([self isPortrait])
        {
            splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-Portrait" ofType:@"png"]]];
        }
        else
        {
            splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-Landscape" ofType:@"png"]]];            
        }
        
        //offset
        CGRect tempFrame = splash.frame;
        tempFrame.origin.y += STATUS_BAR_HEIGHT;
        splash.frame = tempFrame;
    }    
    else if([self isIphone5])
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-568h@2x" ofType:@"png"]]];
    else
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]]];
    */
    
    if([self isIpad])
    {
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-Portrait" ofType:@"png"]]];
        //CGRect tempRect = splash.frame;
        //tempRect.origin.y = STATUS_BAR_HEIGHT;
        //splash.frame = tempRect;
    }
    else if([self isIphone5])
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-568h@2x" ofType:@"png"]]];
    else if([self isRetina])
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default@2x" ofType:@"png"]]];
    else
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]]];


	splash.alpha = 1.0f;
	splash.hidden = NO;
	[self.window addSubview:splash];
	[[self window] bringSubviewToFront:splash];
}

- (void)fadeDefault
{
	if(alreadyFadeDefault)
		return;
    
    if(splash == nil)
        return;
	
	alreadyFadeDefault = YES;
	
	//wait?
    //force wait, show default longer, ugly but good enough for now
    //[NSThread sleepForTimeInterval:0.2];
	
    //fade
    if(true)
    {
        //iphone
        //UIImageView *splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
		/*if(splash == nil)
		 splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
		 
		 splash.alpha = 1.0f;
		 splash.hidden = NO;
		 [self.window addSubview:splash];
		 [[self window] bringSubviewToFront:splash];*/
		
        [UIView animateWithDuration:0.4f
                         animations:^{
                             splash.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [splash removeFromSuperview];
                             splash = nil;
                         }];
	}
}

-(int)databaseVersion
{
	int newVersion = 0;
	const char *sql = nil;
    NSString *searchString;
    
    searchString = @"SELECT * FROM settings where name = 'version' "; 
	sql = [searchString UTF8String];
    
    sqlite3_stmt *statement;
    
    int errorCode = sqlite3_prepare_v2(database, sql, -1, &statement, NULL) ;
    if(errorCode == SQLITE_OK)
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            //int primaryKey = sqlite3_column_int(statement, 0);
            //newVersion = sqlite3_column_int(statement, 1); //name
            newVersion = sqlite3_column_int(statement, 2); //value
		}
    }
    else
    {
		NSLog(@"%@", [NSString stringWithFormat:@"Could not prepare statement: %@", [NSString stringWithUTF8String: sqlite3_errmsg(database)]]);
    }
    
	sqlite3_reset(statement);

	
	return newVersion;
}

-(void)updateRemoveDatabaseVersion
{
	remoteDatabaseVersion = 0;
	updateAvailable = NO;
	
	if(![self isOnline])
		return;
	
	//get list
    NSURL * url_afn = [NSURL URLWithString:URL_API_DB_VERSION];
    NSURLRequest *request_afn = [[NSURLRequest alloc] initWithURL:url_afn];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request_afn
																						success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
										 {
											//save it
											if([JSON count] == 1)
											{
												int localVersion = [self databaseVersion];
												
												//remoteDatabaseVersion = [NSNumber numberWithInt:[[JSON[0] objectForKey:@"version"] integerValue]];
												
												remoteDatabaseVersion = [[JSON[0] objectForKey:@"version"] integerValue];
												
												//compare
												//if( (remoteDatabaseVersion > 0) && (localVersion > 0) &&
														//(remoteDatabaseVersion > localVersion) ) //bigger
                                                if( (remoteDatabaseVersion > 0) && (localVersion > 0) && 
														(remoteDatabaseVersion != localVersion) ) //different

												{
													updateAvailable = YES;
												}
												else
												{
													updateAvailable = NO;
												}
												
												dispatch_async(dispatch_get_main_queue(), ^{
													
													[archiveViewController updateBadgeLeft];
													
												});
												
												
												NSLog(@"remoteDatabaseVersion: %d", remoteDatabaseVersion);
											}
											else
											{
												remoteDatabaseVersion = 0;
												updateAvailable = NO;
											}

										 }
																						failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
										 {
											 NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
										 }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
		//timed out
		remoteDatabaseVersion = 0;
		updateAvailable = NO;
	}];
    [operation start];

}

-(void)backupDatabase
{
	NSFileManager *fileManager = [[NSFileManager alloc] init]; //[NSFileManager defaultManager];
	NSError *error;
	
	//old
	
	NSString *documentsDirectory = [self savePath];
	NSString *backupDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME_BACKUP];
	NSString *originalDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	
	//remove backup
	if([fileManager fileExistsAtPath:backupDBPath])
	{
		  
		if (![fileManager removeItemAtPath:backupDBPath error:&error])
		{
			NSAssert1(0, @"Could not remove backupDBPath database file with message '%@'.", [error localizedDescription]);
		}
    }
    
    //copy
	if(![fileManager copyItemAtPath:originalDBPath toPath:backupDBPath error:&error])
            NSAssert1(0, @"Failed to copy database file with message '%@'.", [error localizedDescription]);
    
}

-(void)revertDatabaseUpdate
{
	NSFileManager *fileManager = [[NSFileManager alloc] init]; //[NSFileManager defaultManager];
	NSError *error;
		
	NSString *documentsDirectory = [self savePath];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	NSString *backupDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME_BACKUP];
	
	if([fileManager fileExistsAtPath:writableDBPath])
	{
       //remove
		if (![fileManager removeItemAtPath:writableDBPath error:&error])
		{
			NSAssert1(0, @"Could not remove old database file with message '%@'.", [error localizedDescription]);
		}
    }
    
    //copy
	
	if(![fileManager copyItemAtPath:backupDBPath toPath:writableDBPath error:&error])
		NSAssert1(0, @"Failed to copy database file with message '%@'.", [error localizedDescription]);
    
    
	//init
    [self initializeDatabase:NO];
}

-(void)replaceDatabaseUpdate
{
    NSFileManager *fileManager = [[NSFileManager alloc] init]; //[NSFileManager defaultManager];

	NSError *error;
	NSString *documentsDirectory = [self savePath];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	NSString *updateDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME_UPDATE];
    
    //old exists?
    if(![fileManager fileExistsAtPath:writableDBPath])
        return;
   
    //update exists?
    if(![fileManager fileExistsAtPath:updateDBPath])
        return;
    
    //delete old
	if (![fileManager removeItemAtPath:writableDBPath error:&error])
    {
        NSAssert1(0, @"Could not remove old database file with message '%@'.", [error localizedDescription]);
    }
    
    //copy
    if(![fileManager copyItemAtPath:updateDBPath toPath:writableDBPath error:&error])
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    
    //delete update
	if (![fileManager removeItemAtPath:updateDBPath error:&error])
    {
        NSAssert1(0, @"Could not remove updated database file with message '%@'.", [error localizedDescription]);
    }
    
	//init
    [self initializeDatabase:YES];
    
    //thread
    dispatch_async(dispatch_get_main_queue(), ^{
             [archiveViewController forceSearch:@"" withDelay:YES];
        });
        
    //[self searchQuote:@""];
    //[self refresh];
}

-(int)howManyRows
{
    int count = 0;
    const char *sql = nil;
    NSString *searchString;
    
    searchString = @"SELECT id FROM quotes";    
    sql = [searchString UTF8String];
    
    sqlite3_stmt *statement;
    
    int errorCode = sqlite3_prepare_v2(database, sql, -1, &statement, NULL) ;
    if(errorCode == SQLITE_OK)
    {
        
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            //int primaryKey = sqlite3_column_int(statement, 0);
			count++;
        }
    }
    else
    {
         NSLog(@"%@", [NSString stringWithFormat:@"Could not prepare statement: %@", [NSString stringWithUTF8String: sqlite3_errmsg(database)]]);
    }
    
     sqlite3_reset(statement);
    
    return count;
}

-(void)searchQuote:(NSString*)search
{    
    const char *sql = nil;
    NSString *searchString;
    BOOL isCategory = NO;
    BOOL shuffle = NO;
    
    searchString = @"SELECT id FROM quotes ORDER BY id DESC"; //instead of sql, since encrypted
    
    //short
    search = [search stringByReplacingOccurrencesOfString:@"cat:" withString:@"category:"];

    //random
    if([search isEqualToString:@"category:random"] )
    {
        shuffle = YES;
        search = @"";
    }
    
    //is category?
    isCategory = !([search rangeOfString:@"category:"].location == NSNotFound);
    
    //remove category
    search = [search stringByReplacingOccurrencesOfString:@"category:" withString:@""];

    //favorite
    favorites = [search isEqualToString:@"favorites"];
    
    sql = [searchString UTF8String];
    
    sqlite3_stmt *statement;
    
    int errorCode = sqlite3_prepare_v2(database, sql, -1, &statement, NULL) ;
    if(errorCode == SQLITE_OK)
    {
        [quotes removeAllObjects];
        
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            int primaryKey = sqlite3_column_int(statement, 0);
            Quotes *q = [[Quotes alloc] initWithPrimaryKey:primaryKey database:database];
            
            //de-crypt
            BOOL decrypt = YES;
            if(decrypt)
            {
                NSString *beforeQuote = [q quote];
                NSString *afterQuote = [self base64Decode:beforeQuote];
                
                NSString *beforeAuthor1 = [q author1];
                NSString *afterAuthor1 = [self base64Decode:beforeAuthor1];
                
                NSString *beforeAuthor2 = [q author2];
                NSString *afterAuthor2 = [self base64Decode:beforeAuthor2];
                
                NSString *beforeCategories = [q categories];
                NSString *afterCategories = [self base64Decode:beforeCategories];
                
                [q setQuote:afterQuote];
                [q setAuthor1:afterAuthor1];
                [q setAuthor2:afterAuthor2];
                [q setCategories:afterCategories];
            }
            
            //[q setRowId:???];
            
			//find, instead of sql, since encrypted
			BOOL match = NO;
            if(isCategory)
            {
                //new
                if([search isEqualToString:@"new"] && ([q isNew] == 1))
                {
                    match = YES;
                }
                else if(favorites && [self isFavorite:[q rowId]]) //todo:chris:favorites
                {
                       match = YES;
                }
                //normal
                else if ([[q categories] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    match = YES;
                }
            }
			else
            {
                if([search length] == 0) //all
                    match = YES;
                else if ([[q quote] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)
                    match = YES;
                //else if ([[q categories] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)
                //    match = YES;
                else if ([[q author1] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)
                    match = YES;
                else if ([[q author2] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)
                    match = YES;
			}
			if(match)
				[quotes addObject:q];
        }
        
                
        totalItems = [quotes count];
        numRows = totalItems; //START_NUM_ROWS;
        
        //random
        //if(isCategory && [search isEqualToString:@"random"] )
        if(shuffle)
        {
            [quotes shuffle];
        }

    }
    else
    {
        totalItems = 0;
        numRows = 0;
         NSLog(@"%@", [NSString stringWithFormat:@"Could not prepare statement: %@", [NSString stringWithUTF8String: sqlite3_errmsg(database)]]);
    }
    
     sqlite3_reset(statement);
}

- (void) deleteOldDatabase
{
	//for previous versions, in documents
	
	NSFileManager *fileManager = [[NSFileManager alloc] init]; //[NSFileManager defaultManager];
	NSError *error;
	
	//old path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];

	if([fileManager fileExistsAtPath:writableDBPath])
    {
		if (![fileManager removeItemAtPath:writableDBPath error:&error])
		{
			NSAssert1(0, @"Could not remove old database file with message '%@'.", [error localizedDescription]);
		}
	}
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    if (&NSURLIsExcludedFromBackupKey == nil) {
        // iOS 5.0.1 and lower
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
    else {
        // First try and remove the extended attribute if it is present
        int result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                NSLog(@"Removed extended attribute on file %@", URL);
            }
        }
        
        // Set the new key
        NSError *error = nil;
        [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        return error == nil;
    }
}


- (NSString*) savePath
{
	//in cache
	
    NSString *os5 = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSString *path = nil;
	NSFileManager *fileManager = [[NSFileManager alloc] init]; //[NSFileManager defaultManager];
	BOOL isDir;
	
	if ([currSysVer compare:os5 options:NSNumericSearch] == NSOrderedDescending) //5.0.1 and above
    {
		path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Databases"];
    }
    else // IOS 5
    {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    }
	
	//create it if not exist
	if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
		if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
			NSLog(@"Error: Create folder failed %@", path);

	//mark as do not backup
	[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
	
    return path;
}

-(void)copyBundleDatabase:(BOOL)forced
{
	NSFileManager *fileManager = [[NSFileManager alloc] init]; //[NSFileManager defaultManager];
	NSError *error;
	
	//old
	[self deleteOldDatabase];
	
	NSString *documentsDirectory = [self savePath];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];

	if([fileManager fileExistsAtPath:writableDBPath])
	{
        //keep it
    	//return;
        
        //check dates
        NSDictionary *dictionary = [fileManager attributesOfItemAtPath:bundleDBPath error:&error];
        NSDate *fileDateBundle =[dictionary objectForKey:NSFileModificationDate];
        
        dictionary = [fileManager attributesOfItemAtPath:writableDBPath error:&error];
        NSDate *fileDateLocal =[dictionary objectForKey:NSFileModificationDate];
    
        //remove local if older than bundle
        if(forced || [fileDateBundle compare: fileDateLocal] == NSOrderedDescending) // if start is later in time than end
        {
            if (![fileManager removeItemAtPath:writableDBPath error:&error])
            {
                NSAssert1(0, @"Could not remove old database file with message '%@'.", [error localizedDescription]);
            }
        }
    }
    
    //copy, if not exist
	if(![fileManager fileExistsAtPath:writableDBPath])
    {	
        if(![fileManager copyItemAtPath:bundleDBPath toPath:writableDBPath error:&error])
            NSAssert1(0, @"Failed to copy database file with message '%@'.", [error localizedDescription]);
    }
    
	//init
    [self initializeDatabase:NO];
}

-(void)initializeDatabase:(BOOL)fromUpdate
{
   self.quotes = [[NSMutableArray alloc] init];
    
    //from copied
	NSString *documentsDirectory = [self savePath];
	NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	
    //from bundle
	//NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];

	//if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
	//if(sqlite3_open_v2([dbPath UTF8String], &database, SQLITE_OPEN_READONLY, NULL) == SQLITE_OK) //read only
	if(sqlite3_open_v2([dbPath UTF8String], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) //read only
	{
        //good
    }
	else
	{
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
        
    //valid?
    int tempCount = [self howManyRows];
    if(tempCount <= 0 || tempCount > 100000)
    {
		if(fromUpdate)
			[self revertDatabaseUpdate];
		else
			[self copyBundleDatabase:YES]; //force
    }

}

- (NSString *)obfuscate:(NSString *)string withKey:(NSString *)key
{
    // Create data object from the string
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

    // Get pointer to data to obfuscate
    char *dataPtr = (char *) [data bytes];

    // Get pointer to key data
    char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];

    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;

    // For each character in data, xor with current value in key
    for (int x = 0; x < [data length]; x++) 
    {
        // Replace current character in data with 
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        *dataPtr = *dataPtr++ ^ *keyPtr++; 

        // If at end of key data, reset count and 
        // set key pointer back to start of key value
        if (++keyIndex == [key length])
            keyIndex = 0, keyPtr = keyData;
    }
 
    NSString *stringOut = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return  stringOut;
}

- (NSString *)obfuscate2:(NSString*) stringIn
{
    NSData *dataIn = [stringIn dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* dataOut = [NSMutableData data];

    NSUInteger n;
    char byte;

    for( n = 0; n < [dataIn length]; ++n )
    {
        [dataIn getBytes:&byte length:1];
        byte ^= 0xA5;
        [dataOut appendBytes:&byte length:1];
    }

    NSString* stringOut = [[NSString alloc] initWithData:dataOut encoding:NSUTF8StringEncoding];
    return stringOut;
}

- (NSString *)base64Encode:(NSString *)plainText
{
	if(plainText == nil)
		return nil;
	
    //NSLog(@"%@",plainText);
    NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainTextData base64EncodedString];
    //NSLog(@"%@",base64String);
	
	assert(base64String);
    return base64String;
}

- (NSString *)base64Decode:(NSString *)base64String
{
	if(base64String == nil)
		return nil;
		
    NSData *plainTextData = [NSData dataFromBase64String:base64String];
    NSString *plainText = [[NSString alloc] initWithData:plainTextData
    encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",plainText);
	
	assert(plainText);
    return plainText;
}


- (void)loadIAP
{
    products = nil;
    
    //disabled
   //if([self isDebug] && ![self isSimulator])
   //   return;
    
	//offline
	if(![self checkOnline])
		return;
			
	[QuoteAddictIAPHelper sharedInstance];

    [[QuoteAddictIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *newProducts) {
        if (success) {
            products = newProducts;
			if(products != nil && [products count]>0)
				productRemoveAds = products[0];
        }
    }];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize withHard:(BOOL)hard
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    if(hard)
    {
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(c, kCGInterpolationNone);
    }
    
    //white background
    //[[UIColor whiteColor] set];
    //UIRectFill(CGRectMake(0, 0, newSize.width, newSize.height));
	
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (BOOL)isFavorite:(NSString*)idString
{
    if(!idString)
        return NO;
    
    BOOL value = NO;
    
    for(NSString *found in favoritesArray)
    {
        if([found isEqualToString:idString])
        {
            value = YES;
            break;
        }
    }
    
    return value;
}

- (void)removeFavorite:(NSString*)idString
{
    if(!idString)
        return;

    //not in list
    if(![self isFavorite:idString])
        return;
    
    //delete
    [favoritesArray removeObject:idString];
    
    favoritesModified = YES;
    
    [Helpers showMessageHud:@"Favorite removed"];

}


- (void)addFavorite:(NSString*)idString
{
    if(!idString)
        return;
    
    //already in list
    if([self isFavorite:idString])
        return;
    
    //add
    [favoritesArray addObject:idString];
    
    favoritesModified = YES;
    
    [Helpers showMessageHud:@"Favorite added"];
}

- (void) initPushNotifications
{
    //https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/IPhoneOSClientImp/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];


    /*UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone)
    {
    
    }*/
    
    /*[[UIApplication sharedApplication] cancelAllLocalNotifications];

    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [datePicker date];
    notif.timeZone = [NSTimeZone defaultTimeZone];

    notif.alertBody = @"Body";
    notif.alertAction = @"AlertButtonCaption";
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = 1;

    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    [notif release];
    */
}

/*
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    //const void *devTokenBytes = [devToken bytes];
    //self.registered = YES;
    //[self sendProviderDeviceToken:devTokenBytes]; // custom method
}
 
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}
*/

- (UIImage *)imageWithGaussianBlur:(UIImage *)image
{
    float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int x = 1; x < 5; ++x) {
        [image drawInRect:CGRectMake(x, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
        [image drawInRect:CGRectMake(-x, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Blur vertically
    UIGraphicsBeginImageContext(image.size);
    [horizBlurredImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[0]];
    for (int y = 1; y < 5; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(0, y, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(0, -y, image.size.width, image.size.height) blendMode:kCGBlendModePlusLighter alpha:weight[y]];
    }
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return blurredImage;
}


- (CGRect) GetScreenRect;
{
    CGRect tempRect = [[UIScreen mainScreen] bounds];
    
    //switch 
    if(![self isPortrait])
    {
        int temp;
        temp = tempRect.size.width;
        tempRect.size.width = tempRect.size.height;
        tempRect.size.height = temp;
    }
    
    return tempRect;
}

- (void)startWobble:(UIView *)view
{
	//disabled
    return;
    

     view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-WOBBLE_DEGREES));

     [UIView animateWithDuration:WOBBLE_SPEED
          delay:0.0 
          options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
          animations:^ {
           view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(WOBBLE_DEGREES));
          }
          completion:NULL
     ];
}

- (void)stopWobble:(UIView *)view
{
     [UIView animateWithDuration:WOBBLE_SPEED
          delay:0.0 
          options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
          animations:^ {
           view.transform = CGAffineTransformIdentity;
          }
          completion:NULL
      ];
}

-(void)updateInReview
{
    [self setShowLockscreen:NO];
    [self setInReview:YES];
	
	if(![self isOnline])
		return;
	
	//get list
    NSURL * url_afn = [NSURL URLWithString:URL_API_IN_REVIEW];
    NSURLRequest *request_afn = [[NSURLRequest alloc] initWithURL:url_afn];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request_afn
																						success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
										 {
											//save it
											if([JSON count] == 1)
											{
												int newValue = [[JSON[0] objectForKey:@"value"] integerValue];
												
                                                //not in review
                                                if(newValue == 0) 
                                                {
                                                    [self setShowLockscreen:YES];
                                                    [self setInReview:NO];
                                                }
											}
										 }
										
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
										 {
											 NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
										 }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
							NSLog(@"Request timed out.");
	}];
    [operation start];
}

#pragma mark -
#pragma mark Notifications

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    [self processNotification:notif];
    [self setupNotifications];
}

- (void) processNotification:(UILocalNotification *)notif {
    
    if(notif) {
        NSLog(@"Recieved Notification %@",notif);
    }
}

- (void)setupNotifications {
    
    //reset
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
 
 /*
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];

    //add one month
    //[components setWeek: [components week] + 4];
    
    [components setHour:12]; //12pm
    [components setMinute:0];
    [components setSecond:0];

    //add one month
    NSDate *nextdDate = [gregorian dateFromComponents:components];
    nextdDate = [nextdDate dateByAddingDays:7];
    
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    if (notif == nil)
        return;
    
    notif.fireDate = nextdDate;
    notif.repeatInterval = NSMonthCalendarUnit; //repeat every month
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody =  @"You haven't used Quote Addict in a while. Please send us some feedback!";
    notif.alertAction = @"View";
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = 1;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
*/
}



-(UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat) scale{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage2 = [UIImage imageWithCGImage:[preImage CGImage]
                                           scale:[preImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    return qrImage2;
}

@end

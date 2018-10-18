//
//  QuoteAddictAppDelegate.h
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <sqlite3.h>
//#import "LocalyticsSession.h"
//#import "FlurryAnalytics.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
//#import "HelpViewController.h"
#import "WelcomeViewController.h"
#import "AboutViewController.h"
#import "QRViewController.h"
#import "UpdateViewController.h"
//#import "JSONKit.h"
#import "FirstViewController.h"
#import "ArchiveViewController.h"
#import "SideMenuViewController.h"
#import "QuoteAddictIAPHelper.h"
#import <StoreKit/StoreKit.h>

#define START_NUM_ROWS  10;
#define OBFUSCATE_KEY @"???"

//cleanup svn
//find . -type d -name '.svn' -print0 | xargs -0 rm -rdf
//find . -type d -name '.git' -print0 | xargs -0 rm -rdf
//find . -name ".DS_Store" -depth -exec rm {} \;

//sounds
//#define SOUND_1 @"sound1"

//#define CACHE_POLICY_IMAGES NSURLRequestReturnCacheDataElseLoad
#define CACHE_POLICY_IMAGES NSURLRequestUseProtocolCachePolicy
//#define CACHE_POLICY_IMAGES NSURLRequestReloadIgnoringLocalCacheData
//#define CACHE_POLICY_AD NSURLRequestUseProtocolCachePolicy
#define CACHE_POLICY_AD NSURLRequestReloadIgnoringLocalCacheData

//urls
#define URL_API_NUM_APPS @"http://www.skyriser.com/api_num_apps.php"
#define URL_API_IN_REVIEW @"http://www.quoteaddict.com/api_rev.php"

//#define URL_API_INC_VIEW @"http://bingwallpapers.com/api_inc_view.php?name=%@" //todo:chris

//ads
#define URL_API_AD_LIST @"http://www.skyriser.com/api_ad_list.php"

typedef enum {
    APP_ID_PASSGRID = 0,
    APP_ID_DAILYWALL = 1,
    APP_ID_QRLOCK = 2,
    APP_ID_QUOTE = 3,
    APP_ID_GOLF = 4,
} APP_ID;

#define APP_ID_CURRENT APP_ID_QUOTE


//color
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


//http://www.idev101.com/code/User_Interface/sizes.html
#define STATUS_BAR_HEIGHT 20
#define NAV_BAR_HEIGHT 44
//#define TOOL_BAR_HEIGHT 44 //?
#define TAB_BAR_HEIGHT 49


#define CLICK_DELAY 0.2f

#define MAX_LOAD 10 

#define MAX_HUD_TIME 30
#define MIN_HUD_TIME 1

#define SPLASH_FADE_TIME 0.3f
#define SPLASH_FADE_TIME_LONG 1.0f
#define CHECKONLINE_REPEAT_TIME 5
#define CONNECTION_TIMEOUT 15
#define LOAD_MORE_DELAY_TIME 1.0 //0.5

#define CELL_HEIGHT_NORMAL 121
#define CELL_HEIGHT_MORE 121

//strings
#define STR_CELL_LOAGING_MORE @"Loading more..."

#define SLIDE_LEN 259
#define SLIDE_LEN_IPAD_PORTRAIT 600
#define SLIDE_LEN_IPAD_LANDSCAPE 600

#define SLIDE_DELAY 0.3f //0.25f //0.5f
#define NUM_MINUTES_TO_REFRESH 60

//update
#define URL_UPDATE @"http://www.quoteaddict.com/database.sqlite"
#define URL_API_DB_VERSION @"http://www.quoteaddict.com/api_db_version.php"
#define DB_NAME @"database.sqlite"
#define DB_NAME_UPDATE @"update.sqlite"
#define DB_NAME_BACKUP @"bakup.sqlite"

//IAP
#define IAP_SECRET @"???"
#define IAP_ID_REMOVEADS @"com.skyriser.quoteaddict.removeads2"
#define IAP_URL_VERIFY @"https://sandbox.itunes.apple.com/verifyReceipt" //{"status":21000}

//wobble
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define WOBBLE_DEGREES 1
#define WOBBLE_SPEED 0.2 //0.25

@interface QuoteAddictAppDelegate : NSObject <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIApplicationDelegate, UINavigationBarDelegate> {
    UIWindow *window;
    UINavigationController *navController;
    UIImage *qrImage;
    
    BOOL showingHelp;
    BOOL prefRated;
    
    FirstViewController     *firstViewController;
	WelcomeViewController   *modalHelp;
	QRViewController        *modalQR;
	UpdateViewController        *modalUpdate;
    ArchiveViewController   *archiveViewController;
    AboutViewController		*aboutViewController;
    SideMenuViewController  *sideMenuViewController;

    UIImage *savedImage;
    UIImage *savedThumbImage;
    UIImage *savedAdImage;
    
    BOOL random;
    BOOL isDoneLaunching;
    BOOL isOnline;
    BOOL isLoading;
    

    BOOL alreadyFillTable;
    BOOL alreadyFillTable2;
    BOOL emptyTable;
    BOOL alreadySelectImage;
    
    int totalItems;
    int numRows;
    
    int indexToLoad;
    UIImage *missingThumb;
    UIImage *cellBackImage1;
    UIImage *cellBackImage2;
    
  	BOOL prefOpened;
 	int prefRunCount;
    int prefNumApps;
    int currentAdId;
    BOOL prefPlaySound;
    NSString *currentAdUrl;

    BOOL prefShowAll;
    NSString *prefVersion;
    double lastTimeSince70;
    BOOL prefPurchasedRemoveAds;
    
    BOOL numAppsDownloaded;
    int numApps;
    NSDate *timeLastRefresh;

    SystemSoundID audioEffect;
    
    sqlite3 *database;
	NSMutableArray *quotes;
    
    BOOL isSliding;
    
    NSArray *products;
	SKProduct * productRemoveAds;
    NSMutableArray *favoritesArray;
    NSMutableArray *adArray;
	
	int remoteDatabaseVersion;
	BOOL updateAvailable;
}

@property (nonatomic, retain) UIImage *missingThumb;
@property (nonatomic, retain) NSMutableArray *quotes;

-(BOOL)backgroundSupported;
- (NSString *) platform;
- (NSString *) platformString;
- (BOOL)isIpad;
- (BOOL) isIphone5;
- (BOOL)isTestflight;
- (BOOL)isDebug;
- (BOOL)isSimulator;
- (BOOL)isRetina;
- (BOOL) isPortrait;
- (BOOL)openURL:(NSURL*)url;
- (BOOL)HasConnection;
- (NSString *)getSecureID;
-(void)cornerView:(UIView*)inView;
-(void)addNavigationController:(UINavigationController*)nav;
- (void)selectImage:(int)index showView:(BOOL)show;
-(void)searchQuote:(NSString*)search;
-(void)replaceDatabaseUpdate;
-(void)copyBundleDatabase:(BOOL)forced;
-(void)updateRemoveDatabaseVersion;
-(int)databaseVersion;

-(UIImage*) maskImage:(UIImage *)inputImage withMask:(UIImage *)inputMaskImage;
-(UIImage *)changeWhiteColorTransparent: (UIImage *)image;
-(UIImage *)colorizeImage: (UIImage *)image;
-(UIImage*) createMaskWithImage: (UIImage*) image;
-(UIImage*) getQRImage;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize withHard:(BOOL)hard;
- (void)sendEmailTo:(NSString *)to withSubject:(NSString *)subject withBody:(NSString *)body withView:(UIViewController*)theView;
- (void)alertHelp:(BOOL)isAnimated;
- (void)alertQR:(BOOL)isAnimated;
- (void)alertUpdate:(BOOL)isAnimated;
- (void)alertUpdateDone:(BOOL)fromThread;
- (void)alertHelpDone;
- (void)alertHelpDoneFirstTime;
- (void)alertHelpDoneNotAnimated;
- (void)gotoReviews;
- (void)gotoGift;
- (void)gotoAd;
- (void)gotoFacebook;
- (void)gotoTwitter;
- (void)gotoQRScannerApp;
- (NSString*)getUserAgent;
- (NSString*)getVersionString;
- (NSString*)getVersionString2;
-(void)updateNumAppsBadge;
-(int)getNumApps;
-(void)hideNumAppsBadge;
- (void)pushAbout;
- (void) updateAd;
- (void) updateAd2;
- (void)saveState;
- (void)saveStateDefault;
- (void)loadState;
- (BOOL) checkOnline;
- (void) playSound:(NSString*)filename;
- (void)refresh;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(void)copyImageToClipboard:(UIImage*)inImage;
- (BOOL) isTapForTap;
- (BOOL) isShowDefault;
- (NSString*) getStringFromURL:(NSString*)url;
- (void)fadeDefault;
- (void)fadeDefaultSetup;
- (NSString *)obfuscate:(NSString *)string withKey:(NSString *)key;
- (NSString *)obfuscate2:(NSString*) stringIn;
//- (void)setRootMenu;
//- (void)setRootNormal;
- (BOOL)isFavorite:(NSString*)idString;
- (void)addFavorite:(NSString*)idString;
- (void)removeFavorite:(NSString*)idString;
- (UIImage *)imageWithGaussianBlur:(UIImage *)image;
- (CGRect) GetScreenRect;
- (void)startWobble:(UIView *)view;
- (void)stopWobble:(UIView *)view;
-(void)updateInReview;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet FirstViewController *firstViewController;
@property (nonatomic, retain) UIImage *qrImage;
@property (nonatomic, retain) UIImage *savedImage;
@property (nonatomic, retain) UIImage *savedAdImage;
@property (nonatomic, retain) UIImage *savedThumbImage;
@property (assign, nonatomic) BOOL showingHelp;
@property (assign, nonatomic) BOOL prefRated;
@property (assign, nonatomic) BOOL random;
@property (assign, nonatomic) BOOL popular;
@property (assign, nonatomic) BOOL alreadySelectImage;
@property(nonatomic, assign) int indexToLoad;
@property(nonatomic, assign) BOOL isDoneLaunching;
@property(nonatomic, assign) BOOL isOnline;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) int totalItems;
@property(nonatomic, assign) int numRows;
@property (nonatomic, retain) ArchiveViewController *archiveViewController;
@property (nonatomic, retain) AboutViewController *aboutViewController;
@property (nonatomic, retain) SideMenuViewController *sideMenuViewController;
@property(nonatomic,retain) IBOutlet UIImage *cellBackImage1;
@property(nonatomic,retain) IBOutlet UIImage *cellBackImage2;
@property (assign, nonatomic) int prefRunCount;
@property (assign, nonatomic) int prefNumApps;
@property (assign, nonatomic) int currentAdId;
@property (assign, nonatomic) BOOL prefPlaySound;
@property (nonatomic, retain) NSString *currentAdUrl;
@property (assign, nonatomic) BOOL prefShowAll;
@property (assign, nonatomic) BOOL prefPurchasedRemoveAds;
@property (nonatomic, retain) NSString *prefVersion;
@property (assign, nonatomic) double lastTimeSince70;
@property (assign, nonatomic) BOOL prefOpened;
@property(nonatomic, retain) NSDate *timeLastRefresh;
@property (assign, nonatomic) BOOL alreadyFadeDefault;
@property (strong, nonatomic) UIImageView *splash;
@property(nonatomic, assign) BOOL isSliding;
@property (nonatomic, retain) UIColor *buttonTextColor;
@property (nonatomic, retain) NSArray *products;
@property (nonatomic, retain) SKProduct * productRemoveAds;
@property (nonatomic, retain) NSMutableArray *favoritesArray;
@property (assign, nonatomic) BOOL favoritesModified;
@property (assign, nonatomic) BOOL favorites;
@property (assign, nonatomic) BOOL showUpdate;
@property (assign, nonatomic) int remoteDatabaseVersion;
@property (assign, nonatomic) BOOL updateAvailable;
@property (assign, nonatomic) BOOL showLockscreen;
@property (assign, nonatomic) BOOL inReview;
@property (assign, nonatomic) int prefMailchimpCount;
@property (assign, nonatomic) BOOL prefMailchimpShown;

@end

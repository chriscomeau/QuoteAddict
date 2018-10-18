//
//  ArchiveViewController.h
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "TableViewController.h"
//#import "TapForTap.h"

#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GADBannerView.h>

@interface ArchiveViewController : UIViewController <MBProgressHUDDelegate, UINavigationBarDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate /*, TapForTapAdViewDelegate*/, GADBannerViewDelegate> {
	
	//IBOutlet UIImageView *imageView;
    
	id appDelegate;
    MBProgressHUD *HUD;
    bool doHud;
    int oldTableHeight;
	BOOL closed;
	BOOL rotating;
    UITableView *tableView;
    UIImageView *darkImage;
    UIButton *adButton;
    UIActivityIndicatorView *spin;
    TableViewController *tableViewController;
	bool adDownloaded;
    //UINavigationController *navigationController;
    BOOL slide;
    UIButton    *tableButton;
    NSString    *searchString;
    int slideX;
    UIAlertView *alertRemoveAd;
	UIDeviceOrientation currentOrientation;

}

//@property (nonatomic, retain) TapForTapAdView *adView;
@property(nonatomic,retain) IBOutlet UIImageView *darkImage;
@property(nonatomic,retain) IBOutlet UIButton *adButton;
@property(nonatomic,retain)  IBOutlet UIActivityIndicatorView *spin;
@property(nonatomic,retain)  IBOutlet UITableView *tableView;
@property(nonatomic,retain)  IBOutlet UIButton *closeButton;
@property(nonatomic,retain)  IBOutlet UIImageView *offlineImage;
@property(nonatomic,retain)  IBOutlet UIImageView *noResultsImage;
@property (nonatomic, retain) TableViewController *tableViewController;
@property(nonatomic,retain) IBOutlet UITextView *badgeText;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewBadge;
@property(nonatomic, assign) BOOL slide;
@property(nonatomic,retain)  IBOutlet UIButton *tableButton;
@property(nonatomic,retain)  NSString *searchString;
@property(nonatomic,retain)  NSString *oldSearchString;
@property(nonatomic,retain)  UISearchBar *searchBar2;
@property(nonatomic,retain)  MBProgressHUD *HUD;

@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;


- (void)notifyForeground;
- (void)selectImage:(int)index showView:(BOOL)show;
- (void)showAd:(BOOL)show;
- (void)hideAd;
- (void)showOffline:(BOOL)show;
- (void)showNoResults:(BOOL)show;
- (void)updateBadgeLeft;
- (void)updateBadgeRight;
- (void)statusBarWillChangeFrame:(id)sender;
- (void)toggleSlide;
- (void)forceSearch:(NSString*)string withDelay:(BOOL)delay;
- (void)forceReSearch;
- (void)scrollToTop;
- (void)buyRemoveAds;
- (void)showHud:(NSString*)label;
- (void)hudTask;
- (void)hideKeyboard;
- (void)updateBanner:(BOOL)reload;

@end

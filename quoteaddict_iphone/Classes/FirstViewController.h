//
//  FirstViewController.h
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface FirstViewController : UIViewController <UINavigationBarDelegate, UIActionSheetDelegate> {
	
    UILabel *textDesc;
    UILabel *countLabel;
   	UIButton *lockscreenButton;
   	UIButton *shuffleButton;
   	UIButton *arrowLeftButton;
    UIButton *arrowRightButton;
   	UIImageView *imageViewEdge;
    bool isFavorite;
    NSString *currentId;
    
	id appDelegate;
    //MBProgressHUD *HUD;
    //bool doHud;
    bool interfaceHidden;
    bool alreadyLongPress;
    bool previewWasInfoHidden;
    
   	UIImageView *darkImage;
    UIActivityIndicatorView *spin;
    id prevNavigationBarDelegate;
    UIAlertView *alertBing;
    int indexToLoad;
    int indexUndo;
    NSString *mixed;
    BOOL reload;
    BOOL flipping;
    ALAssetsLibrary* library;

}

@property(nonatomic,retain) IBOutlet UIButton *lockscreenButton;
@property(nonatomic,retain) IBOutlet UIButton *shuffleButton;
@property(nonatomic,retain) IBOutlet UIButton *arrowLeftButton;
@property(nonatomic,retain) IBOutlet UIButton *arrowRightButton;
@property(nonatomic,retain) IBOutlet UILabel *textDesc;
@property(nonatomic,retain) IBOutlet UILabel *countLabel;
@property(nonatomic,retain) IBOutlet UIImageView *darkImage;
@property(nonatomic,retain)  IBOutlet UIActivityIndicatorView *spin;
@property(nonatomic, assign) BOOL reload;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewEdge;
@property(nonatomic,retain) IBOutlet UIButton *buttonFavorite;

- (void) saveImage: (UIImage*) image;
- (void)actionSave:(id)sender;
- (void)actionReload:(id)sender;
- (void)toggleInterface;
- (void)showInterface:(BOOL)show;
- (void) setupUI;
- (void)showPreview;
- (void)notifyForeground;
-(void)showSpin:(BOOL)show;
-(void) updateLockscreenImage;
@end

//
//  FirstViewController.m
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import "FirstViewController.h"
#import "QuoteAddictAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+HTML.h"
#import "Quotes.h"
#import "UIAlertView+Errors.h"
//#import "SHKFacebook.h"
//#import "SHKTwitter.h"
//#import "SHKTextMessage.h"

NSRecursiveLock *lock1;

@implementation FirstViewController
@synthesize lockscreenButton;
@synthesize shuffleButton;
@synthesize arrowLeftButton;
@synthesize arrowRightButton;
@synthesize spin;
@synthesize darkImage;
@synthesize textDesc;
@synthesize countLabel;
@synthesize reload;
@synthesize imageViewEdge;
@synthesize buttonFavorite;

UIBackgroundTaskIdentifier bgTaskSaveWallpaper;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    appDelegate = (QuoteAddictAppDelegate *)[[UIApplication sharedApplication] delegate];
	bgTaskSaveWallpaper = UIBackgroundTaskInvalid;
	
    //back color
    //[[appDelegate window] setBackgroundColor:[UIColor blackColor]];
    
	[self becomeFirstResponder];
	
	lock1 = [[NSRecursiveLock alloc] init];

    @try {
        library = [[ALAssetsLibrary alloc] init]; //crash?
    }
     @catch (NSException * ex) {
        [UIAlertView showError:@"Error reading image library, please sync with iTunes to correct this issue." withTitle:@"Error"];
    }
    
    [self showSpin:NO];
    flipping = NO;
    alertBing = nil;
    interfaceHidden = NO;
    alreadyLongPress = NO;
    previewWasInfoHidden = NO;
    //auto hide tab bar
    self.hidesBottomBarWhenPushed = YES;
    mixed = @"";
    lockscreenButton.hidden = YES;
    shuffleButton.hidden = NO;
    arrowLeftButton.hidden = NO;
    arrowRightButton.hidden = NO;
    buttonFavorite.hidden = YES; //NO;
    imageViewEdge.hidden = NO;
    isFavorite = NO;
    currentId = @"";
    
    reload = YES;
    indexUndo = -1;
    
    [lockscreenButton addTarget:self action:@selector(actionLockscreen:) forControlEvents:UIControlEventTouchUpInside];
    [shuffleButton addTarget:self action:@selector(actionRandom:) forControlEvents:UIControlEventTouchUpInside];
    [arrowLeftButton addTarget:self action:@selector(actionArrowLeft:) forControlEvents:UIControlEventTouchUpInside];
    [arrowRightButton addTarget:self action:@selector(actionArrowRight:) forControlEvents:UIControlEventTouchUpInside];
    [buttonFavorite addTarget:self action:@selector(actionFavorite:) forControlEvents:UIControlEventTouchUpInside];

    //rotation
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    
    //desc
    
     //count
    countLabel.text = @"0 of 0";
    [countLabel setFont: [UIFont fontWithName:@"Century Gothic" size:12]];
    countLabel.textColor = [UIColor whiteColor]; //RGBA(94, 94, 94, 255); //grey
    countLabel.alpha = 0.2f;
    
    //nav
    //add button
    UIBarButtonItem *rightButon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu:)];
    [self.navigationItem setRightBarButtonItem:rightButon animated:YES];
    
    //swipes
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeLeft)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer];

    UISwipeGestureRecognizer * recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeRight)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer2];

    UISwipeGestureRecognizer * recognizer3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeUp)];
    [recognizer3 setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:recognizer3];

    UISwipeGestureRecognizer * recognizer4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeDown)];
    [recognizer4 setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:recognizer4];


    [self showInterface:YES];
    
    //corner
    //[appDelegate cornerView:self.view];

}

- (void) setupUI;
{
    NSLog(@"FirstViewController::setupUI");

    if(![appDelegate isDoneLaunching])
        return;
        
    if(![appDelegate checkOnline])
        return;
}

- (void)notifyForeground
{
    NSLog(@"FirstViewController::notifyForeground");
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self becomeFirstResponder];
    
	//google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    //flipping = NO;
    
    //title
    /*UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"A.C.M.E. Secret Agent" size:20] ;
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text= @"Details";
    [self navigationItem].titleView = label;
    [self.navigationItem.titleView sizeToFit];  //center*/


    //index
    if(reload)
    {
        indexToLoad = [appDelegate indexToLoad];
        indexUndo = -1;
    }
    
    //show
    [self showInterface:YES];

    lockscreenButton.hidden = YES;
    
    //nav
    //show
    [[appDelegate navController] setNavigationBarHidden:NO animated:YES];
    
    [appDelegate navController].navigationBar.translucent = YES;
    
    
	if([appDelegate backgroundSupported])
	{
		[[NSNotificationCenter  defaultCenter] addObserver:self
												  selector:@selector(notifyForeground)
													  name:UIApplicationWillEnterForegroundNotification
													object:nil]; 
	}
    
        //spin now
    //[self showSpin:YES];
    
    //dont reload on email,text
    reload = NO;
	
	[self updateLockscreenImage];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self becomeFirstResponder];
    
    //[appDelegate setAlreadySelectImage:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    
	[self resignFirstResponder];
    
    //nav bar popped
    [[appDelegate navController] setNavigationBarHidden:NO animated:YES];

	[super viewWillDisappear:animated];

    //if(HUD)
    //doHud = false;
    //[HUD hide:YES];
    
    //[self showSpin:NO];
}

- (void)showPreview
{
    NSLog(@"FirstViewController:showPreview");
    
    [self showInterface:NO];
    
	[self updateLockscreenImage];

    lockscreenButton.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.parentViewController == nil)
    {

        //NSLog(@"viewDidDisappear doesn't have parent so it's been popped");
    } else
    {
        //NSLog(@"PersonViewController view just hidden");
    }
}

- (void)actionSave:(id)sender
{
	//[UIAlertView showError:@"Not yet implemented." withTitle:@"Error"];
    //return;
	
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"actionSave"];
	}
	
	[self showSpin:YES];
	
    //uiscrollview not threadsafe
    /*scrollBounds = imageScrollView.bounds;
    scrollContentOffset = imageScrollView.contentOffset;
    scrollFrame = imageScrollView.frame;
    scrollZoomScale = imageScrollView.zoomScale;
    scrollImage = [appDelegate savedImage];*/
    
    /*UIGraphicsBeginImageContext(imageScrollView.layer.bounds.size);
	 [imageScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
	 scrollImage = UIGraphicsGetImageFromCurrentImageContext();
	 UIGraphicsEndImageContext();*/
	
	[self performSelector:@selector(saveFinish) withObject:nil afterDelay:0.01];
	
	//[self saveFinish];
}

- (void)saveFinish
{
    //200px on each side, retina
    int parallaxOffsetX = 0;
    int parallaxOffsetY = 0;
    
	/*int screenWidth = 320;
	int screenHeight = 480; //retina?
	if([appDelegate isIphone5])
    {
		screenHeight = 568;
	}
    */
    
    CGRect screenRect =  [appDelegate GetScreenRect];
    int screenWidth = screenRect.size.width;
	int screenHeight = screenRect.size.height;
    
    //force size for parallax
    if([appDelegate isIpad])
    {
        //screenWidth = 1424;
        //screenHeight = 1424;
            
        screenWidth = 2360;
        screenHeight = 2524;
        
    }
    else if([appDelegate isIphone5])
    {
        //screenWidth = 1040;
        ///screenHeight = 1536;
        
        screenWidth = 744;
        screenHeight = 1392;
    }
    else
    {
        //4s
        //screenWidth = 1040;
        //screenHeight = 1360;
        
        screenWidth = 744;
        screenHeight = 1216;

    }
    
    //count in non-retina
    screenWidth /= 2;
    screenHeight /= 2;
    
    parallaxOffsetX = (screenWidth - screenRect.size.width)/2;
    parallaxOffsetY = (screenHeight -  screenRect.size.height)/2;

    parallaxOffsetY += 30; //extra offset
    
    /*
            To avoid this you can create your own simply by adjusting the resolution of the wallpaper you use. You need to have 200 pixels on each side of the image to create the perfect parallax wallpaper. The correct resolutions are follows:

        iPad 2 and iPad mini: 1,424 x 1,424
        iPad 3 and iPad 4: 2,448 x 2,448
        iPhone 4S: 1,360 x 1,040
        iPhone 5: 1,536 x 1,040

        The iPhone 4 doesn't support parallax wallpapers.

        Read more at http://www.trustedreviews.com/opinions/ios-7-tips-and-tricks-a-simple-guide#bL015whWOrIQEstp.99
    
        
        http://www.iosres.com/
    
    */
    
	
	UIImage *background = nil;
	if([appDelegate isIpad])
    {
        //if([appDelegate isRetina])
        //    background = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background-quote~ipad" ofType:@"jpg"]]; //no retina?
        //else
            background = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background-quote~ipad" ofType:@"jpg"]];
    }
    else
    {
        if([appDelegate isRetina])
            background = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background-quote@2x" ofType:@"png"]];
        else
            background = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background-quote" ofType:@"png"]];
    }
    
	//stretch
    CGSize newSize;
    newSize.width = screenWidth;
    newSize.height = screenHeight;
    background = [appDelegate imageWithImage:background scaledToSize:newSize withHard:NO];

	
	CGSize tempSize;
    UIImage *resultingImage = nil;
	    
    UIApplication *app = [UIApplication sharedApplication];
    bgTaskSaveWallpaper = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTaskSaveWallpaper];
        bgTaskSaveWallpaper = UIBackgroundTaskInvalid;
    }];
	
	    
    int multi = 1.0f;
    if([appDelegate isRetina])
        multi = 2.0f;
	 
    //draw all
    tempSize = CGSizeMake(screenWidth,screenHeight);
    //UIGraphicsBeginImageContext(tempSize);
    UIGraphicsBeginImageContextWithOptions(tempSize, NO, multi); //retina scaled
	
    [background drawAtPoint:CGPointMake(0, 0)];
    
   
    //write text
    
    //color
    //CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    //[textDesc.textColor getRed:&red green:&green blue:&blue alpha:&alpha];

    //set
    //[RGBA(red, green, blue, textDesc.alpha) set];
    //UIColor* textColor = [UIColor colorWithRed:red green:green blue:blue alpha:textDesc.alpha];
    UIColor* textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:textDesc.alpha];
    [textColor set];
    
    NSString *drawString = textDesc.text;
    CGRect drawRect = textDesc.frame;
    
    //offset
    //int offset = STATUS_BAR_HEIGHT + NAV_BAR_HEIGHT;
    drawRect.origin.x += parallaxOffsetX;
    drawRect.origin.y += parallaxOffsetY;
    
    //center?
    int fontSize = 0;
    if([drawString length] > 500)
        fontSize = 10;
    else if([drawString length] > 400)
        fontSize = 12;
    else if([drawString length] > 300)
        fontSize = 12;
    else if([drawString length] > 200)
        fontSize = 14;
    else if([drawString length] > 130)
        fontSize = 16;
    else
        fontSize = 18;
    
    NSDictionary * attributes = @{
                                  NSFontAttributeName : [UIFont fontWithName:@"Century Gothic" size:fontSize],
                                  NSForegroundColorAttributeName : textColor
                                  };
    [drawString drawInRect:CGRectIntegral(drawRect) withAttributes:attributes];


	//darw edge
    CGSize edgeSize = background.size;
    UIImage *newEdgeImage = [appDelegate imageWithImage:[imageViewEdge image] scaledToSize:edgeSize withHard:NO];
    [newEdgeImage drawAtPoint:CGPointMake(0,0)];
	
    
	//done
	resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    //The completion block to be executed after image taking action process done
    void (^completionBlock)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        [self imageSavedFinished:error];
    };

    void (^failureBlock)(NSError *) = ^(NSError *error) {
        [self imageSavedFinished:error];
    };

    // save image to custom photo album
    [library saveImage:resultingImage
                        toAlbum:@"Quote Addict"
                completion:completionBlock
                   failure:failureBlock];

    //save custom album
	 /*[library saveImage:resultingImage toAlbum:@"Quote Addict" withCompletionBlock:^(NSError *error) {
     
        [self imageSavedFinished:error];
    }];*/
	
    //[self showSpin:NO];
}

-(void)imageSavedFinished:(NSError *)error
{    
    [self showSpin:NO];
    
    if(error)
    {
        NSLog(@"didFinishSavingWithError: %@", error);
        
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The image could not be saved to your Photo Library." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Saved" message:@"The image has been saved to your Photo Library. Use the Photos application to set it as your\n Wallpaper or Lock Screen." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];*/
        
        [Helpers showMessageHud:@"Image saved"];
    }
}

- (void)actionReload:(id)sender
{
   [self setupUI];
}

- (void)actionSwipeLeft
{
    NSLog(@"actionSwipeLeft");
    
    [self nextQuote];
}

- (void)actionSwipeRight
{
    NSLog(@"actionSwipeRight");
    
    [self previousQuote];
}

- (void)actionSwipeUp
{
    NSLog(@"actionSwipeDown");
    
    [self nextQuote];
}

- (void)actionSwipeDown
{
    NSLog(@"actionSwipeDown");
    
    [self previousQuote];
}

- (void)actionMenu:(id)sender
{
    //if still loading
    if(darkImage.hidden == NO)
        return;
    
    //if([appDelegate savedImage] == nil)
    //    return;
    
    
    NSString *footer = @"Check out Quote Addict for iOS!";
    NSString *body = [NSString stringWithFormat:@"%@\n\n\n%@", mixed, footer];
    body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    
    NSString *textToShare = body;
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/app/id580936901"];
    NSString *subject = @"Quote from Quote Addict for iOS";
    
    //UIImage *image = [appDelegate savedImage];
    //NSArray *objectsToShare = @[textToShare, url, image];
    
    NSArray *objectsToShare = @[textToShare, url /*, image*/];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    /*NSArray *excludeActivities = @[
     //UIActivityTypeAirDrop,
     //UIActivityTypePrint,
     //UIActivityTypeAssignToContact,
     //UIActivityTypeSaveToCameraRoll,
     //UIActivityTypeAddToReadingList,
     //UIActivityTypePostToFlickr,
     UIActivityTypePostToVimeo
     ];
     
     activityVC.excludedActivityTypes = excludeActivities;*/
    
    //email subject
    [activityVC setValue:subject forKey:@"subject"];
    
    if([appDelegate isIpad]) {
        if ( [activityVC respondsToSelector:@selector(popoverPresentationController)] ) {
            //activityVC.popoverPresentationController.sourceView = sender;
            activityVC.popoverPresentationController.barButtonItem = sender;
        }
        
    }

    //self is a view, not view controller, try to use root instead
    [self.view.window.rootViewController presentViewController:activityVC animated:YES completion:nil];
    
    
    //disabled
    return;

    
      //lockscreen
    NSString *previewString = @"";
    if([appDelegate showLockscreen] && ![appDelegate isIpad])
        previewString = @"Preview Lock Screen";
    else
        previewString = @"Preview";


    //popup
    //Share on Facebook, send in Email, Tweet on Twitter, Save to Photo Library
    UIActionSheet * actionSheet=nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                               otherButtonTitles: @"Copy", @"Email", @"Text Message", @"Facebook", @"Twitter", previewString, @"Save to Photo Library",
                                                  //nil
                               //otherButtonTitles: @"Email", @"Text Message", @"Facebook", @"Twitter", @"Save to Photo Library",
                                                  nil

                                ];
    
    
	if([appDelegate isIpad])
	{
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[actionSheet showFromBarButtonItem:sender animated:YES];

	}
	else
	{
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    	[actionSheet showInView:self.view];
    }

}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:    (NSInteger)buttonIndex 
{

    if(alertView == alertBing)
    {
        if(buttonIndex==0)
        {
            //cancel
        }
        else if(buttonIndex==1)
        {
        	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bing.com/"]];
        }
    }
    
}

- (void)actionLockscreen:(id)sender
{
    NSLog(@"actionLockscreen");

    lockscreenButton.hidden = YES;
        
    [self showInterface:!previewWasInfoHidden];

}

- (void)actionFavorite:(id)sender
{
    if(isFavorite)
    {
        isFavorite = NO;
        [appDelegate removeFavorite:currentId];
    }
    else
    {
        isFavorite = YES;
        [appDelegate addFavorite:currentId];
        
        //increase view
        [self IncView];
    }
    
    [appDelegate saveState];
    [self updateFavoriteButton];
}

-(void)IncView
{
    //todo:chris
    if(![appDelegate isDebug] && [appDelegate isOnline]) //not in debug
    {
        /*NSString *viewStringURL = [NSString stringWithFormat: URL_API_INC_VIEW, [appDelegate nameToLoad]];
        NSString *viewStringOut = [appDelegate getStringFromURL:viewStringURL];
        NSLog(@"views: %@", viewStringOut);*/
    }
}

-(void)updateFavoriteButton
{
    UIImage *btnImage = nil;
    
    if(isFavorite)
        btnImage = [UIImage imageNamed:@"favorite.png"];
    else
        btnImage = [UIImage imageNamed:@"favorite_off.png"];
    
    [buttonFavorite setImage:btnImage forState:UIControlStateNormal];
}



- (void)actionRandom:(id)sender
{
    NSLog(@"actionRandom");
        
    //[self randomQuote];
    [self performSelector:@selector(randomQuote) withObject:nil afterDelay:0.1];

}

- (void)actionArrowRight:(id)sender
{
    NSLog(@"actionArrowRight");
        
    //[self nextQuote];
    [self performSelector:@selector(nextQuote) withObject:nil afterDelay:0.1];

}

- (void)actionArrowLeft:(id)sender
{
    NSLog(@"actionArrowLeft");
        
    //[self previousQuote];
    [self performSelector:@selector(previousQuote) withObject:nil afterDelay:0.1];
}


- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    library = nil;
}


- (void)dealloc {
    //[super dealloc];
	   
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    //[HUD removeFromSuperview];
	//[HUD release];
}

	
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo 
{
    [self imageSavedFinished:error];
}

-(void) saveImage: (UIImage*) image
{
    //[self showHud:@"Saving"];
    
    [self showSpin:YES];

	UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:), nil);
    
}

- (void)nextQuote
{
    [self curlViewUp];
    
    indexUndo = indexToLoad;
    
    indexToLoad++;
    if(indexToLoad >= [appDelegate totalItems])
        indexToLoad = [appDelegate totalItems] - 1;

    [self showInterface:YES];
}

- (void)previousQuote
{
        [self curlViewDown];
    
    indexUndo = indexToLoad;
    
    indexToLoad--;
    if(indexToLoad < 0)
        indexToLoad = 0;

    [self showInterface:YES];
}

- (void)undoQuote
{
    if(flipping)
        return;
    
    if(indexUndo == -1)
        return;
    
    [self curlViewDown];
    
    indexToLoad = indexUndo;
    
    [self showInterface:YES];
}


- (void)randomQuote
{
    //if(flipping)
    //    return;
    
    [self curlViewUp];
   
    //random
    indexUndo = indexToLoad;
    indexToLoad = rand()%[appDelegate totalItems];
    
    [self showInterface:YES];
}

- (void)curlViewUp
{
     [self curlView:YES];
}

- (void)curlViewDown
{
    [self curlView:NO];
}

- (void)curlView:(BOOL)up
{
    if(flipping)
        return;
    
    flipping = YES;
    
    self.view.hidden = YES;
    shuffleButton.enabled = NO;
    arrowLeftButton.enabled = NO;
    arrowRightButton.enabled = NO;
    buttonFavorite.enabled = NO;
    
    [UIView transitionWithView:self.view
              //duration: 0.75
               //options: (up ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown)
     
                duration: 0.3
                options: (up ? UIViewAnimationOptionTransitionCrossDissolve : UIViewAnimationOptionTransitionCrossDissolve)
     
            animations:^{
                self.view.hidden = NO;
                shuffleButton.enabled = YES;
                arrowLeftButton.enabled = YES;
                arrowRightButton.enabled = YES;
                buttonFavorite.enabled = YES;
            } 
            completion:^(BOOL finished)
                {
                    if (finished)
                    {
                        shuffleButton.enabled = YES;
                        arrowLeftButton.enabled = YES;
                        arrowRightButton.enabled = YES;
                        buttonFavorite.enabled = YES;
                        flipping = NO;
                    }
                }
    ];
    
    //old way
    /*
    if(flipping)
        return;
    
    flipping = YES;
    self.view.hidden = YES;
    
    shuffleButton.enabled = NO;
	arrowLeftButton.enabled = NO;
	arrowRightButton.enabled = NO;
    
    [UIView beginAnimations:@"Flip" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    if(up)
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    else
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    
    self.view.hidden = NO;
    
    shuffleButton.enabled = YES;
	arrowLeftButton.enabled = YES;
	arrowRightButton.enabled = YES;
    
    flipping = NO;
    [UIView commitAnimations];    */
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        [self undoQuote];
       //[self randomQuote];
    }
}


/*
- (void)showHud:(NSString*)text
{
    return;
    
    // Should be initialized with the windows frame so the HUD disables all user input by covering the entire screen
	
    UIView* tempView = self.view;
    //HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD = [[MBProgressHUD alloc] initWithView:tempView];
    
	// Add HUD to screen
	[self.view.window addSubview:HUD];
    
	// Register for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
    
	//HUD.labelText = @"Test";
    HUD.labelText = text;
    
    HUD.userInteractionEnabled = NO;
    
     doHud = TRUE;
    //[HUD showWhileExecuting:@selector(hudTask) onTarget:self withObject:nil animated:YES];
    
    //delay?
    [self performSelector:@selector(showHud2) withObject:nil afterDelay:0.1
    ];

}

- (void)showHud2
{
    [HUD showWhileExecuting:@selector(hudTask) onTarget:self withObject:nil animated:YES];
}

- (void)hudWasHidden {
    
    //doHud = false;
    [HUD removeFromSuperview];
	//[HUD release];
    HUD = nil;
    
	// Remove HUD from screen when the HUD was hidden
	//[HUD removeFromSuperview];
	//[HUD release];
}

- (void)hudTask 
{
    
    int hudTimeStart = [[NSDate date] timeIntervalSince1970];
    bool doMinimum = true;
    //while(doHud)     
    while(doHud || doMinimum) //at least 1 sec
    { 
        int hudTimeCurrent =  [[NSDate date] timeIntervalSince1970]; 
        //int diff = [[NSDate date] timeIntervalSince1970] - hudTimeStart ;
        //doMinimum =  (diff <= 1000);
        //more than 5 secs
        int diff = (hudTimeCurrent - hudTimeStart) ; //in 1000ths or seconds?
        if(diff <= 1)
        {
            doMinimum = true;
        }
        else
        {
            doMinimum = false;
        }
        
        if( diff > 10)
        {
            doHud = false;
           
        }
    }
    
    //hide
    doHud = false;
    doMinimum = false;
    //[HUD hide:YES]; 
    [HUD hide:YES];
   // [HUD hide:YES afterDelay:2];
    
}
*/

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {

    //return;
    
    NSLog(@"FirstViewController::handleSingleTap");

    [self toggleInterface];
    
}

-(void)showInterface:(BOOL)show
{
	[lock1 lock];
		
    NSLog(@"FirstViewController::showInterface");
    
	interfaceHidden = !show;

    shuffleButton.hidden = interfaceHidden;
	arrowLeftButton.hidden = interfaceHidden;
	arrowRightButton.hidden = interfaceHidden;
    buttonFavorite.hidden =  interfaceHidden;
    
    //count
    NSString * searchString = [[appDelegate archiveViewController] searchString];
    
    //NSString *tempString =[NSString stringWithFormat:@"%d of %d", (indexToLoad+1), [appDelegate totalItems]];
    NSString *tempString = nil;
    
    if([searchString length] == 0)
        tempString = [NSString stringWithFormat:@"%d of %d", (indexToLoad+1), [appDelegate totalItems]];
    else
        tempString = [NSString stringWithFormat:@"%d of %d for '%@'", (indexToLoad+1), [appDelegate totalItems], searchString];
    
    //remove 'category:'
    tempString = [tempString stringByReplacingOccurrencesOfString:@"category:" withString:@""]; 
    countLabel.text = tempString;
    countLabel.hidden = interfaceHidden;

	
    //nav
    [[appDelegate navController] setNavigationBarHidden:interfaceHidden animated:YES];
	

    //quote
    //int tempCound = [[appDelegate quotes] count];
    NSAssert([appDelegate quotes] && [[appDelegate quotes] count] > 0 && [[appDelegate quotes] count] < 100000, @"Error: no quotes.");
	
	
    Quotes *quotes = (Quotes*)[[appDelegate quotes] objectAtIndex:indexToLoad];

    //favorite
    currentId = [quotes rowId];
    isFavorite = [appDelegate isFavorite:currentId];
    [self updateFavoriteButton];
	
    NSString *authorString;
    if([[quotes author2] length] != 0)
        authorString = [NSString stringWithFormat:@"- %@, %@", [quotes author1], [quotes author2]];
    else
        authorString = [NSString stringWithFormat:@"- %@", [quotes author1]];
    /*cell.textTitle.text = authorString;
    cell.textTitle.textAlignment = NSTextAlignmentLeft;
    cell.textTitle.contentMode = UIViewContentModeTop;*/

    
    NSString *desc = [quotes quote];
    //mixed =[NSString stringWithFormat:@"%@\n\n%@", desc,  authorString];
    mixed =[NSString stringWithFormat:@"%@\n\n %@", desc,  authorString]; //indented
    textDesc.text = mixed;
    
    textDesc.alpha = 0.6;
    
    NSLog(@"%@", mixed);
    
    int fontSize = 0;
    if([mixed length] > 500)
        fontSize = 10;
    else if([mixed length] > 400)
        fontSize = 12;
    else if([mixed length] > 300)
        fontSize = 12;
    else if([mixed length] > 200)
        fontSize = 14;
    else if([mixed length] > 130)
        fontSize = 16;
    else
        fontSize = 18;
    
    //BOOL isFunny = !([[quotes categories] rangeOfString:@"funny"].location == NSNotFound);
    //BOOL isFunny =  NO; //!([[quotes categories] rangeOfString:@"funny"].location == NSNotFound);

    /*if(isFunny)
    {
        fontSize-=2;
        [textDesc setFont: [UIFont fontWithName:@"A.C.M.E. Secret Agent" size:fontSize]];
    }
    else
        [textDesc setFont: [UIFont fontWithName:@"Century Gothic" size:fontSize]];*/
	
	//[textDesc setFont: [UIFont fontWithName:@"Quando" size:fontSize]];
	//[textDesc setFont: [UIFont fontWithName:@"Noticia Text" size:fontSize]];
	[textDesc setFont: [UIFont fontWithName:@"Century Gothic" size:fontSize]];
	

	
    //[textDesc setFont: [UIFont fontWithName:@"Century Gothic" size:18]];
    //[textDesc setFont: [UIFont fontWithName:@"A.C.M.E. Secret Agent" size:18]];
    textDesc.textColor = [UIColor whiteColor]; //RGBA(94, 94, 94, 255); //grey
    //textDesc.highlightedTextColor = RGBA(94, 94, 94, 255); //grey

    //[self updateZoom];
    //[self maxZoom];

    //auto copy
    //if(show)
    //    [self copyToPasteBoard];
	
	[lock1 unlock];
}

- (void)toggleInterface
{
    NSLog(@"FirstViewController::toggleInterface");

    //toggle    
    interfaceHidden = !interfaceHidden;
    
    [self showInterface:!interfaceHidden];

}


- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        alreadyLongPress = NO;
        return;
    }
    
    if(alreadyLongPress)
        return;
    
    NSLog(@"FirstViewController::handleLongPress");
    
    alreadyLongPress = YES;
    
    
    [self actionMenu:0];
}


-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"FirstViewController::actionSheet didDismissWithButtonIndex");

    //SHKItem *item = nil;
    //NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id580936901"];

    //otherButtonTitles: @"Copy", @"Email", @"Text Message", /*@"QR Code",  @"Preview Lock Screen", @"Gift App",*/ @"Facebook", @"Twitter",

    switch (buttonIndex)
    {
        case 0:
            //copy
            [self copyToPasteBoard];
            
            [Helpers showMessageHud:kStringCopied];

            break;
            
        case 1:
            if([MFMailComposeViewController canSendMail])
            {
                NSString *footer = @"Check out Quote Addict for iOS:\nhttp://itunes.apple.com/app/id580936901";
                NSString *body = [NSString stringWithFormat:@"%@\n\n\n%@", mixed, footer];
                body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                [appDelegate sendEmailTo:@"" withSubject: @"Quote from Quote Addict" withBody:body withView:self];
            }
            else
                [UIAlertView showError:@"Could not send email." withTitle:@"Error"];
            
            break;
            
         case 2:
            if([MFMessageComposeViewController canSendText] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms:"]])
            {
                NSString *body = [NSString stringWithFormat:@"%@", mixed];
                body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

                /*SHKItem *item = nil;

                item = [SHKItem text:body];

                [SHKTextMessage shareItem:item]; */
            }
            else
                [UIAlertView showError:@"Could not send text message." withTitle:@"Error"];

            break;
            
        case 3:
                    //facebook
                    {
                        NSString *body = [NSString stringWithFormat:@"%@", mixed];
                        body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                        body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

                        //no image
                        //item = [SHKItem URL:[NSURL URLWithString:body] title:body contentType:SHKURLContentTypeUndefined];
                        //item = [SHKItem text:body];
                        //[SHKFacebook shareItem:item];
                    }
                    break;
			
                    
		case 4:
                    //twitter
                    {
                        NSString *body = [NSString stringWithFormat:@"%@", mixed];
                        body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                        body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                        
                        //check len
                        
                        if([body length] > 140)
                        {
                            [UIAlertView showError:@"This quote is too long for Twitter. Please share it a different way or choose another quote." withTitle:@"Error"];
                        }
                        else
                        {
                            //item = [SHKItem text:body];
                            //[SHKTwitter shareItem:item];
                        }
                    }
                    break;
		
		case 5: //preview
            [self showPreview];
            break;

		case 6: //save
			[self actionSave:0];
			break;

        
        default:
            break;
    }
    
    alreadyLongPress = NO;
}



-(void) orientationChanged:(NSNotification *) object
{    
	NSLog(@"FirstViewController::orientationChanged");
    
	[self updateLockscreenImage];
	
	//interfaceHidden = YES;
	//[self toggleInterface];
}

-(void) updateLockscreenImage
{
	NSLog(@"FirstViewController::updateLockscreenImage");
	
    NSString *filename =  @"";
    NSString *fullFilename = @"";
    
    if([appDelegate showLockscreen])
        filename = @"lockscreen";
    else
        filename = @"lockscreen2";

	if([appDelegate isIpad])
    {
		lockscreenButton.frame = [appDelegate GetScreenRect];
		lockscreenButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;

		if([appDelegate isPortrait])
		{
            fullFilename = [NSString stringWithFormat:@"%@_ipad.png", filename];
			[lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
		}
		else
		{
            fullFilename = [NSString stringWithFormat:@"%@_ipad_landscape.png", filename];
			[lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
		}
		
    }
	else if([appDelegate isIphone5])
    {
        fullFilename = [NSString stringWithFormat:@"%@_iphone5.png", filename];
        [lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
    }
	else
	{
        //normal
        fullFilename = [NSString stringWithFormat:@"%@", filename];
		[lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
	}
}

/*
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration:{
       CGRect screen = [appDelegate GetScreenRect];
       float pos_y, pos_x;
       pos_y = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.width/2  : screen.size.height/2;
       pos_x = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.height/2 : screen.size.width/2;

       myImageView.center = CGPointMake(pos_x, pos_y);
}

*/

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self updateLockscreenImage];   
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
}


-(void)showSpin:(BOOL)show
{
    spin.hidden = !show;
    if(show)
    [[self view] bringSubviewToFront:spin]; 
    
    darkImage.hidden = !show;
}

/*
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{

    return YES;
}
*/

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

- (void)copyToPasteBoard
{
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *body = textDesc.text;
    body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

	[pasteboard setValue: body forPasteboardType:@"public.utf8-plain-text"];
}



@end

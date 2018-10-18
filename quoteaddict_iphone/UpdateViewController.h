//
//  UpdateViewController.h
//
//  Created by Chris Comeau on 10-02-15.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "QuoteAddictAppDelegate.h"

@interface UpdateViewController : UIViewController 
{
	id appDelegate;
	UIButton *doneButton;
    UITextView *textView;
    UIProgressView *progress;
}

@property(nonatomic,retain) IBOutlet UIButton *doneButton;
@property(nonatomic,retain) IBOutlet UITextView *textView;
@property(nonatomic,retain) IBOutlet UIProgressView *progress;

@end

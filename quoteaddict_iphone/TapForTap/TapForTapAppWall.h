//
//  TapForTapAppWall.h
//  TapForTapAds
//
//  Created by Sami Samhuri on 12-09-05.
//  Copyright (c) 2012 Tap for Tap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TapForTapAppWall : NSObject

+ (void) prepare;
+ (BOOL) isReady;
+ (void) showWithRootViewController: (UIViewController *)rootViewController;

- (BOOL) isReady;
- (void) showWithRootViewController: (UIViewController *)rootViewController;

@end

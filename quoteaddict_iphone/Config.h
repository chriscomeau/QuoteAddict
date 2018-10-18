//
//  Config.h
//
//  Created by Chris Comeau on 2013-10-29.
//

#import <Foundation/Foundation.h>

#define kGoogleAnalyticsTrackingID @"???"
#define kMailChimpAPIKey @"???"
#define kMailChimpListID @"???" // Skyriser Media Updates
#define kMailChimpShowMax 2

#define kButtonFont  [UIFont fontWithName:@"Century Gothic" size:14];

#define kGoogleAdMobId @"???"

//parse, new
#define kParseApplicationID @"???"
#define kParseClientKey @"???"

//strings
#define kStringCopied @"Copied"

/*
iphone 4:
old: 960 x 640
new: ???

iphone 5:
old: 1136 x 640
new: 1392 x 744

ipad:
old:
2048 x 1536
new:
??
2524x2524px

---
To avoid this you can create your own simply by adjusting the resolution of the wallpaper you use. You need to have 200 pixels on each side of the image to create the perfect parallax wallpaper. The correct resolutions are follows:

iPad 2 and iPad mini: 1,424 x 1,424
iPad 3 and iPad 4: 2,448 x 2,448
iPhone 4S: 1,360 x 1,040
iPhone 5: 1,536 x 1,040

The iPhone 4 doesn't support parallax wallpapers.

Read more at http://www.trustedreviews.com/opinions/ios-7-tips-and-tricks-a-simple-guide#bL015whWOrIQEstp.99
---

iPad 2, iPad mini:
1424×1424

iPad Retina:
2448×2448

iPhone 4S (iPhone 4 does not support Parallax):
1360×1040

iPhone 5, iPod touch 5:
1536×1040


*/

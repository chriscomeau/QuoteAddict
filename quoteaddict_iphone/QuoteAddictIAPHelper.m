//
//  QuoteAddictIAPHelper.m
//  
//
//  Created by Chris Comeau on 3/24/13.
//
//


#import "QuoteAddictAppDelegate.h"
#import "QuoteAddictIAPHelper.h"

@implementation QuoteAddictIAPHelper

+ (QuoteAddictIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static QuoteAddictIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAP_ID_REMOVEADS,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
	
    return sharedInstance;
}

@end
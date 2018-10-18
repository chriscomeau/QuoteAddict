//
//  UpdateViewController.m
//
//  Created by Chris Comeau on 10-02-15.
//  Copyright 2010 Games Montreal. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "UpdateViewController.h"
#import "QuoteAddictAppDelegate.h"
#if USE_TESTFLIGHT
#import "TestFlight.h"
#endif
#import "AFNetworking.h"


@implementation UpdateViewController

@synthesize doneButton;
@synthesize textView;
@synthesize progress;

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    //flag
    [appDelegate setShowUpdate:NO];
    
    //doneButton.text = @"Done";
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitle:@"Done" forState:UIControlStateHighlighted];
    [doneButton setTitle:@"Done" forState:UIControlStateDisabled];
    [doneButton setTitle:@"Done" forState:UIControlStateSelected];
    doneButton.Enabled = false; //button disabled
    
    //scroll bars
	//[textView flashScrollIndicators];
    
    progress.progress = 0;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self becomeFirstResponder];
    
    [self downloadDatabase];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (QuoteAddictAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[doneButton addTarget:self action:@selector(actionDone:) forControlEvents:UIControlEventTouchUpInside];
        
    //set font
    UIFont* tempFont = [UIFont fontWithName:@"Century Gothic" size:13] ; 
	[textView setFont:tempFont];
    
    tempFont = kButtonFont; 
	doneButton.titleLabel.font = tempFont;
    [doneButton setTitleColor:[appDelegate buttonTextColor] forState:UIControlStateNormal];
    doneButton.Enabled = false; //button disabled
    
    //corner
    [appDelegate cornerView:self.view];

}


- (void)actionDone:(id)sender
{
	[appDelegate alertUpdateDone:NO];
    
#if USE_TESTFLIGHT
    if([appDelegate isTestflight])
        [TestFlight passCheckpoint:@"UpdateViewController:actionDone"];
#endif
}

- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
}


- (void)dealloc {
    
	//[doneButton release];
	//[doneButton release];
	//[webView release];

	//[super dealloc];
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

- (void)downloadDatabase
{
    NSString *url = [NSString stringWithFormat:@"%@", URL_UPDATE];
    //NSString *url = [NSString stringWithFormat:@"%@?%.0f", URL_UPDATE, [[NSDate date] timeIntervalSince1970]]; //to prevent caching?
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL_UPDATE]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:DB_NAME_UPDATE];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        if(totalBytesExpectedToRead <= 0)
            progress.progress = 1.0;
        else
            progress.progress = (float)totalBytesRead / totalBytesExpectedToRead;
        
        NSLog(@"%@", [NSString stringWithFormat:@"downloadDatabase: total: %lld", totalBytesExpectedToRead]);
    }];
    
    [operation setCompletionBlock:^{
        NSLog(@"downloadDatabase: complete");
        
        progress.progress = 1;
        
        [NSThread sleepForTimeInterval:0.5]; //slow down a bit
        
        //skip
        //if(false)
        {
            [appDelegate replaceDatabaseUpdate];        
            [appDelegate alertUpdateDone:YES];
        }
        
        doneButton.Enabled = YES;
    }];
    
    [operation start];
    
}

@end

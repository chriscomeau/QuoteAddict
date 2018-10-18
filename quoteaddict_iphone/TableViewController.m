

#import "TableViewController.h"
#import "TableViewCell.h"

#import "QuoteAddictAppDelegate.h"
#import "Quotes.h"

//#import "SHKFacebook.h"
//#import "SHKTwitter.h"
//#import "FlurryAnalytics.h"

@implementation TableViewController

- (void)viewDidLoad {
    
    NSLog(@"%@", @"TableViewController::viewDidLoad");

    [super viewDidLoad];

    numRows = 0;
    
    appDelegate = (QuoteAddictAppDelegate *)[[UIApplication sharedApplication] delegate];

    //bring to front    
    self.tableView.rowHeight = CELL_HEIGHT_NORMAL;
    
    self.tableView.scrollsToTop = YES;

    //background    

    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-green.png"]];
    //self.tableView.backgroundView = imageView;
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.opaque = NO;
	self.tableView.backgroundView = nil;
   
    
    //separator
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.tableView.scrollsToTop = YES;    
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}


//to hide empty cell border, separator
/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return [UIView new];
    }
    return nil;
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
       
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    //int totalItems = [appDelegate totalItems] ;

    //not ready yet
    if(![appDelegate isDoneLaunching])
    {
        NSLog(@"TableViewController::tableView:numberOfRowsInSection: %d", 0);
        return 0;
    }
    
    /*if(![appDelegate isOnline])
    {
        NSLog(@"TableViewController::tableView:numberOfRowsInSection: %d", 0);
        return 0;
    }*/

    
    numRows = [appDelegate numRows];
    
    NSLog(@"TableViewController::tableView:numberOfRowsInSection: %d", numRows);
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    TableViewCell *cell = nil;
    
    //UIImage *cellBackImage = nil;
    if(indexPath.row % 2 != 0) //alternate
        //cellBackImage = [appDelegate cellBackImage1];
        cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell1"];

    else
        //cellBackImage = [appDelegate cellBackImage2];
        cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell2"];
    
    //normal cell
    //cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    
    if (cell == nil) 
    {
        //http://stackoverflow.com/questions/540345/how-do-you-load-custom-uitableviewcells-from-xib-files
        // Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"TableViewCell" bundle:nil];
        UIImage *cellBackImage = nil;

        if(indexPath.row % 2 != 0) //alternate
        {
            cellBackImage = [appDelegate cellBackImage1];
        }
        else
        {
            cellBackImage = [appDelegate cellBackImage2];
        }
        
        // Grab a pointer to the custom cell.
        cell = (TableViewCell *)temporaryController.view;
        
        //once
        
        //show all
        cell.backImageView.hidden = NO;
        cell.textDesc.hidden = NO;
        
        //no highlight
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        cell.textDesc.textColor = RGBA(94, 94, 94, 255); //grey
        cell.textDesc.highlightedTextColor = cell.textDesc.textColor; //grey

        cell.textIndex.textColor = RGBA(180, 180, 180, 255); //grey
        cell.textIndex.highlightedTextColor = cell.textIndex.textColor; //grey
        [[cell textIndex] setFont: [UIFont fontWithName:@"Century Gothic" size:10]];
        
            //fx
        cell.textDesc.textAlignment = NSTextAlignmentLeft;
        //cell.textDesc.contentMode = UIViewContentModeTop;
        cell.textDesc.contentMode = UIViewContentModeCenter;
                
        //back
        cell.backImageView.hidden = NO;
                           
        //hide
        [cell imageView].hidden = YES;
        
        //back
        [cell.backImageView setImage:cellBackImage];
    }
    
    //int tempCound = [[appDelegate quotes] count];
    NSAssert([appDelegate quotes] && [[appDelegate quotes] count] > 0 && [[appDelegate quotes] count] < 100000, @"Error: no quotes.");
    Quotes *quotes = (Quotes*)[[appDelegate quotes] objectAtIndex:indexPath.row];
    
    
    NSString *authorString;
    if([[quotes author2] length] != 0)
        authorString = [NSString stringWithFormat:@"- %@, %@", [quotes author1], [quotes author2]];
    else
        authorString = [NSString stringWithFormat:@"- %@", [quotes author1]];
    
    
    NSString *desc = [quotes quote];
    //NSString *mixed =[NSString stringWithFormat:@"%@\n\n%@", desc,  authorString];
    NSString *mixed =[NSString stringWithFormat:@"%@\n\n %@", desc,  authorString]; //indented
    cell.textDesc.text = mixed;

    int fontSize = 0;
    if([mixed length] > 400)
        fontSize = 7;
    else if([mixed length] > 300)
        fontSize = 8;
    else if([mixed length] > 200)
        fontSize = 9;
    else if([mixed length] > 130)
        fontSize = 12;
    else
        fontSize = 14;
	
	//for small font
	//fontSize +=2;
    
    //[[cell textDesc] setFont: [UIFont fontWithName:@"Century Gothic" size:fontSize]];
	//[[cell textDesc] setFont: [UIFont fontWithName:@"Quando" size:fontSize]];
	//[[cell textDesc] setFont: [UIFont fontWithName:@"Noticia Text" size:fontSize]];
	[[cell textDesc] setFont: [UIFont fontWithName:@"Century Gothic" size:fontSize]];
    
	//index
    //cell.textIndex.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    cell.textIndex.text = [NSString stringWithFormat:@"%d of %d", indexPath.row + 1, [appDelegate totalItems]];

    //back
    //[cell.backImageView setImage:cellBackImage];

    
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    return cell;
}


-(void)showScreenshot2:(NSNumber*)number
{   
    //remove highlight
    //[(UITableView*)[self view] deselectRowAtIndexPath: [(UITableView*)[self view] indexPathForSelectedRow ] animated:NO];
    
    [appDelegate selectImage:[number intValue] showView:YES];
    
    //[self showScreenshot: [number intValue]];
}

- (void)showScreenshot:(int)index
{
    //[[appDelegate mainViewController] showScreenshot: index];
}

- (void)actionThumbnail:(id)sender forEvent:(UIEvent *)event
{    
    NSLog(@"TableViewController::actionThumbnail");
    
    UITableView *tempTableView = (UITableView*)[self view];
    
    NSIndexPath *indexPath = 
    [tempTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:tempTableView]];
    
    //[self performSelector:@selector(showScreenshot2:) withObject:[NSNumber numberWithInt:indexPath.row] afterDelay:CLICK_DELAY];
    
    [self performSelector:@selector(showScreenshot2:) withObject:[NSNumber numberWithInt:indexPath.row] afterDelay:0.0];

}


// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath 
{
    NSLog(@"TableViewController::didSelectRowAtIndexPath");
        
    {
        //sound
        //[appDelegate playSound:SOUND_1];
            
        [appDelegate selectImage:newIndexPath.row showView:YES];

        //deselect
        [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
        
        
        /*
        //skip double-click
        //[appDelegate setSwitching:YES];
        
        //screenshot
        [self performSelector:@selector(showScreenshot2:) withObject:[NSNumber numberWithInt:newIndexPath.row] afterDelay:CLICK_DELAY];
        
        //input
        //self.view.userInteractionEnabled = NO;
         */

    }   
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{        
    return CELL_HEIGHT_NORMAL;
    
}

- (void)refresh {
    NSLog(@"%@", @"TableViewController::refresh");

    [appDelegate refresh];
    
    //[self stopLoading];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.0];
}


- (void)dealloc {
    //[super dealloc];
}

//disabled pull to refresh
/*- (void)startLoading
{
    NSLog(@"%@", @"TableViewController::startLoading");

    //[self refresh];
    
     //refresh all rows
    [self.tableView reloadData];
    
}
*/
/*
- (void)stopLoading
{
}
*/

- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}


@end




#import <UIKit/UIKit.h>
//#import "PullRefreshTableViewController.h"

//disabled pull to refresh, to reenable, change class to PullRefreshTableViewController and comment startLoading/stopLoading
//@interface TableViewController : PullRefreshTableViewController {
@interface TableViewController : UITableViewController {
    id appDelegate;
    int numRows;
}

- (void)refresh;

- (void)showScreenshot:(int)index;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath ;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)startLoading;
//- (void)stopLoading;
@end

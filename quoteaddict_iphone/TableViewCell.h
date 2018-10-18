//
//  TableViewCell.h
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
{
    id appDelegate;

    UIImageView *backImageView;    
    UILabel *textDesc;
    UILabel *textIndex;
}

@property(nonatomic,retain)  IBOutlet UIImageView *backImageView;
@property(nonatomic,retain)  IBOutlet UILabel *textDesc; 
@property(nonatomic,retain)  IBOutlet UILabel *textIndex;

@end

//
//  TableViewCell.m


#import "TableViewCell.h"
#import "QuoteAddictAppDelegate.h"

@implementation TableViewCell

@synthesize backImageView;
@synthesize textDesc;
@synthesize textIndex;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}


@end

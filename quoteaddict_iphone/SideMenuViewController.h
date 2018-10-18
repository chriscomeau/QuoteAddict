//
//  SideMenuViewController.h

#import <UIKit/UIKit.h>


@interface SideMenuViewController : UIViewController <UIActionSheetDelegate>
{
    id appDelegate;

    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
    UIButton *button5;
    UIButton *button6;
    UIButton *button7;
    UIButton *button8;
    UIButton *button9;
    UIButton *button10;
    UIButton *button11;
    UIButton *button12;
    UIButton *button13;
    UIButton *buttonAll;
    UIButton *buttonNew;
    UIButton *buttonRandom;
    UIButton *buttonFavorites;
    UIButton *buttonUpdate;
    
    UIButton *buttonRight;
    
    NSMutableArray  *buttonArray;
    NSMutableArray  *stringArray;
    UIImageView *shadow;
    UIImageView *screenshot;
    BOOL alreadyVisible;
}

@property(nonatomic,retain)  IBOutlet UIButton *button1;
@property(nonatomic,retain)  IBOutlet UIButton *button2;
@property(nonatomic,retain)  IBOutlet UIButton *button3;
@property(nonatomic,retain)  IBOutlet UIButton *button4;
@property(nonatomic,retain)  IBOutlet UIButton *button5;
@property(nonatomic,retain)  IBOutlet UIButton *button6;
@property(nonatomic,retain)  IBOutlet UIButton *button7;
@property(nonatomic,retain)  IBOutlet UIButton *button8;
@property(nonatomic,retain)  IBOutlet UIButton *button9;
@property(nonatomic,retain)  IBOutlet UIButton *button10;
@property(nonatomic,retain)  IBOutlet UIButton *button11;
@property(nonatomic,retain)  IBOutlet UIButton *button12;
@property(nonatomic,retain)  IBOutlet UIButton *button13;
@property(nonatomic,retain)  IBOutlet UIButton *buttonAll;
@property(nonatomic,retain)  IBOutlet UIButton *buttonNew;
@property(nonatomic,retain)  IBOutlet UIButton *buttonRandom;
@property(nonatomic,retain)  IBOutlet UIButton *buttonFavorites;
@property(nonatomic,retain)  IBOutlet UIButton *buttonRight;
@property(nonatomic,retain)  IBOutlet UIButton *buttonUpdate;
@property(nonatomic,retain)  IBOutlet UIImageView *shadow;
@property(nonatomic,retain)  IBOutlet UIImageView *screenshot;

-(void)setupShadow:(int)x withScreen:(CGRect)screenRect;
-(void)updateShadow:(int)x withScreen:(CGRect)screenRect;


@end

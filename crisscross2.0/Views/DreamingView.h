
#import <UIKit/UIKit.h>

@interface DreamingView : UIView

@property (strong, nonatomic) NSArray *dreams;
@property (strong, nonatomic) IBOutlet UIView *tagCloudView;
@property (strong, nonatomic) NSString *mainContactId;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)re:(id)sender;
- (void)doRefreshTagCloud;

@end

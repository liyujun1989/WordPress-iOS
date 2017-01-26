#import <UIKit/UIKit.h>
#import "AbstractPost.h"

// For UIAppearance
@interface PostSettingsNavigationBar : UINavigationBar
@end

@interface PostSettingsViewController : UITableViewController

- (instancetype)initWithPost:(AbstractPost *)aPost;
- (void)endEditingAction:(id)sender;

@property (nonatomic, strong, readonly) AbstractPost *apost;
@end

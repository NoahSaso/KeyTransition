#import <Preferences/Preferences.h>
#import "global.h"

@interface KTCustomListItemsController : PSListItemsController
@end

@implementation KTCustomListItemsController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Animation" inBundle:[self bundle]]];
}

@end

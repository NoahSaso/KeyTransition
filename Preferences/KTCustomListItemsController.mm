#import <Preferences/Preferences.h>
#import "global.h"

@interface KTCustomListItemsController : PSListItemsController
@end

@implementation KTCustomListItemsController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[self bundle].bundlePath stringByAppendingPathComponent:@"Animation"]]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		self.navigationController.navigationBar.tintColor = KTColor;
	else
		self.navigationController.navigationController.navigationBar.tintColor = KTColor;
}

@end

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
	self.navigationController.navigationController.navigationBar.tintColor = KTColor;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationController.navigationController.navigationBar.tintColor = nil;
}

@end

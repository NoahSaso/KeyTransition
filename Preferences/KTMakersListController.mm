#import <Preferences/PSListController.h>
#import "global.h"

@interface KTMakersListController: PSListController {
}
@end

@implementation KTMakersListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Makers" target:self];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Makers" inBundle:[self bundle]]];
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	[infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
}

- (void)showInfo {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"KeyTransition" message:@"You can tap on the icons to view the makers' various social media sites" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}

@end

// vim:ft=objc

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
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[self bundle].bundlePath stringByAppendingPathComponent:@"Makers"]]];
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	[infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		self.navigationController.navigationBar.tintColor = KTColor;
	else
		self.navigationController.navigationController.navigationBar.tintColor = KTColor;
}

- (void)showInfo {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"KeyTransition" message:@"You can tap on the icons to view the makers' various social media sites" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}

- (void)openPaypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bit.ly/keytransitionpp"]];
}

@end

// vim:ft=objc

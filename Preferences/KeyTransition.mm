#import <Preferences/PSListController.h>
#import <Twitter/Twitter.h>

#define KTBundle [NSBundle bundleWithPath:@"/Library/PreferenceBundles/KeyTransition.bundle"]

#define KTColor [UIColor colorWithRed:.17 green:.47 blue:.83 alpha:1]

@interface UIImage (Private)
+ (UIImage *)imageNamed:(NSString *)named inBundle:(NSBundle *)bundle;
@end

@interface KeyTransitionListController: PSListController {
}
- (UIViewController *)rootController;
@end

@implementation KeyTransitionListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"KeyTransition" target:self];
	}
	// Get the banner image
	UITableView* tableView = [self table];
	UIImageView* headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Banner" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/KeyTransition.bundle"]]];
	// Resize header image
	CGFloat paneWidth = [[UIScreen mainScreen] bounds].size.width;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		paneWidth = [self rootController].view.frame.size.width;
	// Resize frame to fit
	CGRect newFrame = headerImage.frame;
	CGFloat ratio = paneWidth / newFrame.size.width;
	newFrame.size.width = paneWidth;
	newFrame.size.height *= ratio;
	headerImage.frame = newFrame;
	// Add header container
	UIView* headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, newFrame.size.height)];
	headerContainer.backgroundColor = [UIColor clearColor];
	[headerContainer addSubview:headerImage];
	[tableView setTableHeaderView:headerContainer];
	// Color stuff
	[UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = KTColor;
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = KTColor;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = KTColor;
	[UINavigationBar appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor whiteColor];
	[UINavigationBar appearanceWhenContainedIn:self.class, nil].barTintColor = KTColor;
	[UISlider appearanceWhenContainedIn:self.class, nil].tintColor = KTColor;
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyTransition" inBundle:KTBundle]];
	self.navigationItem.titleView.alpha = 0;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Twitter" inBundle:KTBundle] style:UIBarButtonItemStylePlain target:self action:@selector(tweet)];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    [UIView animateWithDuration:0.55 animations:^{
	    	self.navigationItem.titleView.alpha = 1;
	    }];
	});
}

- (void)tweet {
	if([TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController* vc = [[TWTweetComposeViewController alloc] init];
		[vc setInitialText:@"Loving #KeyTransition by @Sassoty and @AOkhtenberg! :)"];
		[vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
			[self dismissModalViewControllerAnimated:YES];
		}];
		[self presentViewController:vc animated:YES completion:nil];
	}else {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"KeyTransition" message:@"Please make sure you have Twitter accounts signed in on your device." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
	}
}

@end

// vim:ft=objc

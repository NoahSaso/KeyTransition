#import <Preferences/PSListController.h>
#import <Twitter/Twitter.h>
#import "global.h"

@interface KeyTransitionListController: PSListController {
}
- (UIViewController *)rootController;
@end

@implementation KeyTransitionListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"KeyTransition" target:self];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Get the banner image
	UITableView* tableView = [self table];
	UIImageView* headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Banner" inBundle:[self bundle]]];
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
	[UINavigationBar appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor whiteColor];
	[UINavigationBar appearanceWhenContainedIn:self.class, nil].barTintColor = KTColor;
	// Title stuff
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyTransition" inBundle:[self bundle]]];
	self.navigationItem.titleView.alpha = 0;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Twitter" inBundle:[self bundle]] style:UIBarButtonItemStylePlain target:self action:@selector(tweet)];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    [UIView animateWithDuration:0.55 animations:^{
	    	self.navigationItem.titleView.alpha = 1;
	    }];
	});
	// Might be an easter egg, might not ;)
	UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refreshOrMaybeNotIDontEvenKnowWhatThisDoesLol:) forControlEvents:UIControlEventValueChanged];
	refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Congratulations, you found me! Keep dragging for a surprise ;)" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor]}];
	[tableView addSubview:refreshControl];
	// Hopefully fixes a weird text overlap bug
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl beginRefreshing];
        [refreshControl endRefreshing];
    });
}

- (void)refreshOrMaybeNotIDontEvenKnowWhatThisDoesLol:(UIRefreshControl *)refreshControl {
	[refreshControl endRefreshing];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.youtube.com/watch?v=dQw4w9WgXcQ"]];
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

- (void)openBugReport {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bit.ly/AOkhtenbergBugReporter"]];
}

@end

// vim:ft=objc

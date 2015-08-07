#import <Preferences/Preferences.h>
#import "global.h"

#define log(z) NSLog(@"[KeyTransition -- MakerTableCell] %@", z)
#define KTBundlePath @"/Library/PreferenceBundles/KeyTransition.bundle"

@interface KTMakerTableCell: PSTableCell {
	NSDictionary* properties;
}

@end

@implementation KTMakerTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"makerCell" specifier:specifier]) {
		
		properties = specifier.properties;

		UIImage* image = [UIImage imageWithContentsOfFile:[KTBundlePath stringByAppendingPathComponent:properties[@"twitter"]]];
		UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
		imageView.backgroundColor = [UIColor clearColor];
		imageView.frame = CGRectMake(10, 10, 75, 75);
		imageView.layer.cornerRadius = imageView.frame.size.width / 2;
		imageView.layer.masksToBounds = YES;
		[self addSubview:imageView];

		CGRect frame = [self frame];

		UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 10, frame.size.width, frame.size.height)];
		name.text = properties[@"name"];
		name.textColor = [UIColor blackColor];
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			name.font = [UIFont systemFontOfSize:28];
		else
			name.font = [UIFont systemFontOfSize:21];
		[self addSubview:name];

		CGFloat nameWidth = [name.text sizeWithAttributes:@{ NSFontAttributeName : name.font }].width;

		UILabel* twitter = [[UILabel alloc] initWithFrame:CGRectMake(name.frame.origin.x + nameWidth + 10, name.frame.origin.y, frame.size.width, frame.size.height)];
		twitter.text = [NSString stringWithFormat:@"(@%@)", properties[@"twitter"]];
		twitter.textColor = [UIColor grayColor];
		twitter.font = [UIFont systemFontOfSize:name.font.pointSize - 4.5];
		[self addSubview:twitter];

		UILabel* role = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 30, frame.size.width, frame.size.height)];
		role.text = properties[@"role"];
		role.textColor = [UIColor grayColor];
		role.font = [UIFont systemFontOfSize:15];
		[self addSubview:role];

		// Bottom social buttons

		CGFloat nextSpacing = frame.origin.x + 95, yLine = frame.origin.y + 63;

		UIButton* twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		twitterButton.frame = CGRectMake(nextSpacing, yLine, 30, 30);
		[twitterButton setImage:[UIImage imageWithContentsOfFile:[KTBundlePath stringByAppendingPathComponent:@"Twitter"]] forState:UIControlStateNormal];
		[twitterButton addTarget:self action:@selector(openTwitter) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:twitterButton];

		nextSpacing += twitterButton.frame.size.width;

		if(properties[@"reddit"]) {
			UIButton* redditButton = [UIButton buttonWithType:UIButtonTypeCustom];
			redditButton.frame = CGRectMake(nextSpacing, yLine, 30, 30);
			[redditButton setImage:[UIImage imageWithContentsOfFile:[KTBundlePath stringByAppendingPathComponent:@"Reddit"]] forState:UIControlStateNormal];
			[redditButton addTarget:self action:@selector(openReddit) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:redditButton];

			nextSpacing += redditButton.frame.size.width;
		}

		if(properties[@"website"]) {
			UIButton* websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
			websiteButton.frame = CGRectMake(nextSpacing, yLine, 30, 30);
			[websiteButton setImage:[UIImage imageWithContentsOfFile:[KTBundlePath stringByAppendingPathComponent:@"Website"]] forState:UIControlStateNormal];
			[websiteButton addTarget:self action:@selector(openWesbite) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:websiteButton];

			nextSpacing += websiteButton.frame.size.width;
		}

		if(properties[@"github"]) {
			UIButton* githubButton = [UIButton buttonWithType:UIButtonTypeCustom];
			githubButton.frame = CGRectMake(nextSpacing, yLine, 30, 30);
			[githubButton setImage:[UIImage imageWithContentsOfFile:[KTBundlePath stringByAppendingPathComponent:@"Github"]] forState:UIControlStateNormal];
			[githubButton addTarget:self action:@selector(openGithub) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:githubButton];

			nextSpacing += githubButton.frame.size.width;
		}

	}
	return self;
}

- (void)openTwitter {
	log(@"Opening twitter:");
	log(properties[@"twitter"]);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", properties[@"twitter"]]]];
}

- (void)openReddit {
	log(@"Opening reddit:");
	log(properties[@"reddit"]);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://reddit.com/u/%@", properties[@"reddit"]]]];
}

- (void)openWesbite {
	log(@"Opening website:");
	log(properties[@"website"]);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:properties[@"website"]]];
}

- (void)openGithub {
	log(@"Opening github:");
	log(properties[@"github"]);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:properties[@"github"]]];
}

@end

// vim:ft=objc

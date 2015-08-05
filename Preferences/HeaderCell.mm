#import "header/PSListController.h"
#import "header/PSSpecifier.h"
#import "header/PSViewController.h"
#import "header/PSTableCell.h"

@interface HeaderCell : PSTableCell {
    UILabel *heading;
    UILabel *subtitle;
    CGFloat goodHeight;
}
@end

@interface UIImage (Private)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@implementation HeaderCell

- (void)layoutSubviews {
    [super layoutSubviews];
    heading.frame = CGRectMake(0, 0, self.frame.size.width, 60);
    subtitle.frame = CGRectMake(0, 35, self.frame.size.width, 60);
}

- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
    if (self) {

        self.backgroundColor = [UIColor clearColor];

        UIImageView* headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Banner" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/KeyTransition.bundle"]]];
        headerImage.contentMode = UIViewContentModeScaleAspectFit;
        // Resize banner to fit screen
        CGRect newFrame = headerImage.frame;
        CGFloat ratio = [[UIScreen mainScreen] bounds].size.width / newFrame.size.width;
        newFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
        newFrame.size.height *= ratio;
        headerImage.frame = newFrame;
        [self.contentView addSubview:headerImage];

        goodHeight = newFrame.size.height;

        /*
        CGRect frame = CGRectMake(0, 0, width, 60);
        CGRect subFrame = CGRectMake(0, 35, width, 60);
        
        heading = [[UILabel alloc] initWithFrame:frame];
        [heading setNumberOfLines:1];
        heading.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
        [heading setText:@"KeyTransition"];
        [heading setBackgroundColor:[UIColor clearColor]];
        heading.textColor = [UIColor blackColor];
        heading.textAlignment = NSTextAlignmentCenter;
        
        subtitle = [[UILabel alloc] initWithFrame:subFrame];
        [subtitle setNumberOfLines:1];
        subtitle.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:16];
        [subtitle setText:@"By Sassoty & AOkhtenberg"];
        [subtitle setBackgroundColor:[UIColor clearColor]];
        subtitle.textColor = [UIColor blackColor];
        subtitle.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:heading];
        [self.contentView addSubview:subtitle];
        */

    }
    
    return self;
}

- (CGFloat)preferredHeightForWidth:(double)arg1 inTableView:(id)arg2 {
    return goodHeight;
}

@end

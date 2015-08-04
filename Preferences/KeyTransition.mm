#import <Preferences/Preferences.h>

@interface KeyTransitionListController: PSListController {
}
@end

@implementation KeyTransitionListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"KeyTransition" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
